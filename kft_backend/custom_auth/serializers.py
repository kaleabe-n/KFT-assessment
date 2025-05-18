from django.contrib.auth.models import User
from django.contrib.auth.forms import SetPasswordForm
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.utils.http import urlsafe_base64_encode
from django.utils.encoding import force_bytes
from django.utils import timezone
from django.contrib.auth import authenticate
from django.core.cache import cache
from rest_framework import serializers
from .models import Role, ROLE_TYPES
from agent.models import *
from consumer.models import *
from merchant.models import *


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "username", "email", "first_name", "last_name"]


class UserCreateSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150)
    password = serializers.CharField(write_only=True, style={"input_type": "password"})
    email = serializers.EmailField()
    first_name = serializers.CharField(required=False, allow_blank=True, max_length=150)
    last_name = serializers.CharField(required=False, allow_blank=True, max_length=150)
    role_type = serializers.ChoiceField(choices=ROLE_TYPES)

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError(
                "A user with that username already exists."
            )
        return value

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("A user with that email already exists.")
        return value

    def create(self, validated_data):
        role_type = validated_data.pop("role_type")
        user = User.objects.create_user(
            username=validated_data["username"],
            password=validated_data["password"],
            email=validated_data["email"],
            first_name=validated_data.get("first_name", ""),
            last_name=validated_data.get("last_name", ""),
            is_active=True,
        )
        Role.objects.create(user=user, type=role_type)
        if role_type == "admin":
            user.is_staff = True
            user.is_superuser = True
            user.save()
        elif role_type == "consumer":
            ConsumerBalance.objects.create(user=user, balance=0.0)
        elif role_type == "agent":
            AgentBalance.objects.create(user=user, balance=0.0)
        elif role_type == "merchant":
            MerchantBalance.objects.create(user=user, balance=0.0)
        return user


class UserUpdateSerializer(serializers.ModelSerializer):
    username = serializers.CharField(required=False)
    email = serializers.EmailField(required=False)
    first_name = serializers.CharField(required=False, allow_blank=True, max_length=150)
    last_name = serializers.CharField(required=False, allow_blank=True, max_length=150)

    class Meta:
        model = User
        fields = ["email", "first_name", "last_name", "username"]
        extra_kwargs = {"email": {"required": False}}

    def validate_email(self, value):
        if (
            self.instance
            and User.objects.filter(email=value).exclude(pk=self.instance.pk).exists()
        ):
            raise serializers.ValidationError("This email address is already in use.")

        return value

    def update(self, instance, validated_data):
        instance.email = validated_data.get("email", instance.email)
        instance.first_name = validated_data.get("first_name", instance.first_name)
        instance.last_name = validated_data.get("last_name", instance.last_name)
        instance.username = validated_data.get("username", instance.username)
        instance.save()
        return instance


class PasswordChangeSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True, write_only=True)
    new_password = serializers.CharField(
        required=True, write_only=True, style={"input_type": "password"}
    )
    confirm_new_password = serializers.CharField(
        required=True, write_only=True, style={"input_type": "password"}
    )

    def validate_old_password(self, value):
        user = self.context["request"].user
        if not user.check_password(value):
            raise serializers.ValidationError(
                "Your old password was entered incorrectly. Please enter it again."
            )
        return value

    def validate(self, data):
        if data["new_password"] != data["confirm_new_password"]:
            raise serializers.ValidationError(
                {"confirm_new_password": "The two password fields didn't match."}
            )

        return data

    def save(self, **kwargs):
        user = self.context["request"].user
        user.set_password(self.validated_data["new_password"])
        user.save()
        return user


class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)

    def validate_email(self, value):
        if not User.objects.filter(email=value).exists():
            raise serializers.ValidationError("User with this email does not exist.")
        return value

    def save(self):
        email = self.validated_data["email"]
        user = User.objects.get(email=email)
        token_generator = PasswordResetTokenGenerator()
        token = token_generator.make_token(user)
        uid = urlsafe_base64_encode(force_bytes(user.pk))
        return {"uid": uid, "token": token, "user_email": user.email}


class OTPVerificationSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    otp_code = serializers.CharField(required=True, max_length=6)

    _pending_user_data = None

    def validate(self, data):
        email = data.get("email")
        otp_code = data.get("otp_code")

        cache_key = f"reg_otp_{email}"
        cached_data = cache.get(cache_key)

        if not cached_data:
            raise serializers.ValidationError(
                "Invalid or expired OTP session. Please try registering again."
            )

        stored_otp = cached_data.get("otp_code")
        expires_at_timestamp = cached_data.get("expires_at_timestamp")

        if (
            not expires_at_timestamp
            or expires_at_timestamp < timezone.now().timestamp()
        ):
            cache.delete(cache_key)
            raise serializers.ValidationError("OTP has expired.")
        if stored_otp != otp_code:
            raise serializers.ValidationError("Invalid OTP.")

        self._pending_user_data = cached_data.get("pending_user_data")
        if not self._pending_user_data:

            cache.delete(cache_key)
            raise serializers.ValidationError(
                "User registration data not found. Please try registering again."
            )

        return data

    def save(self, **kwargs):
        if not self._pending_user_data:
            raise serializers.ValidationError(
                "Cannot save user, pending data not validated."
            )

        user_create_serializer = UserCreateSerializer(data=self._pending_user_data)
        if not user_create_serializer.is_valid():
            raise serializers.ValidationError(user_create_serializer.errors)

        user = user_create_serializer.save()

        cache.delete(f"reg_otp_{self.validated_data['email']}")
        return user


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField(required=True)
    password = serializers.CharField(
        required=True, write_only=True, style={"input_type": "password"}
    )

    def validate(self, data):
        username = data.get("username")
        password = data.get("password")

        if username and password:
            user = authenticate(
                request=self.context.get("request"),
                username=username,
                password=password,
            )
            if not user:
                msg = "Unable to log in with provided credentials."
                raise serializers.ValidationError(msg, code="authorization")
            if not user.is_active:
                msg = "User account is disabled."
                raise serializers.ValidationError(msg, code="authorization")
        else:
            msg = 'Must include "username" and "password".'
            raise serializers.ValidationError(msg, code="authorization")
        data["user"] = user
        return data


class VerifyPasswordResetOTPSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    otp_code = serializers.CharField(required=True, max_length=6)

    _user_id = None

    def validate(self, data):
        email = data.get("email")
        otp_code = data.get("otp_code")

        cache_key = f"pwd_reset_otp_{email}"
        cached_data = cache.get(cache_key)

        if not cached_data:
            raise serializers.ValidationError(
                "Invalid or expired OTP session for password reset."
            )

        stored_otp = cached_data.get("otp_code")
        expires_at_timestamp = cached_data.get("expires_at_timestamp")
        user_id = cached_data.get("user_id")

        if not user_id:
            cache.delete(cache_key)
            raise serializers.ValidationError(
                "User identification missing in OTP session."
            )

        if expires_at_timestamp < timezone.now().timestamp():
            cache.delete(cache_key)
            raise serializers.ValidationError("OTP has expired.")

        if stored_otp != otp_code:
            raise serializers.ValidationError("Invalid OTP.")

        self._user_id = user_id
        return data


class SetNewPasswordSerializer(serializers.Serializer):
    reset_session_token = serializers.CharField(required=True)
    new_password = serializers.CharField(
        write_only=True, required=True, style={"input_type": "password"}
    )
    confirm_new_password = serializers.CharField(
        write_only=True, required=True, style={"input_type": "password"}
    )

    _user_id = None

    def validate_reset_session_token(self, value):
        cache_key = f"pwd_reset_session_{value}"
        cached_data = cache.get(cache_key)

        if not cached_data:
            raise serializers.ValidationError(
                "Invalid or expired password reset session."
            )

        expires_at_timestamp = cached_data.get("expires_at_timestamp")
        user_id = cached_data.get("user_id")

        if not user_id:
            cache.delete(cache_key)
            raise serializers.ValidationError(
                "User identification missing in reset session."
            )

        if expires_at_timestamp < timezone.now().timestamp():
            cache.delete(cache_key)
            raise serializers.ValidationError("Password reset session has expired.")

        self._user_id = user_id
        return value

    def validate(self, data):
        if data["new_password"] != data["confirm_new_password"]:
            raise serializers.ValidationError(
                {"confirm_new_password": "The two password fields didn't match."}
            )

        form = SetPasswordForm(
            user=None,
            data={
                "new_password1": data["new_password"],
                "new_password2": data["confirm_new_password"],
            },
        )
        if not form.is_valid():
            raise serializers.ValidationError(
                form.errors.get("new_password2", "Password validation failed.")
            )
        return data

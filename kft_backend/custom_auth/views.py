from django.contrib.auth.models import User
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.core.mail import send_mail
from django.utils.http import urlsafe_base64_decode
from django.utils.encoding import force_str
from django.shortcuts import get_object_or_404
from django.conf import settings
from django.core.cache import cache
from django.utils import timezone
import random
import datetime
from consumer.models import ConsumerBalance


from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken

from rest_framework import status, permissions, generics
from .serializers import (
    UserSerializer,
    UserCreateSerializer,
    UserUpdateSerializer,
    LoginSerializer,
    PasswordChangeSerializer,
    ForgotPasswordSerializer,
    OTPVerificationSerializer,
    VerifyPasswordResetOTPSerializer,
    SetNewPasswordSerializer,
)
from .permissions import IsAdminOrOwner, IsAdminUser

from rest_framework.authtoken.models import Token


def send_otp_email(email, otp_code):
    subject = "Your One-Time Password (OTP)"
    message = f"Your One-Time Password (OTP) is: {otp_code}\nThis OTP is valid for 10 minutes."
    email_from = getattr(settings, "EMAIL_HOST_USER", "noreply@example.com")
    recipient_list = [email]
    try:
        send_mail(subject, message, email_from, recipient_list, fail_silently=False)
    except Exception as e:
        print(f"ERROR: Could not send OTP email to {email}. Reason: {e}")


OTP_EXPIRY_MINUTES = 10
PWD_RESET_OTP_EXPIRY_MINUTES = 10
PWD_RESET_SESSION_TOKEN_EXPIRY_MINUTES = 10


class AuthView(APIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [permissions.IsAuthenticated(), IsAdminUser()]
        elif self.request.method == "POST":
            return [permissions.AllowAny()]
        return super().get_permissions()

    def get(self, request):
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = UserCreateSerializer(data=request.data)
        if serializer.is_valid():
            pending_user_data = serializer.validated_data
            email = pending_user_data["email"]

            if (
                User.objects.filter(email=email).exists()
                or User.objects.filter(username=pending_user_data["username"]).exists()
            ):
                return Response(
                    {"error": "A user with this email or username already exists."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            otp_code = str(random.randint(100000, 999999))
            expires_at = timezone.now() + datetime.timedelta(minutes=OTP_EXPIRY_MINUTES)

            cache_key = f"reg_otp_{email}"
            cache_data = {
                "otp_code": otp_code,
                "expires_at_timestamp": expires_at.timestamp(),
                "pending_user_data": pending_user_data,
            }
            cache.set(cache_key, cache_data, timeout=(OTP_EXPIRY_MINUTES * 60) + 60)

            send_otp_email(email, otp_code)

            return Response(
                {
                    "message": f"OTP sent to {email}. Please verify to complete registration."
                },
                status=status.HTTP_200_OK,
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = User.objects.all()
    permission_classes = [permissions.IsAuthenticated, IsAdminOrOwner]

    def get_serializer_class(self):
        if self.request.method in ["PUT", "PATCH"]:
            return UserUpdateSerializer
        return UserSerializer


class ChangePasswordView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = PasswordChangeSerializer(
            data=request.data, context={"request": request}
        )
        if serializer.is_valid():
            serializer.save()
            return Response(
                {"message": "Password changed successfully."}, status=status.HTTP_200_OK
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ForgotPasswordView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = ForgotPasswordSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data["email"]
            user = User.objects.get(email=email)

            otp_code = str(random.randint(100000, 999999))
            expires_at = timezone.now() + datetime.timedelta(
                minutes=PWD_RESET_OTP_EXPIRY_MINUTES
            )

            cache_key = f"pwd_reset_otp_{email}"
            cache_data = {
                "otp_code": otp_code,
                "user_id": user.id,
                "expires_at_timestamp": expires_at.timestamp(),
            }
            cache.set(
                cache_key, cache_data, timeout=(PWD_RESET_OTP_EXPIRY_MINUTES * 60) + 60
            )

            send_otp_email(email, otp_code)

            return Response(
                {"message": f"An OTP has been sent to {email} for password reset."},
                status=status.HTTP_200_OK,
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class OTPVerificationView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = OTPVerificationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()

            return_serializer = UserSerializer(user)
            refresh = RefreshToken.for_user(user)

            return Response(
                {
                    "message": "Account verified and created successfully. You can now log in.",
                    "user": return_serializer.data,
                    "refresh": str(refresh),
                    "access": str(refresh.access_token),
                },
                status=status.HTTP_201_CREATED,
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = LoginSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(
            data=request.data, context={"request": request}
        )
        serializer.is_valid(raise_exception=True)

        user = serializer.validated_data["user"]

        refresh = RefreshToken.for_user(user)

        return Response(
            {
                "user": UserSerializer(user).data,
                "refresh": str(refresh),
                "access": str(refresh.access_token),
            },
            status=status.HTTP_200_OK,
        )


class VerifyPasswordResetOTPView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = VerifyPasswordResetOTPSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data["email"]
            user_id = serializer._user_id
            session_token = str(random.randint(10000000, 99999999))
            expires_at = timezone.now() + datetime.timedelta(
                minutes=PWD_RESET_SESSION_TOKEN_EXPIRY_MINUTES
            )

            session_cache_key = f"pwd_reset_session_{session_token}"
            session_cache_data = {
                "user_id": user_id,
                "expires_at_timestamp": expires_at.timestamp(),
            }
            cache.set(
                session_cache_key,
                session_cache_data,
                timeout=(PWD_RESET_SESSION_TOKEN_EXPIRY_MINUTES * 60) + 60,
            )

            otp_cache_key = f"pwd_reset_otp_{email}"
            cache.delete(otp_cache_key)

            return Response(
                {
                    "message": "OTP verified. Use the provided token to set a new password.",
                    "reset_session_token": session_token,
                },
                status=status.HTTP_200_OK,
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class SetNewPasswordView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = SetNewPasswordSerializer(data=request.data)
        if serializer.is_valid():
            user_id = serializer._user_id
            new_password = serializer.validated_data["new_password"]
            session_token = serializer.validated_data["reset_session_token"]

            user = get_object_or_404(User, pk=user_id)
            user.set_password(new_password)
            user.save()

            cache.delete(f"pwd_reset_session_{session_token}")
            return Response(
                {"message": "Password has been reset successfully."},
                status=status.HTTP_200_OK,
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Product, MerchantBalance, MerchantTransactionHistory
from custom_auth.models import Role


class ProductListSerializer(serializers.ModelSerializer):
    owner_username = serializers.CharField(source="owner.user.username", read_only=True)

    class Meta:
        model = Product
        fields = [
            "id",
            "name",
            "description",
            "price",
            "owner_username",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "owner_username", "created_at", "updated_at"]


class ProductSerializer(serializers.ModelSerializer):
    owner_username = serializers.CharField(source="owner.user.username", read_only=True)

    class Meta:
        model = Product
        fields = [
            "id",
            "name",
            "description",
            "price",
            "owner",
            "owner_username",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "owner_username", "created_at", "updated_at", "owner"]


class MerchantProfileSerializer(serializers.ModelSerializer):
    balance = serializers.SerializerMethodField()
    role = serializers.SerializerMethodField()

    def get_balance(self, obj):
        return MerchantBalance.objects.get(user=obj).balance

    def get_role(self, obj):
        return Role.objects.get(user=obj).type

    class Meta:
        model = User
        fields = [
            "id",
            "username",
            "email",
            "first_name",
            "last_name",
            "balance",
            "role",
        ]


class MerchantTransactionHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = MerchantTransactionHistory
        fields = ["id", "amount", "transaction_type", "created_at"]
        read_only_fields = ["id", "created_at"]

from rest_framework import serializers
from django.contrib.auth.models import User
from consumer.models import ConsumerBalance  
from .models import (
    AgentBalance,
    AgentTransactionHistory,
)  
from custom_auth.models import *


class AgentCashInSerializer(serializers.Serializer):
    consumer_email = serializers.EmailField()
    amount = serializers.DecimalField(max_digits=10, decimal_places=2)

    def validate_amount(self, value):
        if value <= 0:
            raise serializers.ValidationError("Amount must be a positive value.")
        return value

    def validate_consumer_email(self, value):
        try:
            consumer_user = User.objects.get(email=value)
            if not ConsumerBalance.objects.filter(user=consumer_user).exists():
                raise serializers.ValidationError(
                    "Consumer balance account not found for this email."
                )
        except User.DoesNotExist:
            raise serializers.ValidationError(
                "Consumer with this email does not exist."
            )
        return value

    def validate(self, data):
        return data


class AgentUtilityPaymentSerializer(serializers.Serializer):
    UTILITY_TYPES = [
        ("electricity", "Electricity"),
        ("water", "Water"),
        ("mobile_topup", "Mobile Top-up"),
    ]

    utility_type = serializers.ChoiceField(choices=UTILITY_TYPES)
    amount = serializers.DecimalField(max_digits=10, decimal_places=2)
    meter_number = serializers.CharField(
        max_length=50, required=False, allow_blank=True
    )
    phone_number = serializers.CharField(
        max_length=20, required=False, allow_blank=True
    )

    def validate_amount(self, value):
        if value <= 0:
            raise serializers.ValidationError("Amount must be a positive value.")
        return value

    def validate(self, data):
        if data["utility_type"] == "electricity" and not data.get("meter_number"):
            raise serializers.ValidationError(
                {"meter_number": "Meter number is required for electricity payments."}
            )
        if data["utility_type"] == "mobile_topup" and not data.get("phone_number"):
            raise serializers.ValidationError(
                {"phone_number": "Phone number is required for mobile top-up."}
            )
        return data


class AgentTransactionHistorySerializer(serializers.ModelSerializer):
    agent_username = serializers.CharField(source="agent.user.username", read_only=True)

    class Meta:
        model = AgentTransactionHistory
        fields = [
            "id",
            "agent",
            "amount",
            "transaction_type",
            "created_at",
            "agent_username",
        ]
        read_only_fields = ["id", "created_at"]


class AgentProfileSerializer(serializers.ModelSerializer):
    balance = serializers.SerializerMethodField()
    role = serializers.SerializerMethodField()

    def get_balance(self, obj):
        return AgentBalance.objects.get(user=obj).balance

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

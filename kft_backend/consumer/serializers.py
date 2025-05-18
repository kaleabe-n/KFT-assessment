from rest_framework import serializers
from rest_framework.serializers import SerializerMethodField
from django.contrib.auth.models import User
from .models import ConsumerBalance, TransactionHistory
from merchant.models import Product
from agent.models import AgentBalance # Import AgentBalance


class UserProfileSerializer(serializers.ModelSerializer):
    
    balance = SerializerMethodField()
    
    def get_balance(self,object):
        return ConsumerBalance.objects.get(user=object).balance
    

    class Meta:
        model = User
        fields = ["id", "username", "email", "first_name", "last_name", "balance"]


class TransactionHistorySerializer(serializers.ModelSerializer):
    
    consumer_username = serializers.CharField(
        source="consumer.user.username", read_only=True
    )

    class Meta:
        model = TransactionHistory
        fields = ["id", "consumer_username", "amount", "transaction_type", "created_at"]


class UtilityPaymentSerializer(serializers.Serializer):
    UTILITY_TYPES = [
        ("electricity", "Electricity"),
        ("water", "Water"),
        ("mobile_topup", "Mobile Top-up"),
        ("cashout", "Cash-out to Agent"),
    ]

    utility_type = serializers.ChoiceField(choices=UTILITY_TYPES)
    amount = serializers.DecimalField(max_digits=10, decimal_places=2)
    
    meter_number = serializers.CharField(
        max_length=50, required=False, allow_blank=True
    )
    phone_number = serializers.CharField(
        max_length=20, required=False, allow_blank=True
    )
    agent_email = serializers.EmailField(
        required=False, allow_blank=True
    )
    

    def validate(self, data):
        utility_type = data.get("utility_type")
        amount = data.get("amount")

        if amount is None or amount <= 0:
            raise serializers.ValidationError("Amount must be a positive value.")

        if utility_type == 'electricity' and not data.get('meter_number'):
            raise serializers.ValidationError({"meter_number": "Meter number is required for electricity payments."})
        if utility_type == 'mobile_topup' and not data.get('phone_number'):
             raise serializers.ValidationError({"phone_number": "Phone number is required for mobile top-up."})
        
        if utility_type == 'cashout':
            agent_email = data.get('agent_email')
            if not agent_email:
                raise serializers.ValidationError({"agent_email": "Agent email is required for cash-out."})
            try:
                agent_user = User.objects.get(email=agent_email)
                if not AgentBalance.objects.filter(user=agent_user).exists():
                    raise serializers.ValidationError({"agent_email": "Agent account not found for this email."})
            except User.DoesNotExist:
                raise serializers.ValidationError({"agent_email": "Agent with this email does not exist."})

        return data


class ProductPurchaseSerializer(serializers.Serializer):
    product_id = serializers.IntegerField()

    def validate_product_id(self, value):
        try:
            Product.objects.get(pk=value)
        except Product.DoesNotExist:
            raise serializers.ValidationError("Product not found.")
        return value

from rest_framework import generics, status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from django.db import transaction
from django.shortcuts import get_object_or_404
from merchant.models import Product, MerchantBalance, MerchantTransactionHistory
from agent.models import AgentBalance, AgentTransactionHistory
from django.contrib.auth.models import User

from .models import ConsumerBalance, TransactionHistory
from .serializers import (
    UserProfileSerializer,
    TransactionHistorySerializer,
    UtilityPaymentSerializer,
    ProductPurchaseSerializer,
)

# Create your views here.


class ConsumerProfileView(generics.RetrieveAPIView):
    """
    Retrieve the authenticated user's profile and balance.
    """

    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


class TransactionHistoryListView(generics.ListAPIView):
    """
    List transaction history for the authenticated user.
    """

    serializer_class = TransactionHistorySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):

        user = self.request.user
        consumer_balance = get_object_or_404(ConsumerBalance, user=user)
        return TransactionHistory.objects.filter(consumer=consumer_balance).order_by(
            "-created_at"
        )


class UtilityPaymentView(APIView):
    """
    Handle utility payments (electricity, water, mobile top-up).
    """

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = UtilityPaymentSerializer(data=request.data)
        if serializer.is_valid():
            utility_type = serializer.validated_data["utility_type"]
            amount = serializer.validated_data["amount"]
            phone = serializer.validated_data.get("phone_number")
            meter = serializer.validated_data.get("meter_number")
            agent_email = serializer.validated_data.get("agent_email")

            user = request.user

            try:
                with transaction.atomic():
                    consumer_balance = get_object_or_404(ConsumerBalance, user=user)

                    if consumer_balance.balance < amount:
                        return Response(
                            {"error": "Insufficient balance."},
                            status=status.HTTP_400_BAD_REQUEST,
                        )

                    if utility_type == "cashout":
                        agent_user = get_object_or_404(User, email=agent_email)
                        agent_balance_account = get_object_or_404(
                            AgentBalance, user=agent_user
                        )

                        consumer_balance.balance -= amount
                        consumer_balance.save()

                        agent_balance_account.balance += amount
                        agent_balance_account.save()

                        transaction_description = (
                            f"Payment for Cash-out to Agent: {agent_user.email}"
                        )
                        success_message = (
                            f"Cash-out to agent {agent_user.email} successful."
                        )

                        AgentTransactionHistory.objects.create(
                            agent=agent_balance_account,
                            amount=amount,
                            transaction_type=transaction_description,
                        )

                    else:
                        consumer_balance.balance -= amount
                        consumer_balance.save()
                        transaction_description = f"Payment: {utility_type.replace('_', ' ').title()} for {phone or meter}"
                        success_message = f"{utility_type.replace('_', ' ').title()} payment successful."

                    
                    TransactionHistory.objects.create(
                        consumer=consumer_balance,
                        amount=amount,
                        transaction_type=transaction_description,
                    )

                return Response(
                    {
                        "message": success_message,
                        "current_balance": consumer_balance.balance,
                    },
                    status=status.HTTP_200_OK,
                )

            except ConsumerBalance.DoesNotExist:
                return Response(
                    {"error": "Consumer not found for this user."},
                    status=status.HTTP_404_NOT_FOUND,
                )
            except (
                User.DoesNotExist
            ): 
                return Response(
                    {"error": "Agent user not found."}, status=status.HTTP_404_NOT_FOUND
                )
            except AgentBalance.DoesNotExist:
                return Response(
                    {"error": "Agent account not found."},
                    status=status.HTTP_404_NOT_FOUND,
                )
            except Exception as e:
                
                return Response(
                    {"error": "An error occurred during the payment process."},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ProductPurchaseView(APIView):
    """
    Handle consumer purchasing a product from a merchant.
    """

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = ProductPurchaseSerializer(data=request.data)
        if serializer.is_valid():
            product_id = serializer.validated_data["product_id"]
            

            consumer_user = request.user

            try:
                with transaction.atomic():
                    product = get_object_or_404(Product, pk=product_id)
                    consumer_balance = get_object_or_404(
                        ConsumerBalance, user=consumer_user
                    )
                    merchant_balance_account = product.owner
                    total_price = product.price

                    if consumer_balance.balance < total_price:
                        return Response(
                            {"error": "Insufficient balance to purchase this product."},
                            status=status.HTTP_400_BAD_REQUEST,
                        )

                    consumer_balance.balance -= total_price
                    consumer_balance.save()

                    merchant_balance_account.balance += total_price
                    merchant_balance_account.save()

                    TransactionHistory.objects.create(
                        consumer=consumer_balance,
                        amount=total_price,
                        transaction_type=f"Purchase: {product.name} from {merchant_balance_account.user.username}",
                    )

                    MerchantTransactionHistory.objects.create(
                        consumer=merchant_balance_account,
                        amount=total_price,
                        transaction_type=f"Purchase: {product.name} from {consumer_user.username}",
                    )

                return Response(
                    {
                        "message": f"Successfully purchased '{product.name}'.",
                        "consumer_new_balance": consumer_balance.balance,
                    },
                    status=status.HTTP_200_OK,
                )
            except (
                Product.DoesNotExist
            ): 
                return Response(
                    {"error": "Product not found."}, status=status.HTTP_404_NOT_FOUND
                )
            except ConsumerBalance.DoesNotExist:
                return Response(
                    {"error": "Consumer balance not found for this user."},
                    status=status.HTTP_404_NOT_FOUND,
                )
            except (
                MerchantBalance.DoesNotExist
            ): 
                return Response(
                    {"error": "Merchant account for product owner not found."},
                    status=status.HTTP_404_NOT_FOUND,
                )
            except Exception as e:
                
                return Response(
                    {"error": f"An error occurred: {str(e)}"},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

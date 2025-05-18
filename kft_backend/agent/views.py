from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions, generics
from django.db import transaction
from django.shortcuts import get_object_or_404
from django.contrib.auth.models import User
from django.http import Http404


from .models import AgentBalance, AgentTransactionHistory
from consumer.models import (
    ConsumerBalance,
    TransactionHistory as ConsumerTransactionHistory,
)
from custom_auth.models import Role

from .serializers import (
    AgentCashInSerializer,
    AgentUtilityPaymentSerializer,
    AgentTransactionHistorySerializer,
    AgentProfileSerializer,
)

# Create your views here.


class AgentCashInView(APIView):
    """
    Allows an authenticated agent to perform a cash-in transaction,
    transferring funds from their balance to a consumer's balance.
    """

    permission_classes = [
        permissions.IsAuthenticated
    ]  

    def post(self, request, *args, **kwargs):
        if not Role.objects.filter(user=request.user, type="agent").exists():
            return Response(
                {"error": "You are not authorized to perform this action."},
                status=status.HTTP_403_FORBIDDEN,
            )

        serializer = AgentCashInSerializer(data=request.data)
        if serializer.is_valid():
            consumer_email = serializer.validated_data["consumer_email"]
            amount = serializer.validated_data["amount"]

            agent_user = request.user

            try:
                with transaction.atomic():
                    agent_balance_account = get_object_or_404(
                        AgentBalance, user=agent_user
                    )

                    if agent_balance_account.balance < amount:
                        return Response(
                            {"error": "Insufficient agent balance."},
                            status=status.HTTP_400_BAD_REQUEST,
                        )

                    consumer_user_obj = get_object_or_404(User, email=consumer_email)
                    consumer_balance_account = get_object_or_404(
                        ConsumerBalance, user=consumer_user_obj
                    )

                    agent_balance_account.balance -= amount
                    agent_balance_account.save()

                    consumer_balance_account.balance += amount
                    consumer_balance_account.save()

                    AgentTransactionHistory.objects.create(
                        agent=agent_balance_account,
                        amount=amount,
                        transaction_type=f"Cash-in to Consumer: {consumer_email}",
                    )

                    
                    ConsumerTransactionHistory.objects.create(
                        consumer=consumer_balance_account,
                        amount=amount,
                        transaction_type=f"Cash-in from Agent: {agent_user.email}",
                    )

                return Response(
                    {
                        "message": f"Successfully cashed-in {amount} to {consumer_email}.",
                        "agent_new_balance": agent_balance_account.balance,
                    },
                    status=status.HTTP_200_OK,
                )

            except (
                AgentBalance.DoesNotExist,
                ConsumerBalance.DoesNotExist,
                User.DoesNotExist,
            ) as e:
                
                return Response({"error": str(e)}, status=status.HTTP_404_NOT_FOUND)
            except Exception as e:
                
                return Response(
                    {"error": "An unexpected error occurred."},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class AgentProfileView(generics.RetrieveAPIView):
    """
    Retrieve the authenticated agent's profile and balance.
    """

    serializer_class = AgentProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        
        if not Role.objects.filter(user=self.request.user, type="agent").exists():
            raise Http404("Agent profile not found or user is not an agent.")
        return self.request.user


class AgentTransactionHistoryView(generics.ListAPIView):
    """
    Provides a list of an authenticated agent's transaction history.
    """

    serializer_class = AgentTransactionHistorySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        agent_user = self.request.user
        if not Role.objects.filter(user=agent_user, type="agent").exists():
            return AgentTransactionHistory.objects.none() # Return empty if not an agent

        try:
            agent_balance_instance = AgentBalance.objects.get(user=agent_user)
            return AgentTransactionHistory.objects.filter(
                agent=agent_balance_instance
            ).order_by("-created_at")
        except AgentBalance.DoesNotExist:
            return AgentTransactionHistory.objects.none()
        
class AgentUtilityPaymentView(APIView):
    """
    Allows an authenticated agent to pay for utilities (electricity, water, mobile top-up)
    using their agent balance.
    """

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        if not Role.objects.filter(user=request.user, type="agent").exists():
            return Response(
                {"error": "You are not authorized to perform this action."},
                status=status.HTTP_403_FORBIDDEN,
            )

        serializer = AgentUtilityPaymentSerializer(data=request.data)
        if serializer.is_valid():
            utility_type = serializer.validated_data["utility_type"]
            amount = serializer.validated_data["amount"]
            meter_number = serializer.validated_data.get("meter_number")
            phone_number = serializer.validated_data.get("phone_number")

            agent_user = request.user

            try:
                with transaction.atomic():
                    agent_balance_account = get_object_or_404(
                        AgentBalance, user=agent_user
                    )
                    if agent_balance_account.balance < amount:
                        return Response(
                            {"error": "Insufficient agent balance."},
                            status=status.HTTP_400_BAD_REQUEST,
                        )

                    agent_balance_account.balance -= amount
                    agent_balance_account.save()

                    transaction_description = f"Utility Payment: {utility_type.replace('_', ' ').title()} for {phone_number or meter_number}"

                    AgentTransactionHistory.objects.create(
                        agent=agent_balance_account,
                        amount=amount,
                        transaction_type=transaction_description,
                    )

                return Response(
                    {
                        "message": f"{utility_type.replace('_', ' ').title()} payment successful.",
                        "agent_new_balance": agent_balance_account.balance,
                    },
                    status=status.HTTP_200_OK,
                )

            except AgentBalance.DoesNotExist:
                return Response(
                    {"error": "Agent balance account not found."},
                    status=status.HTTP_404_NOT_FOUND,
                )
            except Exception as e:
                return Response(
                    {"error": "An unexpected error occurred during utility payment."},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

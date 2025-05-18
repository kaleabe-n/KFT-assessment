from django.urls import path
from .views import (
    AgentCashInView,
    AgentUtilityPaymentView,
    AgentTransactionHistoryView,
    AgentProfileView,
)

app_name = "agent"

urlpatterns = [
    path("cash-in/", AgentCashInView.as_view(), name="agent_cash_in"),
    path("pay-utility/", AgentUtilityPaymentView.as_view(), name="agent_pay_utility"),
    path(
        "transactions/",
        AgentTransactionHistoryView.as_view(),
        name="agent_transactions",
    ),
    path("profile/", AgentProfileView.as_view(), name="agent_profile"),
]

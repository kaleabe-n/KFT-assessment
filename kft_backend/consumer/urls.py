from django.urls import path
from .views import ConsumerProfileView, TransactionHistoryListView, UtilityPaymentView, ProductPurchaseView


app_name = "consumer"

urlpatterns = [
    path("profile/", ConsumerProfileView.as_view(), name="consumer_profile"),
    path(
        "transactions/",
        TransactionHistoryListView.as_view(),
        name="transaction_history",
    ),
    path("pay-utility/", UtilityPaymentView.as_view(), name="utility_payment"),
    path("buy-product/", ProductPurchaseView.as_view(), name="buy_product"),
]

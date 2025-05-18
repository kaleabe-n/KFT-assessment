from django.urls import path
from .views import (
    ProductListCreateView,
    ProductDetailView,
    MerchantProfileView,
    MerchantTransactionHistoryView,
    MerchantOwnedProductListView,
)

app_name = "merchant"

urlpatterns = [
    path("profile/", MerchantProfileView.as_view(), name="merchant_profile"),
    path(
        "transactions/",
        MerchantTransactionHistoryView.as_view(),
        name="merchant_transactions",
    ),
    path(
        "products/", ProductListCreateView.as_view(), name="product_list_all_and_create"
    ),
    path(
        "my-products/",
        MerchantOwnedProductListView.as_view(),
        name="merchant_owned_products",
    ),
    path("products/<int:pk>/", ProductDetailView.as_view(), name="product_detail"),
]

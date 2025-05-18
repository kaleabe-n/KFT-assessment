from rest_framework import generics, permissions
from django.shortcuts import get_object_or_404
from django.http import Http404
from .models import Product, MerchantBalance, MerchantTransactionHistory
from .serializers import (
    ProductListSerializer,
    ProductSerializer,
    MerchantProfileSerializer,
    MerchantTransactionHistorySerializer,
)
from custom_auth.models import Role
from .permissions import IsProductOwner

# Create your views here.


class MerchantProfileView(generics.RetrieveAPIView):
    """
    Retrieve the authenticated merchant's profile and balance.
    """

    serializer_class = MerchantProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        if not Role.objects.filter(user=self.request.user, type="merchant").exists():
            raise Http404("Merchant profile not found or user is not a merchant.")
        return self.request.user


class MerchantTransactionHistoryView(generics.ListAPIView):
    """
    Provides a list of an authenticated merchant's transaction history.
    """

    serializer_class = MerchantTransactionHistorySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        merchant_user = self.request.user
        if not Role.objects.filter(user=merchant_user, type="merchant").exists():
            return MerchantTransactionHistory.objects.none()

        try:
            merchant_balance = MerchantBalance.objects.get(user=merchant_user)
            return MerchantTransactionHistory.objects.filter(
                merchant=merchant_balance
            ).order_by("-created_at")
        except MerchantBalance.DoesNotExist:
            return MerchantTransactionHistory.objects.none()


class MerchantOwnedProductListView(generics.ListAPIView):
    """
    Provides a list of products owned by the authenticated merchant.
    """

    serializer_class = ProductListSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if not Role.objects.filter(user=user, type="merchant").exists():
            return Product.objects.none()

        try:
            merchant_balance = MerchantBalance.objects.get(user=user)
            return Product.objects.filter(owner=merchant_balance).order_by(
                "-created_at"
            )
        except MerchantBalance.DoesNotExist:
            return Product.objects.none()


class ProductListCreateView(generics.ListCreateAPIView):
    """
    Provides a list of ALL available merchant products (e.g., for consumers or general catalog).
    Allows authenticated merchants to create new products.
    """

    queryset = Product.objects.all().order_by("-created_at")
    permission_classes = [permissions.IsAuthenticated]

    def get_serializer_class(self):
        if self.request.method == "POST":
            return ProductSerializer
        return ProductListSerializer

    def perform_create(self, serializer):
        if not Role.objects.filter(user=self.request.user, type="merchant").exists():
            from rest_framework.exceptions import PermissionDenied

            raise PermissionDenied("Only merchants can create products.")

        merchant_balance = get_object_or_404(MerchantBalance, user=self.request.user)
        serializer.save(owner=merchant_balance)


class ProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Retrieve, update or delete a product instance.
    Only the merchant who owns the product can update or delete it.
    """

    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated, IsProductOwner]

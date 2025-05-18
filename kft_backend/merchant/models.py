from django.db import models
from django.contrib.auth.models import User

# Create your models here.


class MerchantBalance(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    balance = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.user.username

    class Meta:
        db_table = "merchant"
        verbose_name = "Merchant"
        verbose_name_plural = "Merchants"
        ordering = ["-created_at"]


class Product(models.Model):
    name = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    description = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    owner = models.ForeignKey(MerchantBalance, on_delete=models.CASCADE)

    def __str__(self):
        return self.name

    class Meta:
        db_table = "product"
        verbose_name = "Product"
        verbose_name_plural = "Products"
        ordering = ["-created_at"]


class MerchantTransactionHistory(models.Model):
    merchant = models.ForeignKey(MerchantBalance, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    transaction_type = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.merchant.user.username

    class Meta:
        db_table = "merchant_transaction_history"
        verbose_name = "Merchant Transaction History"
        verbose_name_plural = "Merchant Transaction Histories"
        ordering = ["-created_at"]

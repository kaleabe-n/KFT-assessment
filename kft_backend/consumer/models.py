from django.db import models
from django.contrib.auth.models import User

# Create your models here.


class ConsumerBalance(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    balance = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.user.username

    class Meta:
        db_table = "consumer"
        verbose_name = "Consumer"
        verbose_name_plural = "Consumers"
        ordering = ["-created_at"]


class TransactionHistory(models.Model):
    consumer = models.ForeignKey(ConsumerBalance, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    transaction_type = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.consumer.user.username

    class Meta:
        db_table = "transaction_history"
        verbose_name = "Transaction History"
        verbose_name_plural = "Transaction Histories"
        ordering = ["-created_at"]

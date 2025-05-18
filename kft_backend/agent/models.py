from django.db import models
from django.contrib.auth.models import User

# Create your models here.


class AgentBalance(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    balance = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.user.username

    class Meta:
        db_table = "agent"
        verbose_name = "Agent"
        verbose_name_plural = "Agents"
        ordering = ["-created_at"]


class AgentTransactionHistory(models.Model):
    agent = models.ForeignKey(AgentBalance, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    transaction_type = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.agent.user.username

    class Meta:
        db_table = "agent_transaction_history"
        verbose_name = "Agent Transaction History"
        verbose_name_plural = "Agent Transaction Histories"
        ordering = ["-created_at"]

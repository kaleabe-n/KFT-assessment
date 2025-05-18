from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User


ROLE_TYPES = (
    ("admin", "Admin"),
    ("merchant", "Merchant"),
    ("consumer", "Consumer"),
    ("agent", "Agent"),
)


class Role(models.Model):
    type = models.CharField(max_length=20, choices=ROLE_TYPES)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="roles")

    class Meta:
        verbose_name = "Role"
        verbose_name_plural = "Roles"

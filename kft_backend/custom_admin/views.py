from django.shortcuts import render

from rest_framework import generics, permissions
from django.contrib.auth import get_user_model

# Create your views here.

User = get_user_model()


class UserDeleteView(generics.DestroyAPIView):
    """
    Allows admin users to delete any user account.
    Accessible via DELETE request to /api/admin/users/<user_id>/delete/
    """

    queryset = User.objects.all()
    permission_classes = [permissions.IsAdminUser]
    lookup_field = "pk" 

from django.urls import path
from .views import UserDeleteView

app_name = "kft_admin_api"

urlpatterns = [
    path("users/<int:pk>/delete/", UserDeleteView.as_view(), name="admin_user_delete"),
]

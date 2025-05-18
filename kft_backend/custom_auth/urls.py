from django.urls import path
from .views import (
    AuthView,
    UserDetailView,
    ChangePasswordView,
    ForgotPasswordView,
    OTPVerificationView,
    LoginView,
    VerifyPasswordResetOTPView,
    SetNewPasswordView,
)

app_name = "custom_auth"

urlpatterns = [
    path("users/", AuthView.as_view(), name="user_list_or_initiate_registration"),
    path("token/", LoginView.as_view(), name="token_obtain_pair"),
    path("users/verify-otp/", OTPVerificationView.as_view(), name="verify_otp"),
    path("users/<int:pk>/", UserDetailView.as_view(), name="user_detail_update_delete"),
    path(
        "users/change-password/", ChangePasswordView.as_view(), name="change_password"
    ),
    path(
        "users/forgot-password/", ForgotPasswordView.as_view(), name="forgot_password"
    ),
    path(
        "users/verify-password-reset-otp/",
        VerifyPasswordResetOTPView.as_view(),
        name="verify_password_reset_otp",
    ),
    path(
        "users/set-new-password/",
        SetNewPasswordView.as_view(),
        name="set_new_password_after_otp",
    ),
]

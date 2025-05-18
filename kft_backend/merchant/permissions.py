from rest_framework import permissions


class IsProductOwner(permissions.BasePermission):
    """
    Custom permission to only allow owners of a product to edit or delete it.
    Assumes the product's owner is linked to a MerchantBalance, which is linked to a User.
    """

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.owner.user == request.user

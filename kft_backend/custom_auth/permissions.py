from rest_framework import permissions


class IsAdminOrOwner(permissions.BasePermission):
    """
    Custom permission to only allow admins or owners of an object to access/edit/delete it.
    Assumes the view has a `self.get_object()` method.
    """

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            is_admin = (
                request.user.is_staff
                or request.user.roles.filter(type="admin").exists()
            )
            return is_admin or obj == request.user

        
        is_admin = (
            request.user.is_staff or request.user.roles.filter(type="admin").exists()
        )
        return is_admin or obj == request.user


class IsAdminUser(permissions.BasePermission):
    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and (
                request.user.is_staff
                or request.user.roles.filter(type="admin").exists()
            )
        )

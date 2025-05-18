'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { adminAuthService, AdminUser } from '@/services/authService';

export default function AdminDashboardPage() {
    const router = useRouter();
    const [users, setUsers] = useState<AdminUser[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [currentUser, setCurrentUser] = useState<AdminUser | null>(null);

    const fetchAllUsers = async () => {
        setIsLoading(true);
        setError(null);
        try {
            const fetchedUsers = await adminAuthService.getAllUsers();
            setUsers(fetchedUsers);
        } catch (err: any) {
            setError(err.message || "Failed to fetch users.");
            if (String(err.message).includes('401') || String(err.message).includes('token') || err.message === 'Not authenticated') {
                 adminAuthService.logout();
                 router.push('/auth/login');
            }
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        const user = adminAuthService.getUser();
        setCurrentUser(user);
        if (!adminAuthService.isAuthenticated()) {
            router.push('/auth/login');
        } else {
            fetchAllUsers();
        }
    }, [router]);

    const handleDeleteUser = async (userId: number) => {
        if (currentUser && userId === currentUser.id) {
            alert("You cannot delete your own account from this interface.");
            return;
        }
        if (window.confirm("Are you sure you want to delete this user? This action cannot be undone.")) {
            setError(null);
            try {
                await adminAuthService.deleteUser(userId);
                setUsers(prevUsers => prevUsers.filter(user => user.id !== userId));
                alert("User deleted successfully.");
            } catch (err: any) {
                const errorMessage = err.message || "Failed to delete user.";
                setError(errorMessage);
                alert(`Error deleting user: ${errorMessage}`);
            }
        }
    };

    const handleLogout = () => {
        adminAuthService.logout();
        router.push('/auth/login');
    };

    if (isLoading && users.length === 0) {
        return <div className="min-h-screen flex items-center justify-center bg-gray-100"><p className="text-gray-700">Loading dashboard...</p></div>;
    }

    return (
        <div className="min-h-screen bg-gray-100 p-4 md:p-8">
            <div className="container mx-auto bg-white shadow-xl rounded-lg p-6">
                <div className="flex justify-between items-center mb-8">
                    <h1 className="text-3xl font-bold text-gray-800">Admin Dashboard - User Management</h1>
                    <div>
                        {currentUser && <span className="mr-4 text-gray-700">Welcome, {currentUser.username}!</span>}
                        <button
                            onClick={handleLogout}
                            className="px-4 py-2 bg-red-500 text-white rounded-md hover:bg-red-600 transition duration-150"
                        >
                            Logout
                        </button>
                    </div>
                </div>

                {error && <p className="text-red-500 bg-red-100 p-3 rounded-md mb-4">{error}</p>}
                
                <div className="overflow-x-auto">
                    <table className="min-w-full leading-normal">
                        <thead>
                            <tr className="bg-gray-200 text-left text-gray-600 uppercase text-sm">
                                <th className="px-5 py-3 border-b-2 border-gray-300">ID</th>
                                <th className="px-5 py-3 border-b-2 border-gray-300">Username</th>
                                <th className="px-5 py-3 border-b-2 border-gray-300">Email</th>
                                <th className="px-5 py-3 border-b-2 border-gray-300">Role(s)</th>
                                <th className="px-5 py-3 border-b-2 border-gray-300 text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="text-gray-700">
                            {users.map((user) => (
                                <tr key={user.id} className="border-b border-gray-200 hover:bg-gray-50">
                                    <td className="px-5 py-4">{user.id}</td>
                                    <td className="px-5 py-4">{user.username}</td>
                                    <td className="px-5 py-4">{user.email}</td>
                                    <td className="px-5 py-4">
                                        {user.is_superuser ? 'Superuser ' : ''}{user.is_staff ? 'Staff ' : ''}{user.role || ''}{(!user.is_superuser && !user.is_staff && !user.role) ? 'User' : ''}
                                    </td>
                                    <td className="px-5 py-4 text-center">
                                        <button onClick={() => handleDeleteUser(user.id)} disabled={currentUser?.id === user.id} className="text-red-600 hover:text-red-900 font-medium disabled:text-gray-400 disabled:cursor-not-allowed">Delete</button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}
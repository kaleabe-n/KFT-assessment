const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000';

export interface AdminUser {
    id: number;
    username: string;
    email: string;
    first_name?: string;
    last_name?: string;
    is_staff?: boolean;
    is_superuser?: boolean;
    role?: string; 
}

interface AuthResponse {
    access?: string;
    refresh?: string;
    user?: AdminUser;
    message?: string;
    detail?: string;
    [key: string]: any;
}

async function request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const url = `${API_BASE_URL}${endpoint}`;
    const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        ...(options.headers ? options.headers as Record<string, string> : {}),
    };

    const token = adminAuthService.getAccessToken(); 
    if (token && !(options.headers && (options.headers as Record<string, string>)['Authorization'])) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    const config: RequestInit = { ...options, headers };

    try {
        const response = await fetch(url, config);

        if (response.status === 204) { 
            return undefined as T; 
        }

        const data: T & { detail?: string; [key: string]: any } = await response.json();

        if (!response.ok) {
            let errorMessage = `HTTP error! status: ${response.status}`;
            if (data) {
                if (data.detail) errorMessage = data.detail;
                else {
                    const errorValues = Object.values(data).filter(value => Array.isArray(value) || typeof value === 'string');
                    if (errorValues.length > 0) errorMessage = errorValues.flat().join(' ');
                }
            }
            throw new Error(errorMessage);
        }
        return data;
    } catch (error) {
        console.error('API Request Error:', error);
        if (error instanceof Error) throw error;
        throw new Error('An unknown error occurred during the API request.');
    }
}

export const adminAuthService = {
    login: async (username: string, password_1: string): Promise<AuthResponse> => {
        const data = await request<AuthResponse>('/api/auth/token/', {
            method: 'POST',
            body: JSON.stringify({ username, password: password_1 }),
        });
        if (data.access && data.refresh && data.user) {
            adminAuthService.storeTokens(data.access, data.refresh);
            adminAuthService.storeUser(data.user);
        }
        return data;
    },

    storeTokens: (accessToken: string, refreshToken: string): void => {
        if (typeof window !== 'undefined') {
            localStorage.setItem('adminAccessToken', accessToken);
            localStorage.setItem('adminRefreshToken', refreshToken);
        }
    },

    storeUser: (userData: AdminUser): void => {
        if (typeof window !== 'undefined') localStorage.setItem('adminUser', JSON.stringify(userData));
    },

    getAccessToken: (): string | null => {
        return typeof window !== 'undefined' ? localStorage.getItem('adminAccessToken') : null;
    },

    getUser: (): AdminUser | null => {
        if (typeof window === 'undefined') return null;
        const user = localStorage.getItem('adminUser');
        return user ? JSON.parse(user) : null;
    },

    logout: (): void => {
        if (typeof window !== 'undefined') {
            localStorage.removeItem('adminAccessToken');
            localStorage.removeItem('adminRefreshToken');
            localStorage.removeItem('adminUser');
            console.log('Admin logged out');
        }
    },

    isAuthenticated: (): boolean => {
        if (typeof window === 'undefined') return false;
        const user = adminAuthService.getUser();
        return !!adminAuthService.getAccessToken() && !!user;
    },

    getAllUsers: async (): Promise<AdminUser[]> => {
        return request<AdminUser[]>('/api/auth/users/');
    },

    deleteUser: async (userId: number): Promise<void> => {
        await request<void>(`/api/kft_admin/users/${userId}/delete/`, {
            method: 'DELETE',
        });
    },
};
const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000';

interface User {
    id: number;
    username: string;
    email: string;
    first_name?: string;
    last_name?: string;
    role?: string;
}

export interface Product {
    id: number;
    name: string;
    description: string;
    price: string;
    owner?: number;
    owner_username?: string;
}

export interface MerchantTransaction {
    id: number;
    amount: string; // Keep as string to match backend DecimalField
    transaction_type: string;
    created_at: string; // ISO date string
    // Add other fields if your serializer returns more
}

export interface MerchantProfile extends User {
    balance: string; // Balance is likely a string from the backend (DecimalField)
    // role is already in User, but explicitly mentioning it if it's key for profile
    role: string;
}

interface AuthResponse {
    access?: string;
    refresh?: string;
    user?: User;
    message?: string;
    detail?: string;
    [key: string]: any;
}

interface SignupData {
    username: string;
    email: string;
    password: string;
    first_name?: string;
    last_name?: string;
}

async function request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const url = `${API_BASE_URL}${endpoint}`;
    const headers = {
        'Content-Type': 'application/json',
        ...options.headers,
    };

    const config: RequestInit = {
        ...options,
        headers,
    };

    try {
        const response = await fetch(url, config);
        const data: T & { detail?: string; [key: string]: any } = await response.json();

        if (!response.ok) {
            let errorMessage = `HTTP error! status: ${response.status}`;
            if (data) {
                if (data.detail) {
                    errorMessage = data.detail;
                } else {
                    const errorValues = Object.values(data).filter(value => Array.isArray(value) || typeof value === 'string');
                    if (errorValues.length > 0) {
                        errorMessage = errorValues.flat().join(' ');
                    }
                }
            }
            throw new Error(errorMessage);
        }
        return data;
    } catch (error) {
        console.error('API Request Error:', error);
        if (error instanceof Error) {
            throw error;
        }
        throw new Error('An unknown error occurred during the API request.');
    }
}

export const authService = {
    signup: async (userData: SignupData): Promise<AuthResponse> => {
        const payload = { ...userData, role_type: 'merchant' };
        return request<AuthResponse>('/api/auth/users/', {
            method: 'POST',
            body: JSON.stringify(payload),
        });
    },

    verifyOtp: async (email: string, otp_code: string): Promise<AuthResponse> => {
        const data = await request<AuthResponse>('/api/auth/users/verify-otp/', {
            method: 'POST',
            body: JSON.stringify({ email, otp_code }),
        });
        if (data.access && data.refresh && data.user) {
            authService.storeTokens(data.access, data.refresh);
            authService.storeUser(data.user);
        }
        return data;
    },

    login: async (username: string, password_1: string): Promise<AuthResponse> => {
        const data = await request<AuthResponse>('/api/auth/token/', {
            method: 'POST',
            body: JSON.stringify({ username, password: password_1 }),
        });
        if (data.access && data.refresh && data.user) {
            authService.storeTokens(data.access, data.refresh);
            authService.storeUser(data.user);
        }
        return data;
    },

    storeTokens: (accessToken: string, refreshToken: string): void => {
        if (typeof window !== 'undefined') {
            localStorage.setItem('accessToken', accessToken);
            localStorage.setItem('refreshToken', refreshToken);
        }
    },

    storeUser: (userData: User): void => {
        if (typeof window !== 'undefined') {
            localStorage.setItem('user', JSON.stringify(userData));
        }
    },

    getAccessToken: (): string | null => {
        if (typeof window !== 'undefined') {
            return localStorage.getItem('accessToken');
        }
        return null;
    },

    getRefreshToken: (): string | null => {
        if (typeof window !== 'undefined') {
            return localStorage.getItem('refreshToken');
        }
        return null;
    },

    getUser: (): User | null => {
        if (typeof window !== 'undefined') {
            const user = localStorage.getItem('user');
            return user ? JSON.parse(user) : null;
        }
        return null;
    },

    logout: (): void => {
        if (typeof window !== 'undefined') {
            localStorage.removeItem('accessToken');
            localStorage.removeItem('refreshToken');
            localStorage.removeItem('user');
            console.log('User logged out');
        }
    },

    isAuthenticated: (): boolean => {
        if (typeof window !== 'undefined') {
            return !!authService.getAccessToken();
        }
        return false;
    },

    getMerchantProducts: async (): Promise<Product[]> => {
        const token = authService.getAccessToken();
        if (!token) throw new Error('Not authenticated');
        return request<Product[]>('/api/merchant/my-products/', {
            headers: { 'Authorization': `Bearer ${token}` },
        });
    },

    addProduct: async (productData: Omit<Product, 'id' | 'owner' | 'owner_username'>): Promise<Product> => {
        const token = authService.getAccessToken();
        if (!token) throw new Error('Not authenticated');
        return request<Product>('/api/merchant/products/', {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${token}` },
            body: JSON.stringify(productData),
        });
    },

    updateProduct: async (productId: number, productData: Partial<Omit<Product, 'id' | 'owner' | 'owner_username'>>): Promise<Product> => {
        const token = authService.getAccessToken();
        if (!token) throw new Error('Not authenticated');
        return request<Product>(`/api/merchant/products/${productId}/`, {
            method: 'PUT',
            headers: { 'Authorization': `Bearer ${token}` },
            body: JSON.stringify(productData),
        });
    },

    deleteProduct: async (productId: number): Promise<void> => {
        const token = authService.getAccessToken();
        if (!token) throw new Error('Not authenticated');
        const url = `${API_BASE_URL}/api/merchant/products/${productId}/`;
        const response = await fetch(url, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json',
            },
        });
        if (!response.ok) {
            let errorMessage = `HTTP error! status: ${response.status}`;
            try {
                const data = await response.json();
                if (data && data.detail) errorMessage = data.detail;
                else if (data) errorMessage = Object.values(data).flat().join(' ');
            } catch (e) { }
            throw new Error(errorMessage);
        }
    },
    
    getMerchantTransactions: async (): Promise<MerchantTransaction[]> => {
        const token = authService.getAccessToken();
        if (!token) throw new Error('Not authenticated');
        return request<MerchantTransaction[]>('/api/merchant/transactions/', { // Endpoint for merchant transactions
            headers: { 'Authorization': `Bearer ${token}` },
        });
    },

    getMerchantProfile: async (): Promise<MerchantProfile> => {
        const token = authService.getAccessToken();
        if (!token) throw new Error('Not authenticated');
        return request<MerchantProfile>('/api/merchant/profile/', {
            headers: { 'Authorization': `Bearer ${token}` },
        });
    }

};

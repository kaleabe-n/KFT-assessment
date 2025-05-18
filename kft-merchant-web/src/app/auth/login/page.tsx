'use client';

import { useState, FormEvent } from 'react';
import { useRouter } from 'next/navigation';
import { authService } from '@/services/authService'; 

export default function LoginPage() {
    const router = useRouter();
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState<string | null>(null);
    const [isLoading, setIsLoading] = useState(false);

    const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
        event.preventDefault();
        setError(null);
        setIsLoading(true);

        try {
            await authService.login(username, password);
            router.push('/dashboard'); 
        } catch (err: any) {
            setError(err.message || 'Login failed. Please check your credentials.');
        } finally {
            setIsLoading(false);
        }
    };

    const inputStyle = "mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm";
    const labelStyle = "block text-sm font-medium text-gray-700";

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
            <div className="max-w-md w-full space-y-8 p-10 bg-white shadow-lg rounded-lg">
                <div>
                    <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
                        Merchant Log In
                    </h2>
                </div>
                <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
                    <div><label htmlFor="username" className={labelStyle}>Username</label><input id="username" name="username" type="text" required value={username} onChange={(e) => setUsername(e.target.value)} className={inputStyle} /></div>
                    <div><label htmlFor="password" className={labelStyle}>Password</label><input id="password" name="password" type="password" required value={password} onChange={(e) => setPassword(e.target.value)} className={inputStyle} /></div>

                    {error && <p className="text-red-500 text-sm">{error}</p>}

                  
                    <div>
                        <button
                            type="submit"
                            disabled={isLoading}
                            className="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:bg-indigo-300"
                        >
                            {isLoading ? 'Logging in...' : 'Log in'}
                        </button>
                    </div>
                </form>
                <p className="mt-2 text-center text-sm text-gray-600">
                    Don&apos;t have an account?{' '}
                    <a href="/auth/signup" className="font-medium text-indigo-600 hover:text-indigo-500">
                        Sign up
                    </a>
                </p>
            </div>
        </div>
    );
}
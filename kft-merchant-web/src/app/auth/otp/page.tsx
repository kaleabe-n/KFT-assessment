'use client';

import { useState, FormEvent, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { authService } from '@/services/authService'; 

export default function OtpPage() {
    const router = useRouter();
    const [otp, setOtp] = useState('');
    const [email, setEmail] = useState('');
    const [error, setError] = useState<string | null>(null);
    const [message, setMessage] = useState<string | null>(null);
    const [isLoading, setIsLoading] = useState(false);

    useEffect(() => {
        if (typeof window !== 'undefined') {
            const storedEmail = localStorage.getItem('signupEmail');
            if (storedEmail) {
                setEmail(storedEmail);
            } else {
                setError("Email not found for OTP verification. Please start signup again.");
            }
        }
    }, []);

    const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
        event.preventDefault();
        setError(null);
        setMessage(null);
        setIsLoading(true);

        if (!email) {
            setError("Email is missing. Cannot verify OTP.");
            setIsLoading(false);
            return;
        }

        try {
            const response = await authService.verifyOtp(email, otp);
            setMessage(response.message || 'OTP Verified! Account created and logged in.');
            if (typeof window !== 'undefined') {
                localStorage.removeItem('signupEmail');
            }
            router.push('/dashboard'); 
        } catch (err: any) {
            setError(err.message || 'OTP verification failed. Please try again.');
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
                        Verify Your Email
                    </h2>
                    <p className="mt-2 text-center text-sm text-gray-600">
                        Enter the OTP sent to {email || 'your email address'}.
                    </p>
                </div>
                <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
                    <div><label htmlFor="otp" className={labelStyle}>OTP Code</label><input id="otp" name="otp" type="text" required maxLength={6} value={otp} onChange={(e) => setOtp(e.target.value)} className={inputStyle} /></div>

                    {error && <p className="text-red-500 text-sm">{error}</p>}
                    {message && <p className="text-green-500 text-sm">{message}</p>}

                    <div>
                        <button type="submit" disabled={isLoading || !email} className="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:bg-indigo-300">
                            {isLoading ? 'Verifying...' : 'Verify OTP'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
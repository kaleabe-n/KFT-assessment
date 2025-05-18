'use client';

import { useState, FormEvent } from 'react';
import { useRouter } from 'next/navigation';
import { authService } from '@/services/authService'; 

export default function SignupPage() {
    const router = useRouter();
    const [username, setUsername] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword1] = useState('');
    const [password_2, setPassword2] = useState('');
    const [firstName, setFirstName] = useState('');
    const [lastName, setLastName] = useState('');
    const [error, setError] = useState<string | null>(null);
    const [message, setMessage] = useState<string | null>(null);
    const [isLoading, setIsLoading] = useState(false);

    const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
        event.preventDefault();
        setError(null);
        setMessage(null);
        setIsLoading(true);

        if (password !== password_2) {
            setError('Passwords do not match.');
            setIsLoading(false);
            return;
        }

        try {
            const response = await authService.signup({
                username:email,
                email,
                password,
                first_name: firstName,
                last_name: lastName,
            });
            setMessage(response.message || 'OTP sent! Please check your email.');
            if (typeof window !== 'undefined') {
                localStorage.setItem('signupEmail', email); 
            }
            router.push('/auth/otp'); 
        } catch (err: any) {
            setError(err.message || 'Signup failed. Please try again.');
        } finally {
            setIsLoading(false);
        }
    };

    const inputStyle = "mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm";
    const labelStyle = "block text-sm font-medium text-black-900";

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
            <div className="max-w-md w-full space-y-8 p-10 bg-white shadow-lg rounded-lg">
                <div>
                    <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
                        Create Merchant Account
                    </h2>
                </div>
                <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
                    <div><label htmlFor="email" className={labelStyle}>Email address</label><input id="email" name="email" type="email" autoComplete="email" required value={email} onChange={(e) => setEmail(e.target.value)} className={inputStyle} /></div>
                    <div><label htmlFor="firstName" className={labelStyle}>First Name (Optional)</label><input id="firstName" name="firstName" type="text" value={firstName} onChange={(e) => setFirstName(e.target.value)} className={inputStyle} /></div>
                    <div><label htmlFor="lastName" className={labelStyle}>Last Name (Optional)</label><input id="lastName" name="lastName" type="text" value={lastName} onChange={(e) => setLastName(e.target.value)} className={inputStyle} /></div>
                    <div><label htmlFor="password" className={labelStyle}>Password</label><input id="password" name="password" type="password" required value={password} onChange={(e) => setPassword1(e.target.value)} className={inputStyle} /></div>
                    <div><label htmlFor="password_2" className={labelStyle}>Confirm Password</label><input id="password_2" name="password_2" type="password" required value={password_2} onChange={(e) => setPassword2(e.target.value)} className={inputStyle} /></div>

                    {error && <p className="text-red-500 text-sm">{error}</p>}
                    {message && <p className="text-green-500 text-sm">{message}</p>}

                    <div>
                        <button
                            type="submit"
                            disabled={isLoading}
                            className="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:bg-indigo-300"
                        >
                            {isLoading ? 'Signing up...' : 'Sign up'}
                        </button>
                    </div>
                </form>
                 <p className="mt-2 text-center text-sm text-gray-600">
                    Already have an account?{' '}
                    <a href="/auth/login" className="font-medium text-indigo-600 hover:text-indigo-500">
                        Log in
                    </a>
                </p>
            </div>
        </div>
    );
}
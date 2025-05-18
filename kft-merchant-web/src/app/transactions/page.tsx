'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { authService, MerchantTransaction } from '@/services/authService'; 
import Link from 'next/link';

export default function TransactionsPage() {
    const router = useRouter();
    const [transactions, setTransactions] = useState<MerchantTransaction[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        if (!authService.isAuthenticated()) {
            router.push('/auth/login');
            return;
        }

        const fetchTransactions = async () => {
            setIsLoading(true);
            setError(null);
            try {
                const fetchedTransactions = await authService.getMerchantTransactions();
                setTransactions(fetchedTransactions);
            } catch (err: any) {
                setError(err.message || "Failed to fetch transactions.");
                 if (err.message === 'Not authenticated' || err.message.includes('401') || err.message.includes('token')) {
                    authService.logout();
                    router.push('/auth/login');
                }
            } finally {
                setIsLoading(false);
            }
        };

        fetchTransactions();
    }, [router]);

    const formatDate = (dateString: string) => {
        return new Date(dateString).toLocaleString();
    };

    if (isLoading) {
        return <div className="min-h-screen flex items-center justify-center"><p>Loading transactions...</p></div>;
    }

    return (
        <div className="container mx-auto p-4 md:p-8 bg-white min-h-screen">
            <div className="flex justify-between items-center mb-8">
                <h1 className="text-3xl font-bold text-gray-800">Transaction History</h1>
                <Link href="/dashboard" className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition duration-150">
                    Back to Dashboard
                </Link>
            </div>

            {error && <p className="text-red-500 bg-red-100 p-3 rounded-md mb-4">{error}</p>}

            <div className="bg-white shadow-xl rounded-lg overflow-hidden">
                <table className="min-w-full leading-normal">
                    <thead>
                        <tr className="bg-gray-100 text-left text-gray-600 uppercase text-sm">
                            <th className="px-5 py-3 border-b-2 border-gray-200">Date</th>
                            <th className="px-5 py-3 border-b-2 border-gray-200">Type</th>
                            <th className="px-5 py-3 border-b-2 border-gray-200 text-right">Amount</th>
                        </tr>
                    </thead>
                    <tbody className="text-gray-700">
                        {transactions.length === 0 && !isLoading && (
                            <tr><td colSpan={3} className="text-center py-10 text-gray-500">No transactions found.</td></tr>
                        )}
                        {transactions.map((transaction) => (
                            <tr key={transaction.id} className="border-b border-gray-200 hover:bg-gray-50">
                                <td className="px-5 py-4">
                                    <p className="whitespace-no-wrap">{formatDate(transaction.created_at)}</p>
                                </td>
                                <td className="px-5 py-4">
                                    <p className="whitespace-no-wrap">{transaction.transaction_type}</p>
                                </td>
                                <td className="px-5 py-4 text-right">
                                    <p className={`whitespace-no-wrap font-semibold ${
                                        parseFloat(transaction.amount) < 0 || transaction.transaction_type.toLowerCase().includes('payment') || transaction.transaction_type.toLowerCase().includes('fee')
                                            ? 'text-red-600'
                                            : 'text-green-600'
                                    }`}>
                                        ${parseFloat(transaction.amount).toFixed(2)}
                                    </p>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
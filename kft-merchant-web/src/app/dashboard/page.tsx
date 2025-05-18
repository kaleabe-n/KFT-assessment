'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { authService, Product } from '@/services/authService';
import ProductFormModal from '@/components/ProductFormModal'; 

export default function DashboardPage() {
    const router = useRouter();
    const [products, setProducts] = useState<Product[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [merchantBalance, setMerchantBalance] = useState<string | null>(null);


    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingProduct, setEditingProduct] = useState<Product | null>(null);
    const [isSubmitting, setIsSubmitting] = useState(false);

    const fetchProducts = async () => {
        setIsLoading(true);
        setError(null);
        try {
            const fetchedProducts = await authService.getMerchantProducts();
            const profileData = await authService.getMerchantProfile();
            setProducts(fetchedProducts);
            setMerchantBalance(profileData.balance); 

        } catch (err: any) {
            setError(err.message || "Failed to fetch dashboard data.");
            if (err.message === 'Not authenticated' || String(err.message).includes('401') || String(err.message).includes('token')) {
                 authService.logout(); 
                 router.push('/auth/login');
            }
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        if (!authService.isAuthenticated()) {
            router.push('/auth/login');
        } else {
            fetchProducts();
        }
    }, [router]);

    const handleOpenAddModal = () => {
        setEditingProduct(null);
        setIsModalOpen(true);
    };

    const handleOpenEditModal = (product: Product) => {
        setEditingProduct(product);
        setIsModalOpen(true);
    };

    const handleModalClose = () => {
        setIsModalOpen(false);
        setEditingProduct(null);
    };

    const handleModalSubmit = async (productData: Omit<Product, 'id' | 'owner' | 'owner_username'>) => {
        setIsSubmitting(true);
        setError(null);
        try {
            if (editingProduct) {
                await authService.updateProduct(editingProduct.id, productData);
            } else {
                await authService.addProduct(productData);
            }
            handleModalClose();
            await fetchProducts();
        } catch (err: any) {
            console.error("Modal submit error:", err.message);
            throw err; 
        } finally {
            setIsSubmitting(false);
        }
    };

    const handleDeleteProduct = async (productId: number) => {
        if (window.confirm("Are you sure you want to delete this product?")) {
            setIsLoading(true); 
            setError(null);
            try {
                await authService.deleteProduct(productId);
                await fetchProducts();
            } catch (err: any) {
                setError(err.message || "Failed to delete product.");
            } finally {
                setIsLoading(false);
            }
        }
    };

    const handleLogout = () => {
        authService.logout();
        router.push('/auth/login');
    };

    if (isLoading && products.length === 0) { 
        return <div className="min-h-screen flex items-center justify-center"><p>Loading dashboard...</p></div>;
    }

    return (
        <div className="container mx-auto p-4 md:p-8 bg-white min-h-screen">
            <div className="flex justify-between items-center mb-8">
                <h1 className="text-3xl font-bold text-gray-800">Merchant Dashboard</h1>
                <div>
                    <span className="mr-4 text-gray-700">Welcome, {authService.getUser()?.username || 'Merchant'}!</span>
                    <button
                        onClick={handleLogout}
                        className="px-4 py-2 bg-red-500 text-white rounded-md hover:bg-red-600 transition duration-150"
                    >
                        Logout
                    </button>
                </div>
            </div>

            {merchantBalance !== null && (
                <div className="mb-8 p-6 bg-gradient-to-r from-indigo-500 to-purple-600 text-white rounded-lg shadow-lg">
                    <h2 className="text-xl font-semibold mb-2">Your Current Balance</h2>
                    <p className="text-4xl font-bold">${parseFloat(merchantBalance).toFixed(2)}</p>
                </div>
            )}

            <div className="mb-6">
                <Link href="/transactions" className="text-indigo-600 hover:text-indigo-800 font-semibold">
                    View Transaction History &rarr;
                </Link>
            </div>

            <div className="mb-6">
                <button
                    onClick={handleOpenAddModal}
                    className="px-6 py-2 bg-indigo-600 text-white font-semibold rounded-md hover:bg-indigo-700 transition duration-150 shadow-md"
                >
                    Add New Product
                </button>
            </div>

            {error && <p className="text-red-500 bg-red-100 p-3 rounded-md mb-4">{error}</p>}
            
            {isLoading && products.length > 0 && <p className="text-center my-4">Updating product list...</p>}

            <div className="bg-white shadow-xl rounded-lg overflow-hidden">
                <table className="min-w-full leading-normal">
                    <thead>
                        <tr className="bg-gray-100 text-left text-gray-600 uppercase text-sm">
                            <th className="px-5 py-3 border-b-2 border-gray-200">Name</th>
                            <th className="px-5 py-3 border-b-2 border-gray-200">Description</th>
                            <th className="px-5 py-3 border-b-2 border-gray-200 text-right">Price</th>
                            <th className="px-5 py-3 border-b-2 border-gray-200 text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="text-gray-700">
                        {products.length === 0 && !isLoading && (
                            <tr><td colSpan={4} className="text-center py-10 text-gray-500">No products found. Add your first product!</td></tr>
                        )}
                        {products.map((product) => (
                            <tr key={product.id} className="border-b border-gray-200 hover:bg-gray-50">
                                <td className="px-5 py-4"><p className="font-semibold">{product.name}</p></td>
                                <td className="px-5 py-4"><p className="truncate max-w-xs">{product.description || '-'}</p></td>
                                <td className="px-5 py-4 text-right"><p>${parseFloat(product.price).toFixed(2)}</p></td>
                                <td className="px-5 py-4 text-center space-x-2">
                                    <button onClick={() => handleOpenEditModal(product)} className="text-indigo-600 hover:text-indigo-900 font-medium">Edit</button>
                                    <button onClick={() => handleDeleteProduct(product.id)} className="text-red-600 hover:text-red-900 font-medium">Delete</button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>

            <ProductFormModal
                isOpen={isModalOpen}
                onClose={handleModalClose}
                onSubmit={handleModalSubmit}
                initialData={editingProduct}
                isLoading={isSubmitting}
            />
        </div>
    );
}
'use client';

import { useState, useEffect, FormEvent } from 'react';
import { Product } from '@/services/authService'; // Assuming Product type is exported from authService

interface ProductFormModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: (productData: Omit<Product, 'id' | 'owner' | 'owner_username'>) => Promise<void>;
    initialData?: Product | null;
    isLoading: boolean;
}

export default function ProductFormModal({
    isOpen,
    onClose,
    onSubmit,
    initialData,
    isLoading
}: ProductFormModalProps) {
    const [name, setName] = useState('');
    const [description, setDescription] = useState('');
    const [price, setPrice] = useState('');
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        if (initialData) {
            setName(initialData.name || '');
            setDescription(initialData.description || '');
            setPrice(initialData.price || '');
        } else {
            // Reset form for adding new
            setName('');
            setDescription('');
            setPrice('');
        }
        setError(null); // Clear error when modal opens or data changes
    }, [initialData, isOpen]);

    const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
        event.preventDefault();
        setError(null);
        if (!name.trim() || !price.trim()) {
            setError("Name and Price are required.");
            return;
        }
        if (isNaN(parseFloat(price)) || parseFloat(price) <= 0) {
            setError("Price must be a valid positive number.");
            return;
        }

        try {
            await onSubmit({ name, description, price });
            // onClose(); // Parent component will handle closing on successful submit
        } catch (err: any) {
            setError(err.message || "An error occurred.");
        }
    };

    if (!isOpen) return null;

    const inputStyle = "mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm";
    const labelStyle = "block text-sm font-medium text-gray-700";

    return (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full flex items-center justify-center z-50">
            <div className="relative mx-auto p-8 border w-full max-w-md shadow-lg rounded-md bg-white">
                <h3 className="text-2xl font-bold text-center mb-6">
                    {initialData ? 'Edit Product' : 'Add New Product'}
                </h3>
                <form onSubmit={handleSubmit} className="space-y-4">
                    <div>
                        <label htmlFor="productName" className={labelStyle}>Product Name</label>
                        <input id="productName" type="text" value={name} onChange={(e) => setName(e.target.value)} className={inputStyle} required />
                    </div>
                    <div>
                        <label htmlFor="productDescription" className={labelStyle}>Description</label>
                        <textarea id="productDescription" value={description} onChange={(e) => setDescription(e.target.value)} className={inputStyle} rows={3}></textarea>
                    </div>
                    <div>
                        <label htmlFor="productPrice" className={labelStyle}>Price</label>
                        <input id="productPrice" type="number" step="0.01" value={price} onChange={(e) => setPrice(e.target.value)} className={inputStyle} required />
                    </div>

                    {error && <p className="text-red-500 text-sm text-center">{error}</p>}

                    <div className="flex items-center justify-end space-x-4 pt-4">
                        <button
                            type="button"
                            onClick={onClose}
                            disabled={isLoading}
                            className="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            disabled={isLoading}
                            className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:bg-indigo-300"
                        >
                            {isLoading ? (initialData ? 'Saving...' : 'Adding...') : (initialData ? 'Save Changes' : 'Add Product')}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
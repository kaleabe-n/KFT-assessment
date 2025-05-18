'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { adminAuthService } from '@/services/authService'; 

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    if (typeof window !== 'undefined') {
      if (adminAuthService.isAuthenticated()) {
        router.replace('/dashboard');
      } else {
        router.replace('/auth/login');
      }
    }
  }, [router]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <p className="text-gray-700">Loading KFT Admin Portal...</p>
    </div>
  );
}

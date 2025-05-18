'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { authService } from '@/services/authService';

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    if (typeof window !== 'undefined') {
      if (authService.isAuthenticated()) {
        router.replace('/dashboard');
      } else {
        router.replace('/auth/login');
      }
    }
  }, [router]);

  
  return (
    <div className="min-h-screen flex items-center justify-center">
      <p>Loading...</p>
    </div>
  );
}

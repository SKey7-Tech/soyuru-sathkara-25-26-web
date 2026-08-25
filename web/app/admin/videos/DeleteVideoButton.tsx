'use client';

import { useTransition } from 'react';

export default function DeleteVideoButton({ id, deleteAction }: { id: string, deleteAction: (formData: FormData) => void }) {
  const [isPending, startTransition] = useTransition();

  const handleDelete = () => {
    if (confirm('Are you sure you want to delete this video?')) {
      startTransition(() => {
        const formData = new FormData();
        formData.append('id', id);
        deleteAction(formData);
      });
    }
  };

  return (
    <button 
      onClick={handleDelete}
      disabled={isPending}
      className="text-red-500 hover:text-red-700 font-medium transition-colors disabled:opacity-50"
    >
      {isPending ? 'Deleting...' : 'Delete'}
    </button>
  );
}

'use client'

import { GovukButton } from '@/components/govuk'
import { ReviewGuardModal } from '@/components/review-guard/review-guard-modal'
import { useState } from 'react'

interface ReviewGuardButtonProps {
  onConfirm: () => void | Promise<void>
  disabled?: boolean
  className?: string
  // following props used only for wording/modal id
  action: 'copy' | 'download'
  subject: 'transcript' | 'document'
}

export function ReviewGuardButton({
  onConfirm,
  disabled,
  className,
  action,
  subject,
}: ReviewGuardButtonProps) {
  const [modalOpen, setModalOpen] = useState(false)

  const handleConfirm = async () => {
    setModalOpen(false)
    await onConfirm()
  }

  return (
    <>
      <GovukButton
        type="button"
        variant="secondary"
        onClick={() => setModalOpen(true)}
        disabled={disabled}
        className={className}
      >
        {action[0].toUpperCase() + action.slice(1)} {subject}
      </GovukButton>

      <ReviewGuardModal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        onConfirm={handleConfirm}
        action={action}
        subject={subject}
      />
    </>
  )
}

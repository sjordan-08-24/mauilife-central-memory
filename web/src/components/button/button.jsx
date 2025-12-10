import React from 'react'
import './button.css'

/**
 * Button Component
 *
 * A reusable button that can be customized with different styles and behaviors.
 *
 * Props:
 * - children: The text or content inside the button
 * - onClick: Function to call when button is clicked
 * - variant: 'primary' (default), 'secondary', or 'danger' - changes the color
 * - disabled: If true, button cannot be clicked
 * - loading: If true, shows a loading state
 */
function Button({
  children,
  onClick,
  variant = 'primary',
  disabled = false,
  loading = false
}) {
  // Combine CSS classes based on props
  // This lets us apply different styles depending on the variant
  const className = `button button-${variant} ${loading ? 'button-loading' : ''}`

  return (
    <button
      className={className}
      onClick={onClick}
      disabled={disabled || loading}
    >
      {/* Show "Loading..." text when loading, otherwise show children */}
      {loading ? 'Loading...' : children}
    </button>
  )
}

export default Button

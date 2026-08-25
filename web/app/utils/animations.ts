/**
 * Reusable animation variants for Framer Motion
 * Centralized animation configurations for consistent motion design
 */

// Container animations - used for parent elements with staggered children
export const containerVariants = {
  default: {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  },
  slow: {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.15
      }
    }
  },
  fast: {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.05
      }
    }
  }
};

// Item animations - used for individual elements
export const itemVariants = {
  fadeInUp: {
    hidden: { opacity: 0, y: 30 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.6
      }
    }
  },
  fadeInScale: {
    hidden: { opacity: 0, scale: 0.8 },
    visible: {
      opacity: 1,
      scale: 1,
      transition: {
        duration: 0.5
      }
    }
  },
  fadeIn: {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        duration: 0.5
      }
    }
  },
  slideInLeft: {
    hidden: { opacity: 0, x: -50 },
    visible: {
      opacity: 1,
      x: 0,
      transition: {
        duration: 0.6
      }
    }
  },
  slideInRight: {
    hidden: { opacity: 0, x: 50 },
    visible: {
      opacity: 1,
      x: 0,
      transition: {
        duration: 0.6
      }
    }
  }
};

// Page transition animations
export const pageVariants = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -20 }
};

// Hover animations
export const hoverVariants = {
  scale: {
    initial: { scale: 1 },
    hover: { scale: 1.05 },
    tap: { scale: 0.95 }
  },
  lift: {
    initial: { y: 0 },
    hover: { y: -8 },
    tap: { y: 0 }
  },
  glow: {
    initial: { boxShadow: '0 0 0 rgba(59, 130, 246, 0)' },
    hover: { boxShadow: '0 10px 30px rgba(59, 130, 246, 0.3)' }
  }
};

// Transition presets
export const transitionPresets = {
  spring: {
    type: "spring" as const,
    stiffness: 300,
    damping: 20
  },
  smooth: {
    duration: 0.6,
    ease: "easeInOut" as const
  },
  fast: {
    duration: 0.3,
    ease: "easeOut" as const
  },
  slow: {
    duration: 1,
    ease: "easeInOut" as const
  }
};

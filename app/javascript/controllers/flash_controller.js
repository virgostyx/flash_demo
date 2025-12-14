import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        duration: { type: Number, default: 5000 },
        removeDelay: { type: Number, default: 500 } // Time for fade-out animation
    }

    connect() {
        // Fade in animation
        this.element.classList.remove('opacity-0', 'translate-y-[-1rem]')
        this.element.classList.add('opacity-100', 'translate-y-0')

        // Auto-dismiss after duration
        this.timeoutId = setTimeout(() => {
            this.close()
        }, this.durationValue)
    }

    disconnect() {
        if (this.timeoutId) {
            clearTimeout(this.timeoutId)
        }
    }

    close() {
        // Clear timeout to prevent double-execution
        if (this.timeoutId) {
            clearTimeout(this.timeoutId)
            this.timeoutId = null
        }

        // Fade out animation
        this.element.classList.remove('opacity-100', 'translate-y-0')
        this.element.classList.add('opacity-0', 'translate-y-[-1rem]')

        // Remove element after animation completes
        setTimeout(() => {
            this.element.remove()
        }, this.removeDelayValue)
    }

    // Pause auto-dismiss on hover
    pause() {
        if (this.timeoutId) {
            clearTimeout(this.timeoutId)
            this.timeoutId = null
        }
    }

    // Resume auto-dismiss on mouse leave
    resume() {
        if (!this.timeoutId) {
            this.timeoutId = setTimeout(() => {
                this.close()
            }, this.durationValue)
        }
    }
}

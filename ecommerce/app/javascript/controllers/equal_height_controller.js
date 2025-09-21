import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card"]

  connect() {
    this.equalizeHeights()
    this.setupResizeListener()
  }

  disconnect() {
    if (this.resizeTimeout) {
      clearTimeout(this.resizeTimeout)
    }
  }

  equalizeHeights() {
    const cards = this.cardTargets.flatMap(target => 
      Array.from(target.querySelectorAll('.card'))
    )
    
    if (cards.length === 0) return
    
    cards.forEach(card => {
      card.style.height = 'auto'
    })
    
    for (let i = 0; i < cards.length; i += 4) {
      const row = cards.slice(i, i + 4)
      let maxHeight = 0
      
      row.forEach(card => {
        const cardHeight = card.offsetHeight
        if (cardHeight > maxHeight) {
          maxHeight = cardHeight
        }
      })
      
      row.forEach(card => {
        card.style.height = maxHeight + 'px'
      })
    }
  }

  setupResizeListener() {
    this.handleResize = () => {
      clearTimeout(this.resizeTimeout)
      this.resizeTimeout = setTimeout(() => {
        this.equalizeHeights()
      }, 100)
    }
    
    window.addEventListener('resize', this.handleResize)
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card"]

  connect() {
    setTimeout(() => {
      this.equalizeHeights()
    }, 100)
    this.setupResizeListener()
    
    document.addEventListener('turbo:load', () => {
      setTimeout(() => {
        this.equalizeHeights()
      }, 100)
    })
  }

  disconnect() {
    if (this.resizeTimeout) {
      clearTimeout(this.resizeTimeout)
    }
  }

  equalizeHeights() {
    const columns = this.cardTargets
    
    if (columns.length === 0) return
    
    columns.forEach(column => {
      column.style.height = 'auto'
    })
    
    let cardsPerRow = 4 // default for product grids
    if (columns.length > 0) {
      const firstColumn = columns[0]
      if (firstColumn.classList.contains('is-one-third-desktop')) {
        cardsPerRow = 3 // categories/brands
      } else if (firstColumn.classList.contains('is-3')) {
        cardsPerRow = 4 // featured products
      }
    }
    
    console.log('Using', cardsPerRow, 'cards per row')
    
    for (let i = 0; i < columns.length; i += cardsPerRow) {
      const row = columns.slice(i, i + cardsPerRow)
      let maxHeight = 0
      
      row.forEach(column => {
        const columnHeight = column.offsetHeight
        console.log('Column height:', columnHeight)
        if (columnHeight > maxHeight) {
          maxHeight = columnHeight
        }
      })
      
      row.forEach(column => {
        column.style.height = maxHeight + 'px'
        console.log('Set column height to:', maxHeight + 'px')
        
        const card = column.querySelector('.card')
        if (card) {
          card.style.height = '100%'
          card.style.display = 'flex'
          card.style.flexDirection = 'column'
        }
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

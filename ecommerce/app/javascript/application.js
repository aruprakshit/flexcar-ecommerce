// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Equal Height Cards - Turbo-compatible solution
document.addEventListener('turbo:load', function() {
  equalizeCardHeights();
});

document.addEventListener('turbo:render', function() {
  equalizeCardHeights();
});

function equalizeCardHeights() {
  const productGrids = document.querySelectorAll('.product-grid');
  
  productGrids.forEach(function(grid) {
    const cards = grid.querySelectorAll('.card');
    
    // Reset all card heights first
    cards.forEach(function(card) {
      card.style.height = 'auto';
    });
    
    // Group cards by row (4 cards per row on desktop)
    for (let i = 0; i < cards.length; i += 4) {
      const row = Array.from(cards).slice(i, i + 4);
      let maxHeight = 0;
      
      // Find the tallest card in the row
      row.forEach(function(card) {
        const cardHeight = card.offsetHeight;
        if (cardHeight > maxHeight) {
          maxHeight = cardHeight;
        }
      });
      
      // Set all cards in the row to the same height
      row.forEach(function(card) {
        card.style.height = maxHeight + 'px';
      });
    }
  });
}

// Run on window resize with debounce
let resizeTimeout;
window.addEventListener('resize', function() {
  clearTimeout(resizeTimeout);
  resizeTimeout = setTimeout(equalizeCardHeights, 100);
});

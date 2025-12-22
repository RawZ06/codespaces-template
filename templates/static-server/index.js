// Simple JavaScript for interactivity

let clickCount = 0;

const button = document.getElementById('clickBtn');
const result = document.getElementById('result');

button.addEventListener('click', () => {
    clickCount++;
    result.textContent = `Button clicked ${clickCount} time${clickCount !== 1 ? 's' : ''}!`;

    // Add a little animation
    result.style.transform = 'scale(1.1)';
    setTimeout(() => {
        result.style.transform = 'scale(1)';
    }, 200);
});

// Log a welcome message
console.log('Welcome to Static Server Template!');
console.log('Edit index.html, style.css, and index.js to customize your site.');

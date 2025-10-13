
const showNotification = (message, type = 'info') => {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 3000);
};

document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('input[type="range"]').forEach(range => {
        const container = document.createElement('div');
        container.className = 'range-container';
        range.parentNode.insertBefore(container, range);
        container.appendChild(range);
        
        const valueDisplay = document.createElement('div');
        valueDisplay.className = 'range-value';
        container.appendChild(valueDisplay);
        
        const updateValue = () => {
            valueDisplay.textContent = range.value;
            const percent = (range.value - range.min)/(range.max - range.min)*100;
            const offset = Math.min(Math.max(percent, 5), 95);
            valueDisplay.style.left = `calc(${offset}% + (${8 - offset*0.15}px))`;
            valueDisplay.style.opacity = '1';
        };
        
        const hideValue = () => {
            valueDisplay.style.opacity = '0';
            valueDisplay.style.pointerEvents = 'none';
        };
        
        const showValue = () => {
            valueDisplay.style.opacity = '1';
            valueDisplay.style.pointerEvents = 'auto';
        };

        updateValue();
        
        range.addEventListener('input', updateValue);
        
        range.addEventListener('mousedown', showValue);
        // range.addEventListener('mouseup', hideValue);
        range.addEventListener('touchstart', showValue);
        // range.addEventListener('touchend', hideValue);
        
        // container.addEventListener('mouseleave', hideValue);
    });
});
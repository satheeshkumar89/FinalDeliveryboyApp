// ========================================
// LOAD ORDER DATA
// ========================================
window.addEventListener('load', () => {
    const orderData = sessionStorage.getItem('currentOrder');

    if (orderData) {
        const order = JSON.parse(orderData);

        // Update customer info
        document.getElementById('customerName').textContent = order.customerName;
        document.getElementById('customerAddress').textContent = order.customerAddress;
        document.getElementById('customerPhone').textContent = order.customerPhone;

        // Update avatar
        const avatar = document.getElementById('customerAvatar');
        avatar.src = `https://ui-avatars.com/api/?name=${encodeURIComponent(order.customerName)}&background=667eea&color=fff&size=60`;
    }
});

// ========================================
// NAVIGATION
// ========================================
function goBack() {
    window.location.href = 'dashboard.html';
}

// ========================================
// START NAVIGATION
// ========================================
function startNavigation() {
    showToast('Opening Maps app...', 'info');

    // In a real app, this would open the device's maps app
    setTimeout(() => {
        showToast('Navigation started!', 'success');
    }, 1000);
}

// ========================================
// MARK AS ARRIVED
// ========================================
function markArrived() {
    const notification = document.getElementById('arrivalNotification');
    const confirmBtn = document.getElementById('confirmBtn');

    // Show arrival notification
    notification.style.display = 'flex';

    // Show confirm button
    confirmBtn.style.display = 'block';

    // Update markers - add arrived animation
    const endMarker = document.querySelector('.marker-end');
    endMarker.style.animation = 'bounceConfirm 0.6s ease-out';

    showToast('Location reached!', 'success');
}

// ========================================
// CONFIRM DELIVERY
// ========================================
function confirmDelivery() {
    if (confirm('Confirm delivery completion?')) {
        showToast('Delivery completed successfully!', 'success');

        // Wait a bit then go back to dashboard
        setTimeout(() => {
            sessionStorage.removeItem('currentOrder');
            window.location.href = 'dashboard.html';
        }, 1500);
    }
}

// ========================================
// CALL CUSTOMER
// ========================================
function callCustomer() {
    const phone = document.getElementById('customerPhone').textContent;

    if (confirm(`Call ${phone}?`)) {
        // In a real app, this would initiate a phone call
        window.location.href = `tel:${phone}`;
    }
}

// ========================================
// SEARCH FUNCTIONALITY
// ========================================
const searchInput = document.getElementById('searchInput');

searchInput.addEventListener('focus', () => {
    searchInput.parentElement.style.borderColor = '#4A90E2';
});

searchInput.addEventListener('blur', () => {
    searchInput.parentElement.style.borderColor = '#E1E8ED';
});

searchInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        const query = searchInput.value.trim();
        if (query) {
            showToast(`Searching for: ${query}`, 'info');
            // In real app, this would search for location
        }
    }
});

// ========================================
// TOAST NOTIFICATIONS
// ========================================
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;

    const colors = {
        success: '#00BA88',
        info: '#4A90E2',
        error: '#C41E3A'
    };

    toast.style.cssText = `
        position: fixed;
        bottom: 2rem;
        left: 50%;
        transform: translateX(-50%) translateY(100px);
        background: ${colors[type] || colors.info};
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 12px;
        font-weight: 600;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
        z-index: 10000;
        transition: transform 0.3s ease-out;
        max-width: 90%;
    `;

    document.body.appendChild(toast);

    setTimeout(() => {
        toast.style.transform = 'translateX(-50%) translateY(0)';
    }, 100);

    setTimeout(() => {
        toast.style.transform = 'translateX(-50%) translateY(100px)';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// ========================================
// BOUNCE CONFIRM ANIMATION
// ========================================
const style = document.createElement('style');
style.textContent = `
    @keyframes bounceConfirm {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.2); }
    }
`;
document.head.appendChild(style);

console.log('🗺️ Map route initialized');

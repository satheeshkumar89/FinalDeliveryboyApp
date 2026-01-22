// ========================================
// DRAWER MENU
// ========================================
const menuBtn = document.getElementById('menuBtn');
const drawer = document.getElementById('drawer');
const drawerOverlay = document.getElementById('drawerOverlay');
const logoutBtn = document.getElementById('logoutBtn');

function openDrawer() {
    drawer.classList.add('active');
    drawerOverlay.classList.add('active');
    document.body.style.overflow = 'hidden';
}

function closeDrawer() {
    drawer.classList.remove('active');
    drawerOverlay.classList.remove('active');
    document.body.style.overflow = '';
}

menuBtn.addEventListener('click', openDrawer);
drawerOverlay.addEventListener('click', closeDrawer);

// ========================================
// LOGOUT FUNCTIONALITY
// ========================================
logoutBtn.addEventListener('click', () => {
    if (confirm('Are you sure you want to logout?')) {
        localStorage.removeItem('isLoggedIn');
        localStorage.removeItem('userEmail');
        window.location.href = 'sample_login.html';
    }
});

// ========================================
// ORDER DETAILS MODAL
// ========================================
const modalOverlay = document.getElementById('modalOverlay');

const ordersData = {
    1: {
        id: '#833raew',
        status: 'On The Way',
        customerName: 'Mohamed Salah',
        customerAddress: 'Cairo, Nasr City, Street 233',
        customerPhone: '0123334456',
        note: 'Please deliver to the main gate'
    },
    2: {
        id: '#745mnop',
        status: 'Upcoming',
        customerName: 'Mohamed Ali',
        customerAddress: 'Cairo, Nasr City, Street 536',
        customerPhone: '0112010666',
        note: 'None'
    },
    3: {
        id: '#621abcd',
        status: 'Upcoming',
        customerName: 'Omar Said',
        customerAddress: 'Cairo, Nasr City, Street 333',
        customerPhone: '0123456789',
        note: 'Call before arriving'
    }
};

function showOrderDetails(orderId) {
    const order = ordersData[orderId];

    if (!order) return;

    // Update modal content
    document.getElementById('orderId').textContent = order.id;
    document.getElementById('orderStatus').textContent = order.status;
    document.getElementById('customerName').textContent = order.customerName;
    document.getElementById('customerAddress').textContent = order.customerAddress;
    document.getElementById('customerPhone').textContent = order.customerPhone;
    document.getElementById('orderNote').textContent = order.note;

    // Show modal
    modalOverlay.classList.add('active');
    document.body.style.overflow = 'hidden';
}

function closeModal() {
    modalOverlay.classList.remove('active');
    document.body.style.overflow = '';
}

// Close modal when clicking outside
modalOverlay.addEventListener('click', (e) => {
    if (e.target === modalOverlay) {
        closeModal();
    }
});

// Close modal on Escape key
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeModal();
        closeDrawer();
    }
});

// ========================================
// NAVIGATION TO MAP
// ========================================
function navigateToMap(orderId) {
    const order = ordersData[orderId];
    // Store order info in sessionStorage for map page
    sessionStorage.setItem('currentOrder', JSON.stringify(order));
    window.location.href = 'map_route.html';
}

// ========================================
// ORDER ACTIONS
// ========================================
document.addEventListener('click', (e) => {
    // Handle Cancel button
    if (e.target.classList.contains('btn-secondary') && e.target.textContent === 'Cancel') {
        const orderCard = e.target.closest('.order-card');
        if (confirm('Are you sure you want to cancel this order?')) {
            orderCard.style.animation = 'slideOut 0.3s ease-out';
            setTimeout(() => {
                orderCard.remove();
            }, 300);
        }
    }

    // Handle Confirm/Deliver button
    if (e.target.classList.contains('btn-primary')) {
        const orderCard = e.target.closest('.order-card');
        const orderId = orderCard.dataset.orderId;
        const action = e.target.textContent;

        if (confirm(`${action} this order?`)) {
            // Update status
            const statusDot = orderCard.querySelector('.status-dot');
            const statusLabel = orderCard.querySelector('.status-label');

            statusDot.classList.remove('status-ontheway', 'status-upcoming');
            statusDot.style.background = '#00BA88';
            statusLabel.textContent = 'Order Completed';

            // Change button
            e.target.textContent = 'Completed ✓';
            e.target.style.background = '#00BA88';
            e.target.disabled = true;

            // Show success message
            showToast('Order completed successfully!', 'success');
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

    toast.style.cssText = `
        position: fixed;
        bottom: 2rem;
        left: 50%;
        transform: translateX(-50%) translateY(100px);
        background: ${type === 'success' ? '#00BA88' : '#4A90E2'};
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 12px;
        font-weight: 600;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
        z-index: 10000;
        transition: transform 0.3s ease-out;
    `;

    document.body.appendChild(toast);

    // Animate in
    setTimeout(() => {
        toast.style.transform = 'translateX(-50%) translateY(0)';
    }, 100);

    // Remove after 3 seconds
    setTimeout(() => {
        toast.style.transform = 'translateX(-50%) translateY(100px)';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// ========================================
// SLIDE OUT ANIMATION
// ========================================
const style = document.createElement('style');
style.textContent = `
    @keyframes slideOut {
        to {
            opacity: 0;
            transform: translateX(-100%);
        }
    }
`;
document.head.appendChild(style);

// ========================================
// CHECK LOGIN STATUS
// ========================================
window.addEventListener('load', () => {
    const isLoggedIn = localStorage.getItem('isLoggedIn');

    if (!isLoggedIn) {
        window.location.href = 'sample_login.html';
        return;
    }

    // Welcome message
    const userEmail = localStorage.getItem('userEmail');
    if (userEmail) {
        setTimeout(() => {
            showToast(`Welcome back, ${userEmail.split('@')[0]}!`, 'success');
        }, 500);
    }
});

// ========================================
// NAVIGATION MENU ITEMS
// ========================================
document.querySelectorAll('.nav-item').forEach(item => {
    item.addEventListener('click', (e) => {
        e.preventDefault();
        const text = item.querySelector('span').textContent;
        closeDrawer();
        setTimeout(() => {
            showToast(`${text} - Feature coming soon!`, 'info');
        }, 300);
    });
});

console.log('📱 Dashboard initialized successfully');

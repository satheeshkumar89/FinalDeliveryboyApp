// ========================================
// PASSWORD VISIBILITY TOGGLE
// ========================================
const togglePasswordBtn = document.getElementById('togglePassword');
const passwordInput = document.getElementById('password');
const eyeOpen = togglePasswordBtn.querySelector('.eye-open');
const eyeClosed = togglePasswordBtn.querySelector('.eye-closed');

togglePasswordBtn.addEventListener('click', () => {
    const isPassword = passwordInput.type === 'password';

    // Toggle input type
    passwordInput.type = isPassword ? 'text' : 'password';

    // Toggle eye icons with smooth transition
    if (isPassword) {
        eyeOpen.style.display = 'none';
        eyeClosed.style.display = 'block';
    } else {
        eyeOpen.style.display = 'block';
        eyeClosed.style.display = 'none';
    }

    // Add a small animation to the button
    togglePasswordBtn.style.transform = 'scale(0.9)';
    setTimeout(() => {
        togglePasswordBtn.style.transform = 'scale(1)';
    }, 100);
});

// ========================================
// FORM VALIDATION & SUBMISSION
// ========================================
const loginForm = document.getElementById('loginForm');
const submitBtn = document.getElementById('submitBtn');
const btnText = submitBtn.querySelector('.btn-text');
const btnLoader = submitBtn.querySelector('.btn-loader');
const emailInput = document.getElementById('email');
const rememberMeCheckbox = document.getElementById('rememberMe');

// Load saved email if "Remember Me" was checked
window.addEventListener('load', () => {
    const savedEmail = localStorage.getItem('savedEmail');
    if (savedEmail) {
        emailInput.value = savedEmail;
        rememberMeCheckbox.checked = true;
    }
});

// Email validation
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

// Input validation with visual feedback
function validateInput(input) {
    const inputWrapper = input.closest('.input-wrapper');
    const inputIcon = inputWrapper.querySelector('.input-icon');

    if (input.value.trim() === '') {
        input.style.borderColor = '#FF6B6B';
        inputIcon.style.color = '#FF6B6B';
        return false;
    } else {
        input.style.borderColor = '#00BA88';
        inputIcon.style.color = '#00BA88';
        return true;
    }
}

// Real-time validation
emailInput.addEventListener('blur', () => {
    if (emailInput.value.trim() !== '') {
        const isValid = isValidEmail(emailInput.value) || emailInput.value.length >= 3;
        const inputWrapper = emailInput.closest('.input-wrapper');
        const inputIcon = inputWrapper.querySelector('.input-icon');

        if (isValid) {
            emailInput.style.borderColor = '#00BA88';
            inputIcon.style.color = '#00BA88';
        } else {
            emailInput.style.borderColor = '#FF6B6B';
            inputIcon.style.color = '#FF6B6B';
        }
    }
});

passwordInput.addEventListener('blur', () => validateInput(passwordInput));

// Remove validation colors on focus
[emailInput, passwordInput].forEach(input => {
    input.addEventListener('focus', () => {
        const inputWrapper = input.closest('.input-wrapper');
        const inputIcon = inputWrapper.querySelector('.input-icon');
        input.style.borderColor = '#FF6B6B';
        inputIcon.style.color = '#FF6B6B';
    });
});

// Form submission
loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    // Validate all inputs
    const isEmailValid = validateInput(emailInput);
    const isPasswordValid = validateInput(passwordInput);

    if (!isEmailValid || !isPasswordValid) {
        // Shake animation for invalid form
        loginForm.style.animation = 'shake 0.5s';
        setTimeout(() => {
            loginForm.style.animation = '';
        }, 500);
        return;
    }

    // Show loading state
    submitBtn.disabled = true;
    btnText.style.display = 'none';
    btnLoader.style.display = 'block';

    // Get form data
    const formData = {
        email: emailInput.value.trim(),
        password: passwordInput.value,
        rememberMe: rememberMeCheckbox.checked
    };

    try {
        // Simulate API call (replace with your actual API endpoint)
        const response = await simulateLogin(formData);

        if (response.success) {
            // Save email if "Remember Me" is checked
            if (formData.rememberMe) {
                localStorage.setItem('savedEmail', formData.email);
            } else {
                localStorage.removeItem('savedEmail');
            }

            // Show success state
            btnText.textContent = 'Success!';
            btnText.style.display = 'block';
            btnLoader.style.display = 'none';
            submitBtn.style.background = 'linear-gradient(135deg, #00BA88 0%, #00D09C 100%)';

            // Save login state
            localStorage.setItem('isLoggedIn', 'true');
            localStorage.setItem('userEmail', formData.email);

            // Redirect after short delay
            setTimeout(() => {
                window.location.href = 'dashboard.html';
            }, 1000);
        } else {
            throw new Error(response.message || 'Login failed');
        }
    } catch (error) {
        // Show error state
        btnText.textContent = 'Login Failed';
        btnText.style.display = 'block';
        btnLoader.style.display = 'none';
        submitBtn.style.background = 'linear-gradient(135deg, #FF6B6B 0%, #FF5252 100%)';

        // Show error message (you can customize this with a toast notification)
        alert(error.message || 'Invalid credentials. Please try again.');

        // Reset button after delay
        setTimeout(() => {
            btnText.textContent = 'Sign In';
            submitBtn.style.background = 'linear-gradient(135deg, #FF6B6B 0%, #FF8E53 100%)';
            submitBtn.disabled = false;
        }, 2000);
    }
});

// ========================================
// SIMULATED LOGIN FUNCTION
// Replace this with your actual API call
// ========================================
async function simulateLogin(credentials) {
    return new Promise((resolve) => {
        setTimeout(() => {
            // Demo: Accept any email with password "demo123"
            if (credentials.password === 'demo123') {
                resolve({
                    success: true,
                    message: 'Login successful',
                    user: {
                        email: credentials.email,
                        name: 'Demo User'
                    }
                });
            } else {
                resolve({
                    success: false,
                    message: 'Invalid credentials. Use password "demo123" for demo.'
                });
            }
        }, 1500);
    });
}

// ========================================
// SOCIAL LOGIN HANDLERS
// ========================================
const socialButtons = document.querySelectorAll('.social-btn');

socialButtons.forEach(btn => {
    btn.addEventListener('click', async (e) => {
        const provider = btn.querySelector('span').textContent.trim();

        // Add loading state
        btn.disabled = true;
        btn.style.opacity = '0.7';

        // Simulate social login (replace with actual OAuth flow)
        await new Promise(resolve => setTimeout(resolve, 1000));

        alert(`${provider} login would be handled here. Integrate with your OAuth provider.`);

        btn.disabled = false;
        btn.style.opacity = '1';
    });
});

// ========================================
// SHAKE ANIMATION FOR ERRORS
// ========================================
const style = document.createElement('style');
style.textContent = `
    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
        20%, 40%, 60%, 80% { transform: translateX(5px); }
    }
`;
document.head.appendChild(style);

// ========================================
// INPUT ANIMATIONS
// ========================================
const inputs = document.querySelectorAll('.form-input');

inputs.forEach(input => {
    input.addEventListener('input', () => {
        const wrapper = input.closest('.input-wrapper');
        const icon = wrapper.querySelector('.input-icon');

        if (input.value.length > 0) {
            icon.style.transform = 'scale(1.1)';
            setTimeout(() => {
                icon.style.transform = 'scale(1)';
            }, 200);
        }
    });
});

// ========================================
// PREVENT DEFAULT LINK BEHAVIORS (FOR DEMO)
// ========================================
document.querySelectorAll('a[href="#"]').forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        const linkText = link.textContent.trim();
        alert(`"${linkText}" functionality would be implemented here.`);
    });
});

// ========================================
// ACCESSIBILITY ENHANCEMENTS
// ========================================
// Add keyboard navigation for custom checkbox
rememberMeCheckbox.addEventListener('keypress', (e) => {
    if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        rememberMeCheckbox.checked = !rememberMeCheckbox.checked;
    }
});

// Focus trap for form (accessibility)
const focusableElements = loginForm.querySelectorAll(
    'input, button, a, [tabindex]:not([tabindex="-1"])'
);
const firstFocusable = focusableElements[0];
const lastFocusable = focusableElements[focusableElements.length - 1];

loginForm.addEventListener('keydown', (e) => {
    if (e.key === 'Tab') {
        if (e.shiftKey && document.activeElement === firstFocusable) {
            e.preventDefault();
            lastFocusable.focus();
        } else if (!e.shiftKey && document.activeElement === lastFocusable) {
            e.preventDefault();
            firstFocusable.focus();
        }
    }
});

// Auto-focus email input on page load
window.addEventListener('load', () => {
    setTimeout(() => {
        emailInput.focus();
    }, 300);
});

console.log('✨ Dharai Delivery Login System Initialized');
console.log('💡 Demo Tip: Use password "demo123" to test the login flow');

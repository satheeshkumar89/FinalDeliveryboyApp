## OTP Authentication Screens

I've successfully implemented the OTP authentication screens for the Dharai Delivery Boy app based on the Organflow design you provided.

### Files Created

1. **`lib/screens/phone_login_screen.dart`**
   - Phone number entry screen
   - Clean Organflow-style logo
   - 10-digit phone number input
   - "Send OTP" button
   - Terms and privacy policy links

2. **`lib/screens/otp_verification_screen.dart`**
   - 6-digit OTP input boxes
   - Auto-focus navigation between boxes
   - Masked phone number display
   - Resend OTP functionality with 30-second timer
   - Dynamic "Verify" button (grey when incomplete, green when all digits entered)
   - Back navigation support

### Features Implemented

#### Phone Login Screen
- ✅ Clean, minimalist design matching Organflow
- ✅ Green (#00C853) color scheme
- ✅ Logo with abstract design
- ✅ 10-digit phone number validation
- ✅ Input formatting (digits only)
- ✅ Loading state during OTP send
- ✅ Terms and privacy policy text at bottom

#### OTP Verification Screen
- ✅ 6 separate input boxes for OTP digits
- ✅ Auto-focus: automatically moves to next box when digit is entered
- ✅ Auto-backspace: moves to previous box when deleting
- ✅ Border color changes to green when box is filled
- ✅ Masked phone number display (e.g., "+91 94 *******53")
- ✅ Resend OTP with countdown timer (30 seconds)
- ✅ Verify button state:
  - Grey and disabled when OTP is incomplete
  - Green and enabled when all 6 digits are entered
- ✅ Loading state during verification
- ✅ Success/error feedback

### User Flow

1. **Login Screen** → Click "Login with Phone"
2. **Phone Login Screen** → Enter 10-digit number → Click "Send OTP"
3. **OTP Verification Screen** → Enter 6-digit OTP → Click "Verify"
4. **Success** → Navigate to Home (to be implemented)

### Integration with Existing App

- Updated `login_screen.dart` to add "Login with Phone" button
- Fully integrated with existing navigation flow
- Ready for backend API integration

### Next Steps (Optional)

To fully integrate with your backend:

1. **API Integration**
   - Add API call in `_sendOTP()` to request OTP from backend
   - Add API call in `_verifyOTP()` to verify OTP with backend
   - Handle authentication token storage on success

2. **Navigation**
   - Navigate to home screen after successful OTP verification
   - Handle authentication state management

3. **Error Handling**
   - Display specific error messages from backend
   - Handle network errors gracefully
   - Add retry logic for failed API calls

### Testing

The screens are now live in your running simulator! You can:
- Click "Login with Phone" on the login screen
- Enter a 10-digit phone number
- Test the OTP input boxes and auto-navigation
- See the verify button change color when OTP is complete
- Test the resend functionality

All UI/UX interactions are fully functional and match the Organflow design specifications.

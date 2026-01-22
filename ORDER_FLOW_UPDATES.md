# Delivery Boy App - Order Flow Updates

## Changes Made

### 1. **Updated Order Status Enum**
- Added `reachedRestaurant` status to `OrderStatus` enum in `order_model.dart`
- Updated status mapping to handle `'reached_restaurant'` and `'reached'` from backend
- Added color mapping (purple) for the new status
- Updated statusText getter to display "At Restaurant" for reachedRestaurant status

### 2. **Added New API Endpoint**
- Added `reachedRestaurant` endpoint constant in `api_constants.dart`:
  - `POST /delivery-partner/orders/{orderId}/reached`

###  3. **Created New Order Event**
- Added `ReachRestaurantRequested` event in `order_event.dart`
- Event triggers when delivery partner reaches the restaurant

### 4. **Updated Repository**
- Added `reachRestaurant(String orderId)` method in `order_repository.dart`
- Method calls the reached restaurant API endpoint

### 5. **Updated OrderBloc**
- Registered `ReachRestaurantRequested` event handler in constructor
- Implemented `_onReachRestaurantRequested` handler method
- Handler refreshes both active and available orders after status update

### 6. **Updated UI Components**

#### order_details_screen.dart
- Updated action buttons condition to include `reachedRestaurant` status
- Modified button flow:
  - **READY** → Shows "Reached Restaurant" button → Calls `ReachRestaurantRequested`
  - **REACHED_RESTAURANT** → Shows "Pick Up Order" button → Calls `PickupOrderRequested`
  - **ON_THE_WAY** → Shows "Complete Delivery" button → Calls `CompleteOrderRequested`
  - **UPCOMING** → Shows "Accept Order" button → Calls `AcceptOrderRequested`

#### order_card.dart
- Updated action buttons condition to include `reachedRestaurant` status
- Updated button logic to handle the new status flow
- Updated button text to show appropriate action based on status

## Order Flow

The complete delivery order flow is now:

1. **NEW/PENDING** → Restaurant prepares order
2. **READY** → Order ready for pickup (Shows in "Available Orders")
   - Delivery partner sees "Reached Restaurant" button
3. **REACHED_RESTAURANT** → Delivery partner arrived at restaurant
   - Shows "Pick Up Order" button
4. **PICKED_UP/ON_THE_WAY** → Order picked up, en route to customer
   - Shows "Complete Delivery" button
5. **DELIVERED/COMPLETED** → Order delivered

## Backend Requirements

The backend should ensure:
1. Available orders API (`/delivery-partner/orders/available`) returns only orders with `status = 'READY'`
2. Active orders API (`/delivery-partner/orders/active`) includes orders with statuses:
   - `REACHED_RESTAURANT`
   - `PICKED_UP`
   - `ON_THE_WAY`
   - `ASSIGNED`/`ACCEPTED`

## Files Modified

1. `/lib/core/constants/api_constants.dart` - Added reachedRestaurant endpoint
2. `/lib/models/order_model.dart` - Added reachedRestaurant status enum and mapping
3. `/lib/blocs/order/order_event.dart` - Added ReachRestaurantRequested event
4. `/lib/repositories/order_repository.dart` - Added reachRestaurant method
5. `/lib/blocs/order/order_bloc.dart` - Added event handler
6. `/lib/screens/order_details_screen.dart` - Updated button flow
7. `/lib/widgets/order_card.dart` - Updated button flow

## Testing Checklist

- [ ] Available orders only show READY status orders
- [ ] "Reached Restaurant" button appears for READY orders
- [ ] Clicking "Reached Restaurant" calls correct API and updates status
- [ ] "Pick Up Order" button appears for REACHED_RESTAURANT orders
- [ ] Order progresses correctly through all statuses
- [ ] Active orders list includes all in-progress statuses
- [ ] Real-time updates via Socket.IO work correctly
- [ ] Status colors display correctly for each state

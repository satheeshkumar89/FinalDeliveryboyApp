# Quick Reference: Order Flow Changes

## New Order Status Flow

```
┌──────────────────────────────────────────────────────────────┐
│  RESTAURANT SIDE                                               │
├──────────────────────────────────────────────────────────────┤
│  NEW → PREPARING → READY                                      │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────┐
│  DELIVERY PARTNER SIDE (NEW FLOW)                            │
├──────────────────────────────────────────────────────────────┤
│  1. READY (Available Tab)                                     │
│     Button: "Reached Restaurant"                              │
│     API: POST /orders/{id}/reached                            │
│                                                                │
│  2. REACHED_RESTAURANT (Active Tab)                           │
│     Button: "Pick Up Order"                                   │
│     API: POST /orders/{id}/picked-up                          │
│                                                                │
│  3. PICKED_UP / ON_THE_WAY (Active Tab)                       │
│     Button: "Complete Delivery"                               │
│     API: POST /orders/{id}/complete                           │
│                                                                │
│  4. DELIVERED (Completed Tab)                                 │
│     Final status ✓                                            │
└──────────────────────────────────────────────────────────────┘
```

## API Endpoints

| Endpoint | Method | Purpose | Status Change |
|----------|--------|---------|---------------|
| `/delivery-partner/orders/{id}/accept` | POST | Accept order | → ASSIGNED |
| **`/delivery-partner/orders/{id}/reached`** | **POST** | **Mark arrival** | **READY → REACHED** |
| `/delivery-partner/orders/{id}/picked-up` | POST | Pickup order | REACHED → ON_THE_WAY |
| `/delivery-partner/orders/{id}/complete` | POST | Complete delivery | ON_THE_WAY → DELIVERED |

## Status Colors

| Status | Color | Hex Code |
|--------|-------|----------|
| READY | 🟠 Orange | #FFA726 |
| **REACHED_RESTAURANT** | **🟣 Purple** | **#AB47BC** |
| ON_THE_WAY | 🔵 Blue | #42A5F5 |
| DELIVERED | ⚫ Grey | #BDBDBD |
| CANCELLED | 🔴 Red | #EF5350 |

## Backend Filter Requirements

### Available Orders (`/delivery-partner/orders/available`)
```sql
WHERE status = 'READY'
  AND delivery_partner_id IS NULL
  OR delivery_partner_id = <current_partner_id>
```

### Active Orders (`/delivery-partner/orders/active`)
```sql
WHERE delivery_partner_id = <current_partner_id>
  AND status IN ('ACCEPTED', 'ASSIGNED', 'REACHED_RESTAURANT', 'PICKED_UP', 'ON_THE_WAY')
```

### Completed Orders (`/delivery-partner/orders/completed`)
```sql
WHERE delivery_partner_id = <current_partner_id>
  AND status IN ('DELIVERED', 'COMPLETED')
ORDER BY updated_at DESC
LIMIT 50
```

## Code Locations

| Component | File Path |
|-----------|-----------|
| Status Enum | `lib/models/order_model.dart:1` |
| API Constant | `lib/core/constants/api_constants.dart:51-53` |
| Event | `lib/blocs/order/order_event.dart:27-34` |
| Repository Method | `lib/repositories/order_repository.dart:85-106` |
| Bloc Handler | `lib/blocs/order/order_bloc.dart:23-35` |
| Details Screen | `lib/screens/order_details_screen.dart:623-628` |
| Order Card | `lib/widgets/order_card.dart` |

## Testing Commands

```bash
# Analyze code
flutter analyze --no-pub

# Run app in debug mode
flutter run

# Build release APK  
flutter build apk --release

# View logs
flutter logs
```

## Common Issues & Solutions

### Issue: Button not showing
**Check:** Verify order status is correctly mapped from backend

### Issue: API call fails
**Check:** Backend endpoint `/orders/{id}/reached` is implemented

### Issue: Status doesn't update
**Check:** Socket.IO connection is working, refresh orders manually

### Issue: Wrong button text
**Check:** Status color in `_getStatusColor()` method

---

**Need help?** Check `IMPLEMENTATION_SUMMARY.md` for full details.

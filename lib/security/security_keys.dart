/// Canonical key names as configured in the database SecurityKey table.
///
/// Use these constants in every [SecurityGuard.guard] call so that a key
/// rename in the DB only requires updating one line here, not hunting down
/// raw strings across the codebase.
///
/// Level semantics (set by the admin in UsersScreen):
///   0 = Cashier-accessible  (both Cashier and Admin may enter)
///   1 = Admin-only          (only Admin may enter)
abstract final class SecurityKeys {
  // ── Main sidebar ──────────────────────────────────────────────────────────
  static const management     = 'Management';
  static const salesHistory   = 'SalesHistory';
  static const openOrders     = 'Order.All';
  static const endOfDay       = 'BusinessDay.Close';
  static const cashMovement   = 'CashMovement';
  static const creditPayments = 'CreditPayments';
  static const settings       = 'Settings';
  static const loyaltyCards   = 'Management.LoyaltyCards';
  static const shiftManagement = 'ShiftManagement';
}

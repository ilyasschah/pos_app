import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/auth/user_model.dart';
import 'package:pos_app/auth/users_screen.dart';
import 'package:pos_app/bookings/booking_model.dart';
import 'package:pos_app/bookings/bookings_provider.dart';
import 'package:pos_app/cart/cart_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/company/my_company_screen.dart';
import 'package:pos_app/currency/currencies_screen.dart';
import 'package:pos_app/document/documents_screen.dart';
import 'package:pos_app/floor_plan/floor_plan_table.dart';
import 'package:pos_app/menu/menu_screen.dart';
import 'package:pos_app/product/products_screen.dart';
import 'package:pos_app/reports/reports_screen.dart';
import 'package:pos_app/settings/settings_screen.dart';
import 'package:pos_app/stock/stock_screen.dart';
import 'package:pos_app/stock/warehouses_screen.dart';
import 'package:pos_app/tax/tax_rates_screen.dart';

// ── Layout constants ──────────────────────────────────────────────────────────
const double _slotHeight = 64.0;
const double _timeColWidth = 72.0;
const double _staffColWidth = 180.0;
const double _headerRowHeight = 48.0;
const int _dayStart = 8;  // 08:00
const int _dayEnd = 22;   // 22:00
const int _totalSlots = (_dayEnd - _dayStart) * 2; // 28 half-hour slots
const double _totalHeight = _totalSlots * _slotHeight; // 1792px

// ── Status helpers ────────────────────────────────────────────────────────────
// 1=Scheduled, 2=Arrived/Waiting, 3=In Service, 4=Completed & Paid, 5=No Show
const _statusLabels = {
  1: 'Scheduled',
  2: 'Arrived',
  3: 'In Service',
  4: 'Completed',
  5: 'No Show',
};
const _statusColors = {
  1: Colors.blue,
  2: Colors.orange,
  3: Colors.purple,
  4: Colors.green,
  5: Colors.grey,
};

Color _statusColor(int s) => _statusColors[s] ?? Colors.grey;
String _statusLabel(int s) => _statusLabels[s] ?? 'Unknown';

// ── Date helpers ──────────────────────────────────────────────────────────────
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months   = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _fmtHeaderDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';

String _fmtTime(TimeOfDay t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
}

String _fmtDateTime(DateTime dt) => _fmtTime(TimeOfDay.fromDateTime(dt));

enum _PostSaveAction { stay, open }

// ────────────────────────────────────────────────────────────────────────────
// BookingsScreen
// ────────────────────────────────────────────────────────────────────────────
class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedBookingDateProvider);
    final bookingsAsync = ref.watch(allBookingsProvider);
    final usersAsync = ref.watch(allUsersProvider);

    final company = ref.watch(selectedCompanyProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueGrey),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.event_note, color: Colors.white, size: 36),
                  const SizedBox(height: 8),
                  Text(company?.name ?? 'POS System',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(currentUser?.displayName ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('POS / Menu'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MenuScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('My Company'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MyCompanyScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Documents'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DocumentsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.fastfood),
              title: const Text('Products'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProductsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Stock'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StockScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: const Text('Warehouses'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const WarehousesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.percent),
              title: const Text('Tax Rates'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TaxRatesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Currencies'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CurrenciesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Users'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const UsersScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ReportsScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                ref.read(currentUserProvider.notifier).state = null;
                ref.read(cartProvider.notifier).clearCart();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous day',
            onPressed: () => ref.read(selectedBookingDateProvider.notifier).state =
                selectedDate.subtract(const Duration(days: 1)),
          ),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null && mounted) {
                ref.read(selectedBookingDateProvider.notifier).state = picked;
              }
            },
            child: Text(
              _fmtHeaderDate(selectedDate),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next day',
            onPressed: () => ref.read(selectedBookingDateProvider.notifier).state =
                selectedDate.add(const Duration(days: 1)),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: usersAsync.when(
              data: (users) => ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Booking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _showAddDialog(
                  context,
                  users: users.where((u) => u.isEnabled).toList(),
                  prefilledDate: selectedDate,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading bookings: $err')),
        data: (allBookings) {
          final dayBookings = allBookings
              .where((b) => isSameDay(b.startTime, selectedDate))
              .toList();

          return usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading staff: $err')),
            data: (allUsers) {
              final staff = allUsers.where((u) => u.isEnabled).toList();
              return _CalendarView(
                bookings: dayBookings,
                staff: staff,
                selectedDate: selectedDate,
                onEmptySlotTap: (staffMember, time) => _showAddDialog(
                  context,
                  users: staff,
                  prefilledDate: selectedDate,
                  prefilledStaff: staffMember,
                  prefilledTime: time,
                ),
                onBookingTap: (booking) => _showDetailDialog(context, booking, staff),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(
    BuildContext context, {
    required List<User> users,
    required DateTime prefilledDate,
    User? prefilledStaff,
    TimeOfDay? prefilledTime,
  }) {
    showDialog(
      context: context,
      builder: (_) => _AddBookingDialog(
        users: users,
        date: prefilledDate,
        prefilledStaff: prefilledStaff,
        prefilledTime: prefilledTime,
        onSaved: () => ref.invalidate(allBookingsProvider),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, Booking booking, List<User> staff) {
    showDialog(
      context: context,
      builder: (_) => _BookingDetailDialog(
        booking: booking,
        staff: staff,
        onUpdated: () => ref.invalidate(allBookingsProvider),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Calendar View
// ────────────────────────────────────────────────────────────────────────────
class _CalendarView extends StatelessWidget {
  final List<Booking> bookings;
  final List<User> staff;
  final DateTime selectedDate;
  final void Function(User?, TimeOfDay) onEmptySlotTap;
  final void Function(Booking) onBookingTap;

  const _CalendarView({
    required this.bookings,
    required this.staff,
    required this.selectedDate,
    required this.onEmptySlotTap,
    required this.onBookingTap,
  });

  double _bookingTop(Booking b) {
    final minutesFromStart =
        (b.startTime.hour - _dayStart) * 60 + b.startTime.minute;
    return (minutesFromStart / 30) * _slotHeight;
  }

  double _bookingHeight(Booking b) {
    final durationMinutes = b.endTime.difference(b.startTime).inMinutes;
    return (durationMinutes / 30) * _slotHeight;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCols = staff.isEmpty ? 1 : staff.length;
    final gridWidth = totalCols * _staffColWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fill screen width if staff fit
        final effectiveColWidth = staff.isEmpty
            ? constraints.maxWidth
            : (constraints.maxWidth - _timeColWidth) / totalCols < _staffColWidth
                ? _staffColWidth
                : (constraints.maxWidth - _timeColWidth) / totalCols;
        final effectiveGridWidth = totalCols * effectiveColWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Time Labels column ────────────────────────────────────────
              SizedBox(
                width: _timeColWidth,
                child: Column(
                  children: [
                    // spacer for staff header row
                    SizedBox(height: _headerRowHeight),
                    for (int i = 0; i < _totalSlots; i++)
                      SizedBox(
                        height: _slotHeight,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8, top: 4),
                            child: Text(
                              _slotLabel(i),
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Staff columns ─────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: effectiveGridWidth,
                    child: Column(
                      children: [
                        // Staff header row
                        SizedBox(
                          height: _headerRowHeight,
                          child: Row(
                            children: staff.isEmpty
                                ? [
                                    Expanded(
                                      child: _StaffHeader(
                                        name: 'Unassigned',
                                        theme: theme,
                                      ),
                                    ),
                                  ]
                                : staff
                                    .map((u) => SizedBox(
                                          width: effectiveColWidth,
                                          child: _StaffHeader(
                                            name: u.displayName,
                                            theme: theme,
                                          ),
                                        ))
                                    .toList(),
                          ),
                        ),

                        // Calendar body
                        SizedBox(
                          height: _totalHeight,
                          child: Stack(
                            children: [
                              // Horizontal grid lines
                              for (int i = 0; i <= _totalSlots; i++)
                                Positioned(
                                  top: i * _slotHeight,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: i % 2 == 0 ? 1.0 : 0.5,
                                    color: theme.dividerColor.withValues(
                                        alpha: i % 2 == 0 ? 0.5 : 0.25),
                                  ),
                                ),

                              // Vertical column dividers
                              for (int i = 1; i < totalCols; i++)
                                Positioned(
                                  left: i * effectiveColWidth,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 1,
                                    color: theme.dividerColor.withValues(alpha: 0.4),
                                  ),
                                ),

                              // Empty-slot tap layer
                              Positioned.fill(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTapDown: (details) {
                                    final colIndex =
                                        (details.localPosition.dx / effectiveColWidth)
                                            .floor()
                                            .clamp(0, totalCols - 1);
                                    final slotIndex =
                                        (details.localPosition.dy / _slotHeight)
                                            .floor()
                                            .clamp(0, _totalSlots - 1);
                                    final totalMinutes =
                                        _dayStart * 60 + slotIndex * 30;
                                    final time = TimeOfDay(
                                      hour: totalMinutes ~/ 60,
                                      minute: totalMinutes % 60,
                                    );
                                    final staffMember = staff.isNotEmpty &&
                                            colIndex < staff.length
                                        ? staff[colIndex]
                                        : null;
                                    onEmptySlotTap(staffMember, time);
                                  },
                                ),
                              ),

                              // Booking chips
                              ..._buildBookingChips(
                                  staff, effectiveColWidth, gridWidth),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildBookingChips(
      List<User> staff, double colWidth, double totalWidth) {
    final chips = <Widget>[];

    for (final booking in bookings) {
      final top = _bookingTop(booking);
      final height = _bookingHeight(booking).clamp(_slotHeight * 0.5, double.infinity);

      // Find column index by userId
      int colIndex = 0;
      if (booking.userId != null && staff.isNotEmpty) {
        final idx = staff.indexWhere((u) => u.id == booking.userId);
        colIndex = idx >= 0 ? idx : 0;
      }

      chips.add(
        Positioned(
          top: top,
          left: colIndex * colWidth + 2,
          width: colWidth - 4,
          height: height,
          child: GestureDetector(
            onTap: () => onBookingTap(booking),
            child: _BookingChip(booking: booking),
          ),
        ),
      );
    }
    return chips;
  }

  String _slotLabel(int index) {
    final totalMinutes = _dayStart * 60 + index * 30;
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (m != 0) return '';
    final period = h < 12 ? 'AM' : 'PM';
    final displayH = h % 12 == 0 ? 12 : h % 12;
    return '$displayH $period';
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Staff Header Cell
// ────────────────────────────────────────────────────────────────────────────
class _StaffHeader extends StatelessWidget {
  final String name;
  final ThemeData theme;

  const _StaffHeader({required this.name, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
          right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: theme.colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Booking Chip (compact card for the grid)
// ────────────────────────────────────────────────────────────────────────────
class _BookingChip extends StatelessWidget {
  final Booking booking;

  const _BookingChip({required this.booking});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(booking.status);
    final timeStr =
        '${_fmtDateTime(booking.startTime)} – ${_fmtDateTime(booking.endTime)}';

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            booking.reservationName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (booking.guestCount > 1)
            Row(
              children: [
                Icon(Icons.people,
                    size: 10,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5)),
                const SizedBox(width: 2),
                Text(
                  '${booking.guestCount}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Add Booking Dialog
// ────────────────────────────────────────────────────────────────────────────
class _AddBookingDialog extends ConsumerStatefulWidget {
  final List<User> users;
  final DateTime date;
  final User? prefilledStaff;
  final TimeOfDay? prefilledTime;
  final VoidCallback onSaved;

  const _AddBookingDialog({
    required this.users,
    required this.date,
    this.prefilledStaff,
    this.prefilledTime,
    required this.onSaved,
  });

  @override
  ConsumerState<_AddBookingDialog> createState() => _AddBookingDialogState();
}

class _AddBookingDialogState extends ConsumerState<_AddBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _guestController = TextEditingController(text: '1');
  final _noteController = TextEditingController();

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  User? _selectedStaff;
  FloorPlanTable? _selectedRoom;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _startTime = widget.prefilledTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = TimeOfDay(
      hour: (_startTime.hour + 1).clamp(0, 23),
      minute: _startTime.minute,
    );
    _selectedStaff = widget.prefilledStaff ??
        (widget.users.isNotEmpty ? widget.users.first : null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _guestController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  DateTime _toDateTime(TimeOfDay t) => DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        t.hour,
        t.minute,
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;

    try {
      final createdMap = await ApiClient().createBooking(companyId, {
        'reservationName': _nameController.text.trim(),
        'guestCount': int.tryParse(_guestController.text) ?? 1,
        'startTime': _toDateTime(_startTime).toIso8601String(),
        'endTime': _toDateTime(_endTime).toIso8601String(),
        'userId': _selectedStaff?.id,
        'floorPlanTableId': _selectedRoom?.id,
        'note': _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      });
      final created = Booking.fromJson(createdMap);
      widget.onSaved();
      if (!mounted) return;

      // Post-save confirmation
      final action = await showDialog<_PostSaveAction>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Booking Saved!'),
          content: Text(
            '${created.reservationName} has been scheduled for '
            '${_fmtDateTime(created.startTime)}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, _PostSaveAction.stay),
              child: const Text('Stay on Calendar'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text('Open Order Now',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () => Navigator.pop(ctx, _PostSaveAction.open),
            ),
          ],
        ),
      );

      if (!mounted) return;
      if (action == _PostSaveAction.open) {
        final user = ref.read(currentUserProvider);
        if (user != null) {
          await ref.read(cartProvider.notifier).startBookingOrder(
                ApiClient(),
                companyId,
                user.id,
                created.id,
                created.reservationName,
                staffUserId: created.userId,
                floorPlanTableId: created.floorPlanTableId,
              );
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MenuScreen()),
            (route) => false,
          );
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Booking'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Guest Name *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TimePicker(
                      label: 'Start Time',
                      time: _startTime,
                      onChanged: (t) => setState(() {
                        _startTime = t;
                        final endH = (t.hour + 1).clamp(0, 23);
                        _endTime = TimeOfDay(hour: endH, minute: t.minute);
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimePicker(
                      label: 'End Time',
                      time: _endTime,
                      onChanged: (t) => setState(() => _endTime = t),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _guestController,
                      decoration: const InputDecoration(
                        labelText: 'Guests',
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<User?>(
                      initialValue: _selectedStaff,
                      decoration: const InputDecoration(
                        labelText: 'Staff',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      items: [
                        const DropdownMenuItem<User?>(
                          value: null,
                          child: Text('Unassigned'),
                        ),
                        ...widget.users.map(
                          (u) => DropdownMenuItem<User?>(
                            value: u,
                            child: Text(u.displayName),
                          ),
                        ),
                      ],
                      onChanged: (u) => setState(() => _selectedStaff = u),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ref.watch(allRoomsProvider).when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
                data: (rooms) => DropdownButtonFormField<FloorPlanTable?>(
                  initialValue: _selectedRoom,
                  decoration: const InputDecoration(
                    labelText: 'Room / Resource (optional)',
                    prefixIcon: Icon(Icons.meeting_room),
                  ),
                  items: [
                    const DropdownMenuItem<FloorPlanTable?>(
                      value: null,
                      child: Text('No room assigned'),
                    ),
                    ...rooms.map((t) => DropdownMenuItem<FloorPlanTable?>(
                          value: t,
                          child: Text(t.name),
                        )),
                  ],
                  onChanged: (t) => setState(() => _selectedRoom = t),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Booking Detail / Status Update Dialog
// ────────────────────────────────────────────────────────────────────────────
class _BookingDetailDialog extends ConsumerStatefulWidget {
  final Booking booking;
  final List<User> staff;
  final VoidCallback onUpdated;

  const _BookingDetailDialog({
    required this.booking,
    required this.staff,
    required this.onUpdated,
  });

  @override
  ConsumerState<_BookingDetailDialog> createState() =>
      _BookingDetailDialogState();
}

class _BookingDetailDialogState extends ConsumerState<_BookingDetailDialog> {
  bool _saving = false;

  String _staffName(int? userId) {
    if (userId == null) return 'Unassigned';
    final u = widget.staff.where((s) => s.id == userId).firstOrNull;
    return u?.displayName ?? 'Staff #$userId';
  }

  Future<void> _updateStatus(int newStatus) async {
    setState(() => _saving = true);
    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;
    try {
      await ApiClient()
          .updateBookingStatus(companyId, widget.booking.id, newStatus);
      widget.onUpdated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _startService() async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    final user = ref.read(currentUserProvider);
    if (companyId == null || user == null) return;

    setState(() => _saving = true);
    try {
      // Mark booking as In Service
      await ApiClient().updateBookingStatus(
          companyId, widget.booking.id, 3);

      // Create PosOrder linked to this booking and populate the cart
      await ref.read(cartProvider.notifier).startBookingOrder(
            ApiClient(),
            companyId,
            user.id,
            widget.booking.id,
            widget.booking.reservationName,
            staffUserId: widget.booking.userId,
            floorPlanTableId: widget.booking.floorPlanTableId,
          );

      widget.onUpdated();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MenuScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Booking'),
        content: Text(
            'Delete booking for "${widget.booking.reservationName}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _saving = true);
    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) return;
    try {
      await ApiClient().deleteBooking(companyId, widget.booking.id);
      widget.onUpdated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _statusBtn(int currentStatus, int s) {
    return ElevatedButton(
      onPressed: (currentStatus == s || _saving) ? null : () => _updateStatus(s),
      style: ElevatedButton.styleFrom(
        backgroundColor: _statusColor(s),
        disabledBackgroundColor: _statusColor(s).withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        _statusLabel(s),
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = widget.booking;
    final statusColor = _statusColor(b.status);

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              b.reservationName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: ShapeDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: const StadiumBorder(),
            ),
            child: Text(
              _statusLabel(b.status),
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              icon: Icons.access_time,
              text:
                  '${_fmtDateTime(b.startTime)} – ${_fmtDateTime(b.endTime)}',
            ),
            _DetailRow(
                icon: Icons.people, text: '${b.guestCount} guest(s)'),
            _DetailRow(
                icon: Icons.badge, text: _staffName(b.userId)),
            if (b.note != null && b.note!.isNotEmpty)
              _DetailRow(icon: Icons.notes, text: b.note!),
            if (b.floorPlanTableId != null)
              _DetailRow(icon: Icons.meeting_room, text: 'Room #${b.floorPlanTableId}'),
            if (b.status == 4) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, size: 14, color: Colors.green),
                    SizedBox(width: 8),
                    Text('This booking is completed and cannot be modified.',
                        style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Text('Update Status',
                  style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 8),
              Row(
                children: [1, 2, 3].expand((s) => [
                  if (s > 1) const SizedBox(width: 6),
                  Expanded(child: _statusBtn(b.status, s)),
                ]).toList(),
              ),
              const SizedBox(height: 6),
              Row(
                children: [4, 5].expand((s) => [
                  if (s > 4) const SizedBox(width: 6),
                  Expanded(child: _statusBtn(b.status, s)),
                ]).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (b.status != 4)
          TextButton.icon(
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: _saving ? null : _delete,
          ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (b.status != 4 && b.status != 5) ...[
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text('Start Service',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: _saving ? null : _startService,
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon,
              size: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Time Picker helper widget
// ────────────────────────────────────────────────────────────────────────────
class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  const _TimePicker({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.access_time, size: 18),
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(_fmtTime(time), style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/place.dart';
import '../models/user.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';
import '../services/user_service.dart';
import '../database/database_helper.dart';

class BookingFormScreen extends StatefulWidget {
  final Place place;

  const BookingFormScreen({
    Key? key,
    required this.place,
  }) : super(key: key);

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final ReservationService _reservationService = ReservationService();
  final UserService _userService = UserService();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specialRequestsController = TextEditingController();

  // Calendar
  DateTime _focusedDay = DateTime.now();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  // Form data
  int _numberOfGuests = 1;
  double _totalPrice = 0.0;
  bool _isLoading = false;
  List<DateTime> _bookedDates = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadBookedDates();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _loadBookedDates() async {
    try {
      List<DateTime> bookedDates = await _reservationService.getBookedDatesForPlace(widget.place.id!);
      setState(() {
        _bookedDates = bookedDates;
      });
    } catch (e) {
      print('Error loading booked dates: $e');
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_checkInDate, selectedDay)) {
      setState(() {
        _focusedDay = focusedDay;
      });
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _checkInDate = start;
      _checkOutDate = end;
    });

    if (start != null && end != null) {
      _calculateTotalPrice();
    }
  }

  Future<void> _calculateTotalPrice() async {
    if (_checkInDate != null && _checkOutDate != null) {
      double price = await _reservationService.calculateTotalPrice(
        widget.place.id!,
        _checkInDate!,
        _checkOutDate!,
        _numberOfGuests,
      );
      setState(() {
        _totalPrice = price;
      });
    }
  }

  bool _isDayBooked(DateTime day) {
    return _bookedDates.any((bookedDate) => isSameDay(bookedDate, day));
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_checkInDate == null || _checkOutDate == null) {
      _showErrorDialog('Por favor selecciona las fechas de check-in y check-out');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Test database connection first
      await _testDatabaseConnection();
      
      // Check if dates are available
      bool isAvailable = await _reservationService.isDateAvailable(
        widget.place.id!,
        _checkInDate!,
        _checkOutDate!,
      );

      if (!isAvailable) {
        throw Exception('Las fechas seleccionadas no están disponibles');
      }

      // Create or get user
      User? user = await _userService.getUserByEmail(_emailController.text);
      if (user == null) {
        user = await _userService.registerUser(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
        );
      }

      if (user == null) {
        throw Exception('Error creating user');
      }

      // Create reservation
      Reservation reservation = Reservation(
        placeId: widget.place.id!,
        userId: user.id!,
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        numberOfGuests: _numberOfGuests,
        totalPrice: _totalPrice,
        status: ReservationStatus.pending,
        specialRequests: _specialRequestsController.text.isNotEmpty 
            ? _specialRequestsController.text 
            : null,
        createdAt: DateTime.now(),
      );

      await _reservationService.createReservation(reservation);

      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      print('Error in _submitBooking: $e');
      
      if (e.toString().contains('databaseFactory not initialized') || 
          e.toString().contains('Bad state') ||
          e.toString().contains('database') ||
          e.toString().contains('Database')) {
        _showDatabaseErrorDialog();
      } else {
        _showErrorDialog('Error al crear la reserva: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Reserva Exitosa!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text('Tu reserva en ${widget.place.title} ha sido creada exitosamente.'),
            const SizedBox(height: 8),
            Text('Total: Rp ${_totalPrice.toStringAsFixed(0)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar ${widget.place.title}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Place info card
              _buildPlaceInfoCard(),
              const SizedBox(height: 24),

              // Calendar section
              _buildCalendarSection(),
              const SizedBox(height: 24),

              // Guests selection
              _buildGuestsSection(),
              const SizedBox(height: 24),

              // User information
              _buildUserInfoSection(),
              const SizedBox(height: 24),

              // Special requests
              _buildSpecialRequestsSection(),
              const SizedBox(height: 24),

              // Price summary
              _buildPriceSummary(),
              const SizedBox(height: 32),

              // Submit button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                widget.place.imageAsset,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.place.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.place.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                        ' ${widget.place.rating}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        widget.place.price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona fechas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TableCalendar<dynamic>(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              rangeSelectionMode: _rangeSelectionMode,
              rangeStartDay: _checkInDate,
              rangeEndDay: _checkOutDate,
              onDaySelected: _onDaySelected,
              onRangeSelected: _onRangeSelected,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              enabledDayPredicate: (day) {
                // Disable past dates and booked dates
                if (day.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                  return false;
                }
                return !_isDayBooked(day);
              },
              calendarStyle: CalendarStyle(
                rangeHighlightColor: Colors.teal.withOpacity(0.3),
                rangeStartDecoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                disabledDecoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(color: Colors.red),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            if (_checkInDate != null && _checkOutDate != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Check-in', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_formatDate(_checkInDate!)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Check-out', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_formatDate(_checkOutDate!)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGuestsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Número de huéspedes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Huéspedes',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _numberOfGuests > 1
                          ? () {
                              setState(() {
                                _numberOfGuests--;
                              });
                              _calculateTotalPrice();
                            }
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.teal,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.teal),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_numberOfGuests',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _numberOfGuests < 10
                          ? () {
                              setState(() {
                                _numberOfGuests++;
                              });
                              _calculateTotalPrice();
                            }
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.teal,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del huésped',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Por favor ingresa tu nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Por favor ingresa tu correo';
                }
                if (!value!.contains('@')) {
                  return 'Por favor ingresa un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Por favor ingresa tu teléfono';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialRequestsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Solicitudes especiales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialRequestsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Solicitudes adicionales (opcional)',
                hintText: 'Ej: Vista al mar, cuna para bebé, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.note_add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de precio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_checkInDate != null && _checkOutDate != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Noches: ${_checkOutDate!.difference(_checkInDate!).inDays}'),
                  Text(widget.place.price),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Huéspedes: $_numberOfGuests'),
                  if (_numberOfGuests > 2)
                    Text('+ Rp ${(_numberOfGuests - 2) * 50000 * _checkOutDate!.difference(_checkInDate!).inDays}'),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rp ${_totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'Selecciona fechas para ver el precio',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Confirmar Reserva',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _testDatabaseConnection() async {
    try {
      // Try a simple database operation
      await _userService.getAllUsers();
    } catch (e) {
      print('Database connection test failed: $e');
      throw Exception('Error de conexión a la base de datos');
    }
  }

  void _showDatabaseErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Error de Base de Datos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning,
              color: Colors.orange,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Hay un problema con la base de datos. ¿Deseas reiniciar la aplicación para solucionarlo?',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetAndRetry();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAndRetry() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Reset database
      await DatabaseHelper.instance.resetDatabase();
      
      // Wait a moment
      await Future.delayed(const Duration(seconds: 1));
      
      // Try to initialize again
      await DatabaseHelper.instance.database;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Base de datos reiniciada. Puedes intentar de nuevo.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorDialog('Error al reiniciar la base de datos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
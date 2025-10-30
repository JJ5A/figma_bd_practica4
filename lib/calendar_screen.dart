import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/reservation.dart';
import '../models/place.dart';
import '../models/user.dart';
import '../services/reservation_service.dart';
import '../services/place_service.dart';
import '../services/user_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ReservationService _reservationService = ReservationService();
  final PlaceService _placeService = PlaceService();
  final UserService _userService = UserService();
  
  late final ValueNotifier<List<Reservation>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  
  Map<DateTime, List<Reservation>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadReservations();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Reservation> reservations = await _reservationService.getAllReservations();
      _events = _groupReservationsByDate(reservations);
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    } catch (e) {
      print('Error loading reservations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reservations: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<DateTime, List<Reservation>> _groupReservationsByDate(List<Reservation> reservations) {
    Map<DateTime, List<Reservation>> events = {};
    
    for (Reservation reservation in reservations) {
      DateTime startDate = DateTime(
        reservation.checkInDate.year,
        reservation.checkInDate.month,
        reservation.checkInDate.day,
      );
      DateTime endDate = DateTime(
        reservation.checkOutDate.year,
        reservation.checkOutDate.month,
        reservation.checkOutDate.day,
      );
      
      DateTime currentDate = startDate;
      while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
        if (events[currentDate] == null) {
          events[currentDate] = [];
        }
        events[currentDate]!.add(reservation);
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }
    
    return events;
  }

  List<Reservation> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  List<Reservation> _getEventsForRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(start.add(Duration(days: i)));
    }

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else {
      _selectedEvents.value = [];
    }
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.confirmed:
        return Colors.green;
      case ReservationStatus.checkedIn:
        return Colors.blue;
      case ReservationStatus.checkedOut:
        return Colors.teal;
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.completed:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendario de Reservas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReservations,
          ),
          PopupMenuButton<CalendarFormat>(
            icon: const Icon(Icons.view_module, color: Colors.white),
            onSelected: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarFormat.month,
                child: Text('Vista Mensual'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.twoWeeks,
                child: Text('Vista 2 Semanas'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.week,
                child: Text('Vista Semanal'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TableCalendar<Reservation>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    eventLoader: _getEventsForDay,
                    rangeSelectionMode: _rangeSelectionMode,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    onDaySelected: _onDaySelected,
                    onRangeSelected: _onRangeSelected,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: const TextStyle(color: Colors.red),
                      holidayTextStyle: const TextStyle(color: Colors.red),
                      selectedDecoration: BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      formatButtonTextStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: ValueListenableBuilder<List<Reservation>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reservas (${value.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: value.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No hay reservas para esta fecha',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: value.length,
                                      itemBuilder: (context, index) {
                                        final reservation = value[index];
                                        return _buildReservationCard(reservation);
                                      },
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FutureBuilder<Place?>(
                    future: _placeService.getPlaceById(reservation.placeId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Text(
                          snapshot.data!.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                      return const Text('Cargando lugar...');
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reservation.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reservation.status.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<User?>(
              future: _userService.getUserById(reservation.userId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Text(
                    'Cliente: ${snapshot.data!.name}',
                    style: const TextStyle(fontSize: 14),
                  );
                }
                return const Text('Cargando cliente...');
              },
            ),
            const SizedBox(height: 4),
            Text(
              'Check-in: ${_formatDate(reservation.checkInDate)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Check-out: ${_formatDate(reservation.checkOutDate)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Huéspedes: ${reservation.numberOfGuests}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Total: Rp ${reservation.totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            if (reservation.specialRequests?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                'Solicitudes: ${reservation.specialRequests}',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Botones de acción
            if (reservation.status != ReservationStatus.cancelled && 
                reservation.status != ReservationStatus.completed) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (reservation.status == ReservationStatus.pending) ...[
                    ElevatedButton.icon(
                      onPressed: () => _confirmReservation(reservation),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Confirmar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                  ElevatedButton.icon(
                    onPressed: () => _cancelReservation(reservation),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _confirmReservation(Reservation reservation) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Reserva'),
          content: Text('¿Estás seguro de que quieres confirmar esta reserva?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        int result = await _reservationService.confirmReservation(reservation.id!);
        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reserva confirmada exitosamente')),
          );
          _loadReservations(); // Recargar datos
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al confirmar reserva')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancelar Reserva'),
          content: Text('¿Estás seguro de que quieres cancelar esta reserva?\n\nEsta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sí, cancelar'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        int result = await _reservationService.cancelReservation(reservation.id!);
        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reserva cancelada exitosamente')),
          );
          _loadReservations(); // Recargar datos
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al cancelar reserva')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
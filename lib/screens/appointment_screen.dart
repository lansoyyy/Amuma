import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<Appointment> appointments = [
    Appointment(
      id: '1',
      title: 'Dr. Santos - Check-up',
      date: DateTime.now().add(const Duration(days: 2)),
      time: '10:00 AM',
      location: 'Medical Center Cebu',
      type: AppointmentType.checkup,
      notes: 'Bring previous lab results',
      isCompleted: false,
    ),
    Appointment(
      id: '2',
      title: 'Lab Test - Blood Chemistry',
      date: DateTime.now().add(const Duration(days: 7)),
      time: '8:00 AM',
      location: 'Hi-Precision Diagnostics',
      type: AppointmentType.labTest,
      notes: 'Fasting required - no food 8 hours before',
      isCompleted: false,
    ),
    Appointment(
      id: '3',
      title: 'Cardiologist Consultation',
      date: DateTime.now().add(const Duration(days: 14)),
      time: '2:00 PM',
      location: 'Heart Center',
      type: AppointmentType.specialist,
      notes: 'Bring ECG results',
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: TextWidget(
          text: 'Appointments',
          fontSize: 20,
          color: textLight,
          fontFamily: 'Bold',
        ),
        actions: [
          IconButton(
            onPressed: _addAppointment,
            icon: const Icon(Icons.add, color: primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar<Appointment>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
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
                weekendTextStyle: TextStyle(color: Colors.red.shade400),
                holidayTextStyle: TextStyle(color: Colors.red.shade400),
                selectedDecoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.blue.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
              ),
            ),
          ),

          // Appointments List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: _selectedDay != null
                            ? 'Appointments for ${DateFormat('MMM d, y').format(_selectedDay!)}'
                            : 'Upcoming Appointments',
                        fontSize: 16,
                        color: textLight,
                        fontFamily: 'Bold',
                      ),
                      TextButton(
                        onPressed: _showAllAppointments,
                        child: TextWidget(
                          text: 'View All',
                          fontSize: 12,
                          color: primary,
                          fontFamily: 'Medium',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _getDisplayAppointments().length,
                      itemBuilder: (context, index) {
                        final appointment = _getDisplayAppointments()[index];
                        return _buildAppointmentCard(appointment);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    return appointments
        .where((appointment) => isSameDay(appointment.date, day))
        .toList();
  }

  List<Appointment> _getDisplayAppointments() {
    if (_selectedDay != null) {
      return _getEventsForDay(_selectedDay!);
    }
    // Show next 5 upcoming appointments
    final upcoming = appointments
        .where((apt) =>
            apt.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming.take(5).toList();
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final isToday = isSameDay(appointment.date, DateTime.now());
    final isPast = appointment.date.isBefore(DateTime.now());
    final isUpcoming = appointment.date.isAfter(DateTime.now());

    Color cardColor = surface;
    Color borderColor = Colors.grey.shade200;

    if (isToday) {
      cardColor = primary.withOpacity(0.05);
      borderColor = primary.withOpacity(0.3);
    } else if (isPast && !appointment.isCompleted) {
      cardColor = Colors.red.shade50;
      borderColor = Colors.red.shade200;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(appointment.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(appointment.type),
                  color: _getTypeColor(appointment.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: appointment.title,
                      fontSize: 16,
                      color: textLight,
                      fontFamily: 'Bold',
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: textGrey, size: 14),
                        const SizedBox(width: 4),
                        TextWidget(
                          text:
                              '${DateFormat('MMM d').format(appointment.date)} • ${appointment.time}',
                          fontSize: 12,
                          color: textGrey,
                          fontFamily: 'Regular',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isToday)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextWidget(
                    text: 'TODAY',
                    fontSize: 10,
                    color: buttonText,
                    fontFamily: 'Bold',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, color: textGrey, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: TextWidget(
                  text: appointment.location,
                  fontSize: 12,
                  color: textGrey,
                  fontFamily: 'Regular',
                ),
              ),
            ],
          ),
          if (appointment.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.note, color: Colors.blue.shade600, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextWidget(
                      text: appointment.notes,
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontFamily: 'Regular',
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (!appointment.isCompleted && isUpcoming) ...[
                Expanded(
                  child: ButtonWidget(
                    label: 'Mark as Done',
                    onPressed: () => _markAppointmentComplete(appointment.id),
                    color: Colors.green,
                    height: 36,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ButtonWidget(
                    label: 'Reschedule',
                    onPressed: () => _rescheduleAppointment(appointment),
                    color: Colors.orange,
                    height: 36,
                    fontSize: 12,
                  ),
                ),
              ] else if (appointment.isCompleted) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green.shade600, size: 16),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: 'Completed',
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontFamily: 'Medium',
                      ),
                    ],
                  ),
                ),
              ] else if (isPast && !appointment.isCompleted) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade600, size: 16),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: 'Missed',
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontFamily: 'Medium',
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(AppointmentType type) {
    switch (type) {
      case AppointmentType.checkup:
        return Colors.blue.shade400;
      case AppointmentType.labTest:
        return Colors.green.shade400;
      case AppointmentType.specialist:
        return Colors.purple.shade400;
      case AppointmentType.procedure:
        return Colors.orange.shade400;
      case AppointmentType.followUp:
        return Colors.teal.shade400;
    }
  }

  IconData _getTypeIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.checkup:
        return Icons.medical_services;
      case AppointmentType.labTest:
        return Icons.science;
      case AppointmentType.specialist:
        return Icons.person_search;
      case AppointmentType.procedure:
        return Icons.healing;
      case AppointmentType.followUp:
        return Icons.follow_the_signs;
    }
  }

  void _addAppointment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Add Appointment',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Appointment scheduling coming soon!',
          fontSize: 14,
          color: textGrey,
          fontFamily: 'Regular',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'OK',
              fontSize: 14,
              color: primary,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }

  void _markAppointmentComplete(String appointmentId) {
    setState(() {
      final index = appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index != -1) {
        appointments[index].isCompleted = true;
      }
    });
  }

  void _rescheduleAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Reschedule Appointment',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Rescheduling feature coming soon!',
          fontSize: 14,
          color: textGrey,
          fontFamily: 'Regular',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'OK',
              fontSize: 14,
              color: primary,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }

  void _showAllAppointments() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'All Appointments',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Detailed appointments view coming soon!',
          fontSize: 14,
          color: textGrey,
          fontFamily: 'Regular',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'OK',
              fontSize: 14,
              color: primary,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }
}

enum AppointmentType {
  checkup,
  labTest,
  specialist,
  procedure,
  followUp,
}

class Appointment {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final String location;
  final AppointmentType type;
  final String notes;
  bool isCompleted;

  Appointment({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.type,
    required this.notes,
    required this.isCompleted,
  });
}

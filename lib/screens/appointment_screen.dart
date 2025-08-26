import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:amuma/services/firebase_service.dart';
import 'package:amuma/models/data_models.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Controllers for adding appointments
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = 'checkup';

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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
      body: StreamBuilder<List<AppointmentModel>>(
        stream: _firebaseService.getAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: healthRed,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  TextWidget(
                    text: 'Error loading appointments',
                    fontSize: 16,
                    color: textSecondary,
                    fontFamily: 'Medium',
                  ),
                ],
              ),
            );
          }

          final appointments = snapshot.data ?? [];

          return Column(
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
                child: TableCalendar<AppointmentModel>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) => _getEventsForDay(day, appointments),
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
                            onPressed: () => _showAllAppointments(appointments),
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
                        child: appointments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      color: textSecondary,
                                      size: 64,
                                    ),
                                    const SizedBox(height: 16),
                                    TextWidget(
                                      text: 'No appointments scheduled',
                                      fontSize: 18,
                                      color: textSecondary,
                                      fontFamily: 'Bold',
                                    ),
                                    const SizedBox(height: 8),
                                    TextWidget(
                                      text: 'Schedule your first appointment',
                                      fontSize: 14,
                                      color: textLight,
                                      fontFamily: 'Regular',
                                    ),
                                    const SizedBox(height: 24),
                                    ButtonWidget(
                                      label: 'Add Appointment',
                                      onPressed: _addAppointment,
                                      color: primary,
                                      width: 200,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _getDisplayAppointments(appointments)
                                    .length,
                                itemBuilder: (context, index) {
                                  final appointment = _getDisplayAppointments(
                                      appointments)[index];
                                  return _buildAppointmentCard(appointment);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<AppointmentModel> _getEventsForDay(
      DateTime day, List<AppointmentModel> appointments) {
    return appointments
        .where((appointment) => isSameDay(appointment.date, day))
        .toList();
  }

  List<AppointmentModel> _getDisplayAppointments(
      List<AppointmentModel> appointments) {
    if (_selectedDay != null) {
      return _getEventsForDay(_selectedDay!, appointments);
    }
    // Show next 5 upcoming appointments
    final upcoming = appointments
        .where((apt) =>
            apt.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming.take(5).toList();
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
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
              Row(
                children: [
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
                  const SizedBox(width: 8),
                  // Delete button
                  GestureDetector(
                    onTap: () => _deleteAppointment(appointment.id),
                    child: Icon(
                      Icons.delete_outline,
                      color: healthRed,
                      size: 16,
                    ),
                  ),
                ],
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
          if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
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
                      text: appointment.notes!,
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'checkup':
        return Colors.blue.shade400;
      case 'labTest':
        return Colors.green.shade400;
      case 'specialist':
        return Colors.purple.shade400;
      case 'procedure':
        return Colors.orange.shade400;
      case 'followUp':
        return Colors.teal.shade400;
      default:
        return Colors.blue.shade400;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'checkup':
        return Icons.medical_services;
      case 'labTest':
        return Icons.science;
      case 'specialist':
        return Icons.person_search;
      case 'procedure':
        return Icons.healing;
      case 'followUp':
        return Icons.follow_the_signs;
      default:
        return Icons.medical_services;
    }
  }

  void _addAppointment() {
    _titleController.clear();
    _locationController.clear();
    _notesController.clear();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _selectedType = 'checkup';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Add Appointment',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Appointment Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Type dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Appointment Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'checkup', child: Text('Check-up')),
                  DropdownMenuItem(value: 'labTest', child: Text('Lab Test')),
                  DropdownMenuItem(
                      value: 'specialist', child: Text('Specialist')),
                  DropdownMenuItem(
                      value: 'procedure', child: Text('Procedure')),
                  DropdownMenuItem(value: 'followUp', child: Text('Follow-up')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(DateFormat('MMM d, y').format(_selectedDate)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 8),
                            Text(_selectedTime.format(context)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Location
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: textSecondary,
              fontFamily: 'Medium',
            ),
          ),
          TextButton(
            onPressed: _saveAppointment,
            child: TextWidget(
              text: 'Save',
              fontSize: 14,
              color: primary,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in title and location'),
          backgroundColor: healthRed,
        ),
      );
      return;
    }

    final appointment = AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      time: _selectedTime.format(context),
      location: _locationController.text.trim(),
      type: _selectedType,
      notes: _notesController.text.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    final success = await _firebaseService.addAppointment(appointment);

    if (success) {
      Navigator.pop(context);

      // Log activity
      await _firebaseService.logActivity(
        'appointment',
        'Appointment scheduled: ${appointment.title}',
        data: {
          'type': appointment.type,
          'date': appointment.date.toIso8601String(),
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${appointment.title} scheduled successfully'),
          backgroundColor: healthGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to schedule appointment'),
          backgroundColor: healthRed,
        ),
      );
    }
  }

  Future<void> _markAppointmentComplete(String appointmentId) async {
    final success =
        await _firebaseService.markAppointmentCompleted(appointmentId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment marked as completed'),
          backgroundColor: healthGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update appointment'),
          backgroundColor: healthRed,
        ),
      );
    }
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Delete Appointment',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Are you sure you want to delete this appointment?',
          fontSize: 14,
          color: textGrey,
          fontFamily: 'Regular',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: textSecondary,
              fontFamily: 'Medium',
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: TextWidget(
              text: 'Delete',
              fontSize: 14,
              color: healthRed,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _firebaseService.deleteAppointment(appointmentId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment deleted successfully'),
            backgroundColor: healthGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete appointment'),
            backgroundColor: healthRed,
          ),
        );
      }
    }
  }

  void _rescheduleAppointment(AppointmentModel appointment) {
    // Set current appointment data for editing
    _titleController.text = appointment.title;
    _locationController.text = appointment.location;
    _notesController.text = appointment.notes ?? '';
    _selectedDate = appointment.date;
    _selectedTime = TimeOfDay.fromDateTime(appointment.date);
    _selectedType = appointment.type;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Reschedule Appointment',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date picker
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(DateFormat('MMM d, y').format(_selectedDate)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 8),
                            Text(_selectedTime.format(context)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: textSecondary,
              fontFamily: 'Medium',
            ),
          ),
          TextButton(
            onPressed: () => _updateAppointment(appointment.id),
            child: TextWidget(
              text: 'Update',
              fontSize: 14,
              color: primary,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAppointment(String appointmentId) async {
    final updatedAppointment = AppointmentModel(
      id: appointmentId,
      title: _titleController.text.trim(),
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      time: _selectedTime.format(context),
      location: _locationController.text.trim(),
      type: _selectedType,
      notes: _notesController.text.trim(),
      isCompleted: false,
      createdAt: DateTime.now(), // This will be ignored in update
    );

    final success = await _firebaseService.updateAppointment(
        appointmentId, updatedAppointment);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment rescheduled successfully'),
          backgroundColor: healthGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reschedule appointment'),
          backgroundColor: healthRed,
        ),
      );
    }
  }

  void _showAllAppointments(List<AppointmentModel> appointments) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: TextWidget(
              text: 'All Appointments',
              fontSize: 18,
              color: textLight,
              fontFamily: 'Bold',
            ),
            backgroundColor: surface,
          ),
          body: appointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: textSecondary,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      TextWidget(
                        text: 'No appointments scheduled',
                        fontSize: 18,
                        color: textSecondary,
                        fontFamily: 'Bold',
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(appointments[index]);
                  },
                ),
        ),
      ),
    );
  }
}

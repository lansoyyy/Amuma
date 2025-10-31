import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/services/firebase_service.dart';
import 'package:amuma/services/local_storage_service.dart';
import 'package:amuma/models/data_models.dart';
import 'package:intl/intl.dart';

class CheckInHistoryScreen extends StatefulWidget {
  const CheckInHistoryScreen({super.key});

  @override
  State<CheckInHistoryScreen> createState() => _CheckInHistoryScreenState();
}

class _CheckInHistoryScreenState extends State<CheckInHistoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final LocalStorageService _localStorageService = LocalStorageService();

  List<DateTime> _checkInHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCheckInHistory();
  }

  Future<void> _loadCheckInHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current attendance streak
      final streaks = await _firebaseService.getStreaks().first;
      final attendanceStreak = streaks.firstWhere(
        (s) => s.type == 'attendance',
        orElse: () => StreakModel(
          id: 'attendance_streak',
          type: 'attendance',
          count: 0,
          lastUpdate: DateTime.now(),
        ),
      );

      // Get last check-in date from local storage
      final lastCheckInStr =
          _localStorageService.getString('last_check_in_date');

      // For demo purposes, create a mock history based on streak count
      // In a real app, you would store all check-in dates in a database
      final List<DateTime> mockHistory = [];
      if (lastCheckInStr != null) {
        final lastCheckIn = DateTime.parse(lastCheckInStr);

        // Generate check-in history based on streak count
        for (int i = 0; i < attendanceStreak.count; i++) {
          final checkInDate = lastCheckIn
              .subtract(Duration(days: attendanceStreak.count - 1 - i));
          mockHistory.add(checkInDate);
        }
      }

      setState(() {
        _checkInHistory = mockHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Failed to load check-in history',
            fontSize: 14,
            color: Colors.white,
            fontFamily: 'Medium',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: TextWidget(
          text: 'Check-in History',
          fontSize: 20,
          color: textLight,
          fontFamily: 'Bold',
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: textLight),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _checkInHistory.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              color: textGrey,
              size: 64,
            ),
            const SizedBox(height: 16),
            TextWidget(
              text: 'No check-in history yet',
              fontSize: 18,
              color: textLight,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            TextWidget(
              text: 'Start checking in daily to build your streak!',
              fontSize: 14,
              color: textGrey,
              fontFamily: 'Regular',
              align: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: _loadCheckInHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _checkInHistory.length,
        itemBuilder: (context, index) {
          final checkInDate = _checkInHistory[index];
          final isToday = _isToday(checkInDate);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isToday ? primary.withOpacity(0.3) : Colors.grey.shade200,
                width: isToday ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isToday
                      ? primary.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isToday
                        ? primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: isToday ? primary : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: isToday
                            ? 'Today'
                            : DateFormat('EEEE, MMM d, y').format(checkInDate),
                        fontSize: 16,
                        color: textLight,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 4),
                      TextWidget(
                        text:
                            'Checked in at ${DateFormat('h:mm a').format(checkInDate)}',
                        fontSize: 12,
                        color: textGrey,
                        fontFamily: 'Regular',
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextWidget(
                      text: 'Current',
                      fontSize: 10,
                      color: Colors.white,
                      fontFamily: 'Bold',
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

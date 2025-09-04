import 'package:flutter/foundation.dart';

class BookingProvider with ChangeNotifier {
  DateTime? _selectedDate;
  int _startHour = 0;
  int _endHour = 24;
  double _totalPrice = 500.0; // Fixed price for 24-hour period
  bool _isBookingConfirmed = false;
  String _bookingId = '';

  DateTime? get selectedDate => _selectedDate;
  int get startHour => _startHour;
  int get endHour => _endHour;
  double get totalPrice => _totalPrice;
  bool get isBookingConfirmed => _isBookingConfirmed;
  String get bookingId => _bookingId;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setStartHour(int hour) {
    _startHour = hour;
    _calculatePrice();
    notifyListeners();
  }

  void setEndHour(int hour) {
    _endHour = hour;
    _calculatePrice();
    notifyListeners();
  }

  void _calculatePrice() {
    // Fixed ₹500 for any 24-hour period as per requirements
    _totalPrice = 500.0;
  }

  Future<bool> confirmBooking() async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    if (_selectedDate != null) {
      _isBookingConfirmed = true;
      _bookingId = 'NR${DateTime.now().millisecondsSinceEpoch}';
      notifyListeners();
      return true;
    }
    return false;
  }

  void resetBooking() {
    _selectedDate = null;
    _startHour = 0;
    _endHour = 24;
    _totalPrice = 500.0;
    _isBookingConfirmed = false;
    _bookingId = '';
    notifyListeners();
  }

  String getFormattedTimeSlot() {
    return '${_startHour.toString().padLeft(2, '0')}:00 - ${_endHour.toString().padLeft(2, '0')}:00';
  }
}
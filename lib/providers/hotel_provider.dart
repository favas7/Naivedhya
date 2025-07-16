import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/hotel_service.dart';

class HotelProvider with ChangeNotifier {
  final HotelService _hotelService = HotelService();

  // Form controllers
  final TextEditingController hotelNameController = TextEditingController();
  final TextEditingController hotelAddressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController managerNameController = TextEditingController();
  final TextEditingController managerEmailController = TextEditingController();
  final TextEditingController managerPhoneController = TextEditingController();

  // Form keys
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey3 = GlobalKey<FormState>();

  // State variables
  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _error;
  int _currentStep = 0;

  // Getters
  List<Hotel> get hotels => _hotels;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentStep => _currentStep;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Set current step
  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  // Clear all form controllers
  void clearAllControllers() {
    hotelNameController.clear();
    hotelAddressController.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    postalCodeController.clear();
    managerNameController.clear();
    managerEmailController.clear();
    managerPhoneController.clear();
    _currentStep = 0;
    _error = null;
    notifyListeners();
  }

  // Validate form step
  bool validateStep(int step) {
    switch (step) {
      case 0:
        return formKey1.currentState?.validate() ?? false;
      case 1:
        return formKey2.currentState?.validate() ?? false;
      case 2:
        return formKey3.currentState?.validate() ?? false;
      default:
        return false;
    }
  }

  // Create hotel
  Future<void> createHotel() async {
    try {
      _setLoading(true);
      _setError(null);

      await _hotelService.createHotel(
        hotelName: hotelNameController.text.trim(),
        hotelAddress: hotelAddressController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        country: countryController.text.trim(),
        postalCode: postalCodeController.text.trim(),
        managerName: managerNameController.text.trim(),
        managerEmail: managerEmailController.text.trim(),
        managerPhone: managerPhoneController.text.trim(),
      );

      // Clear form and refresh hotels
      clearAllControllers();
      await fetchHotels();

      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      _setError(error.toString());
      rethrow;
    }
  }

  // Fetch hotels
  Future<void> fetchHotels() async {
    try {
      _setLoading(true);
      _setError(null);

      _hotels = await _hotelService.fetchHotels();
      
      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      _setError(error.toString());
    }
  }

  // Fetch hotels by enterprise
  Future<void> fetchHotelsByEnterprise(String enterpriseId) async {
    try {
      _setLoading(true);
      _setError(null);


      
      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      _setError(error.toString());
    }
  }

  // Delete hotel
  Future<void> deleteHotel(String hotelId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _hotelService.deleteHotel(hotelId);
      await fetchHotels(); // Refresh the list

      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      _setError(error.toString());
      rethrow;
    }
  }

  // Update hotel
  Future<void> updateHotel(String hotelId, Map<String, dynamic> updates) async {
    try {
      _setLoading(true);
      _setError(null);

      await _hotelService.updateHotel(hotelId, updates);
      await fetchHotels(); // Refresh the list

      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      _setError(error.toString());
      rethrow;
    }
  }

  // Get hotel details with location and manager
  Future<Map<String, dynamic>?> getHotelDetails(String hotelId) async {
    try {
      return await _hotelService.fetchHotelWithDetails(hotelId);
    } catch (error) {
      _setError(error.toString());
      return null;
    }
  }

  // Dispose controllers
  @override
  void dispose() {
    hotelNameController.dispose();
    hotelAddressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    postalCodeController.dispose();
    managerNameController.dispose();
    managerEmailController.dispose();
    managerPhoneController.dispose();
    super.dispose();
  }
}
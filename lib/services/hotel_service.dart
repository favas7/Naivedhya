import '../models/hotel.dart';
import '../models/location.dart';
import '../models/manager.dart';
import 'database_service.dart';

class HotelService {
  static final HotelService _instance = HotelService._internal();
  factory HotelService() => _instance;
  HotelService._internal();

  final DatabaseService _dbService = DatabaseService();

  // Create a new hotel with location and manager
  Future<Hotel> createHotel({
    required String hotelName,
    required String hotelAddress,
    required String city,
    required String state,
    required String country,
    required String postalCode,
    required String managerName,
    required String managerEmail,
    required String managerPhone,
  }) async {
    try {
      // Get enterprise ID
      final enterpriseId = await _dbService.getCurrentEnterpriseId();

      // Create location
      final locationData = Location(
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
      ).toJson();

      final locationResponse = await _dbService.insertData('locations', locationData);
      final locationId = locationResponse['id'];

      // Create manager
      final managerData = Manager(
        name: managerName,
        email: managerEmail,
        phone: managerPhone,
      ).toJson();

      final managerResponse = await _dbService.insertData('managers', managerData);
      final managerId = managerResponse['id'];

      // Create hotel
      final hotelData = Hotel(
        name: hotelName,
        address: hotelAddress,
        enterpriseId: enterpriseId,
        locationId: locationId,
        managerId: managerId,
      ).toJson();

      final hotelResponse = await _dbService.insertData('hotels', hotelData);
      return Hotel.fromJson(hotelResponse);
    } catch (e) {
      throw Exception('Error creating hotel: $e');
    }
  }

  // Fetch all hotels
  Future<List<Hotel>> fetchHotels() async {
    try {
      final hotelsData = await _dbService.selectData(
        'hotels',
        orderBy: 'created_at',
        ascending: false,
      );

      return hotelsData.map((json) => Hotel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching hotels: $e');
    }
  }



  // Fetch hotel by ID
  Future<Hotel?> fetchHotelById(String hotelId) async {
    try {
      final hotelData = await _dbService.selectData(
        'hotels',
        filters: {'id': hotelId},
        limit: 1,
      );

      if (hotelData.isNotEmpty) {
        return Hotel.fromJson(hotelData.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching hotel by ID: $e');
    }
  }

  // Update hotel
  Future<Hotel> updateHotel(String hotelId, Map<String, dynamic> updates) async {
    try {
      final updatedData = await _dbService.updateData(
        'hotels',
        updates,
        {'id': hotelId},
      );

      return Hotel.fromJson(updatedData);
    } catch (e) {
      throw Exception('Error updating hotel: $e');
    }
  }

  // Delete hotel
  Future<void> deleteHotel(String hotelId) async {
    try {
      await _dbService.deleteData('hotels', {'id': hotelId});
    } catch (e) {
      throw Exception('Error deleting hotel: $e');
    }
  }

  // Fetch location by ID
  Future<Location?> fetchLocationById(String locationId) async {
    try {
      final locationData = await _dbService.selectData(
        'locations',
        filters: {'id': locationId},
        limit: 1,
      );

      if (locationData.isNotEmpty) {
        return Location.fromJson(locationData.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching location by ID: $e');
    }
  }

  // Fetch manager by ID
  Future<Manager?> fetchManagerById(String managerId) async {
    try {
      final managerData = await _dbService.selectData(
        'managers',
        filters: {'id': managerId},
        limit: 1,
      );

      if (managerData.isNotEmpty) {
        return Manager.fromJson(managerData.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching manager by ID: $e');
    }
  }

  // Fetch hotel with related data (location and manager)
  Future<Map<String, dynamic>?> fetchHotelWithDetails(String hotelId) async {
    try {
      final hotel = await fetchHotelById(hotelId);
      if (hotel == null) return null;

      final location = hotel.locationId != null 
          ? await fetchLocationById(hotel.locationId!) 
          : null;
      
      final manager = hotel.managerId != null 
          ? await fetchManagerById(hotel.managerId!) 
          : null;

      return {
        'hotel': hotel,
        'location': location,
        'manager': manager,
      };
    } catch (e) {
      throw Exception('Error fetching hotel with details: $e');
    }
  }
}
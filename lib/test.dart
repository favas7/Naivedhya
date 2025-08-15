// Add this to your project as a temporary test screen
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<String> testResults = [];
  bool isLoading = false;

  void addResult(String result) {
    setState(() {
      testResults.add("${DateTime.now().toString().substring(11, 19)}: $result");
    });
  }

  Future<void> runTests() async {
    setState(() {
      isLoading = true;
      testResults.clear();
    });

    addResult("🔍 Starting database tests...");

    // Test 1: Check authentication
    try {
      final user = _supabase.auth.currentUser;
      addResult("✅ Auth test: User = ${user?.email ?? 'No user'}");
    } catch (e) {
      addResult("❌ Auth test failed: $e");
    }

    // Test 2: Test basic connection
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .select('count')
          .count();
      addResult("✅ Connection test: Count = $response");
    } catch (e) {
      addResult("❌ Connection test failed: $e");
    }

    // Test 3: Check table structure
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .select()
          .limit(1);
      
      if (response.isNotEmpty) {
        addResult("✅ Structure test: Columns = ${response.first.keys.toList()}");
      } else {
        addResult("⚠️  Structure test: Table exists but empty");
      }
    } catch (e) {
      addResult("❌ Structure test failed: $e");
    }

    // Test 4: Try to fetch all data
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .select()
          .limit(5);
      addResult("✅ Data fetch test: Found ${response.length} records");
      
      if (response.isNotEmpty) {
        addResult("📄 First record: ${response.first}");
      }
    } catch (e) {
      addResult("❌ Data fetch test failed: $e");
    }

    // Test 5: Check specific queries
    try {
      final availableResponse = await _supabase
          .from('delivery_personnel')
          .select()
          .eq('is_available', true)
          .limit(3);
      addResult("✅ Available query test: Found ${availableResponse.length} available");
    } catch (e) {
      addResult("❌ Available query test failed: $e");
    }

    // Test 6: Check RLS policies
    try {
      final response = await _supabase.rpc('current_user_id');
      addResult("✅ RLS test: Current user ID = $response");
    } catch (e) {
      addResult("⚠️  RLS test (optional): $e");
    }

    setState(() {
      isLoading = false;
    });

    addResult("🏁 All tests completed!");
  }

  Future<void> insertTestData() async {
    setState(() {
      isLoading = true;
    });

    try {
      addResult("📝 Inserting test delivery personnel...");
      
      final testData = {
        'user_id': 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Test Delivery Person',
        'email': 'test.delivery@example.com',
        'full_name': 'Test Delivery Person Full Name',
        'phone': '1234567890',
        'state': 'Kerala',
        'city': 'Kochi',
        'aadhaar_number': '123456789012',
        'date_of_birth': '1990-01-01',
        'vehicle_type': 'Motorcycle',
        'vehicle_model': 'Honda Activa',
        'number_plate': 'KL-07-AB-1234',
        'is_available': true,
        'is_verified': true,
        'earnings': 1000.0,
        'verification_status': 'verified',
        'assigned_orders': [],
      };

      final response = await _supabase
          .from('delivery_personnel')
          .insert(testData)
          .select();

      addResult("✅ Test data inserted successfully: ${response.length} record(s)");
    } catch (e) {
      addResult("❌ Test data insertion failed: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : runTests,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isLoading ? 'Running Tests...' : 'Run Database Tests'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : insertTestData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Insert Test Data'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  testResults.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Results'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Results:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (testResults.isEmpty)
                        const Text(
                          'No tests run yet. Click "Run Database Tests" to start.',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ...testResults.map((result) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            result,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: result.contains('❌') ? Colors.red :
                                     result.contains('⚠️') ? Colors.orange :
                                     result.contains('✅') ? Colors.green :
                                     Colors.black87,
                            ),
                          ),
                        )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
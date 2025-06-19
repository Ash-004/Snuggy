import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class NfcScannerScreen extends StatefulWidget {
  const NfcScannerScreen({Key? key}) : super(key: key);

  @override
  _NfcScannerScreenState createState() => _NfcScannerScreenState();
}

class _NfcScannerScreenState extends State<NfcScannerScreen> {
  final Color teal = const Color(0xFF006D77);
  final Color background = const Color(0xFFEFF6F7);
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _rfidController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  int? _studentId;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> _lookupStudentByEmail() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a student email';
        _successMessage = null;
        _studentId = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/user/lookup?email=${_emailController.text}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _studentId = data['id'];
          _successMessage = 'Student found: ${data['name']}';
        });
      } else {
        setState(() {
          _errorMessage = 'Student not found';
          _studentId = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _studentId = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerRfid() async {
    if (_studentId == null) {
      setState(() {
        _errorMessage = 'Please lookup a student first';
        _successMessage = null;
      });
      return;
    }

    if (_rfidController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an RFID UID';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/rfid/admin/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'rfidUid': _rfidController.text.trim(),
          'studentId': _studentId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _successMessage = 'RFID registered successfully';
          _rfidController.clear();
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to register RFID: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _rfidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('NFC Scanner'),
        backgroundColor: teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/admin-dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Register RFID Tag',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Step 1: Enter student email
                    Text('Step 1: Enter Student Email', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Student Email',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _lookupStudentByEmail,
                          child: Text('Lookup'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Step 2: Scan RFID
                    Text('Step 2: Enter RFID UID', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _rfidController,
                      decoration: InputDecoration(
                        labelText: 'RFID UID',
                        border: OutlineInputBorder(),
                        hintText: 'Enter or scan RFID UID',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Note: Currently manual input only. To implement automatic scanning, add the flutter_nfc_kit package.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Register button
                    ElevatedButton(
                      onPressed: _isLoading || _studentId == null ? null : _registerRfid,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: teal,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Register RFID'),
                    ),
                    
                    // Error/Success messages
                    if (_errorMessage != null) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.red.shade100,
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ],
                    
                    if (_successMessage != null) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.green.shade100,
                        child: Text(
                          _successMessage!,
                          style: TextStyle(color: Colors.green.shade900),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Enter the student\'s email address and click "Lookup"'),
                    Text('2. Enter the RFID UID (or scan it if hardware is available)'),
                    Text('3. Click "Register RFID" to link the RFID tag to the student'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
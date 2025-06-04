// lib/core/api/api_client.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kDebugMode and defaultTargetPlatform
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For securely storing auth token

class ApiClient {
  // --- IMPORTANT: CONFIGURE FOR YOUR DEVELOPMENT SETUP ---
  //
  // Replace "YOUR_COMPUTER_LOCAL_IP_ADDRESS" with your computer's actual local IP address
  // when testing with a physical device. You mentioned yours is 10.0.0.237.
  //
  // static const String _physicalDeviceDevHost = "YOUR_COMPUTER_LOCAL_IP_ADDRESS";
  // For example, if your IP is 10.0.0.237:
  static const String _physicalDeviceDevHost = "10.0.1.69"; // <<-- UPDATE THIS WITH YOUR IP

  static const String _port = "3000"; // Your Next.js development server port

  // URLs for different development scenarios
  static const String _devBaseUrlAndroidEmulator = "http://10.0.2.2:$_port/api";
  static const String _devBaseUrliOSSimulator = "http://localhost:$_port/api";
  static const String _devBaseUrlPhysicalDevice = "http://$_physicalDeviceDevHost:$_port/api";
  
  // Replace with your actual production URL when you deploy your backend
  static const String _prodBaseUrl = "https://your_production_domain.com/api";

  // Helper to get the correct base URL based on the environment
  String get baseUrl {
    if (kReleaseMode) {
      // Production mode
      return _prodBaseUrl;
    } else {
      // Development mode
      // To explicitly test with physical device, ensure _physicalDeviceDevHost is correctly set.
      // A more robust way for physical device detection might involve passing a flag or using
      // environment variables at build time, but this heuristic works for many common cases.
      //
      // If you have a specific way you want to determine if it's a physical device test,
      // you can adjust this logic. For now, if _physicalDeviceDevHost is set to a real IP,
      // it assumes you might be using it. Otherwise, it checks platform.
      //
      // The most reliable way is often to have a build flavor or environment variable.
      // For simplicity here, we'll prioritize physical device URL if its placeholder is changed.
      if (_physicalDeviceDevHost != "YOUR_COMPUTER_LOCAL_IP_ADDRESS" && _physicalDeviceDevHost.isNotEmpty) {
         // This simple check implies you've configured it for physical device testing
         // Note: `defaultTargetPlatform` might not always distinguish physical device from emulator accurately
         // without more context (e.g. Platform.isAndroid && !isEmulator).
         // However, if you manually set your IP, this URL should be used.
        print("[ApiClient] Using configured physical device dev URL: $_devBaseUrlPhysicalDevice");
        return _devBaseUrlPhysicalDevice;
      }
      
      if (defaultTargetPlatform == TargetPlatform.android) {
        print("[ApiClient] Using Android emulator dev URL: $_devBaseUrlAndroidEmulator");
        return _devBaseUrlAndroidEmulator;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        print("[ApiClient] Using iOS simulator dev URL: $_devBaseUrliOSSimulator");
        return _devBaseUrliOSSimulator;
      } else {
        // Fallback for other desktop platforms (macOS, Windows, Linux) if running Flutter desktop
        print("[ApiClient] Using localhost dev URL (desktop/other): $_devBaseUrliOSSimulator");
        return _devBaseUrliOSSimulator;
      }
    }
  }

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    try {
      return await _secureStorage.read(key: 'authToken');
    } catch (e) {
      print("[ApiClient] Error reading token from secure storage: $e");
      return null;
    }
  }

  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    if (requiresAuth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else if (requiresAuth) {
        // This case might be an issue - trying to make an auth'd request without a token
        print("[ApiClient] Warning: Auth required but no token found.");
      }
    }
    return headers;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body, {bool requiresAuth = false}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    print('[ApiClient] POST Request to: $url');
    print('[ApiClient] POST Headers: $headers'); // For debugging auth issues
    print('[ApiClient] POST Body: ${jsonEncode(body)}');
    try {
      return await http.post(url, headers: headers, body: jsonEncode(body));
    } catch (e) {
      print('[ApiClient] POST Network Error to $url: $e');
      // Rethrow a more specific error or a custom network error
      throw Exception('Network error: Failed to connect to server. Please check your connection and API URL. ($e)');
    }
  }

  Future<http.Response> get(String endpoint, {bool requiresAuth = false, Map<String, String>? queryParams}) async {
    var urlString = '$baseUrl$endpoint';
    if (queryParams != null && queryParams.isNotEmpty) {
      urlString += '?${Uri(queryParameters: queryParams).query}';
    }
    final url = Uri.parse(urlString);
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    print('[ApiClient] GET Request to: $url');
    print('[ApiClient] GET Headers: $headers'); // For debugging auth issues
    try {
      return await http.get(url, headers: headers);
    } catch (e) {
      print('[ApiClient] GET Network Error to $url: $e');
      throw Exception('Network error: Failed to connect to server. ($e)');
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body, {bool requiresAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    print('[ApiClient] PUT Request to: $url');
    print('[ApiClient] PUT Headers: $headers'); // For debugging auth issues
    print('[ApiClient] PUT Body: ${jsonEncode(body)}');
     try {
      return await http.put(url, headers: headers, body: jsonEncode(body));
    } catch (e) {
      print('[ApiClient] PUT Network Error to $url: $e');
      throw Exception('Network error: Failed to connect to server. ($e)');
    }
  }

  Future<http.Response> delete(String endpoint, {bool requiresAuth = true}) async {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      print('[ApiClient] DELETE Request to: $url');
      print('[ApiClient] DELETE Headers: $headers'); // For debugging auth issues
      try {
        return await http.delete(url, headers: headers);
      } catch (e) {
        print('[ApiClient] DELETE Network Error to $url: $e');
        throw Exception('Network error: Failed to connect to server. ($e)');
      }
  }
}
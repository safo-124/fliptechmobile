// lib/services/category_service.dart
import 'dart:convert';
import '../core/api/api_client.dart'; // Adjust path as needed
import '../data/models/category_model.dart'; // Adjust path as needed

abstract class CategoryService {
  Future<List<Category>> getCategories({String? type});
}

class CategoryServiceImpl implements CategoryService {
  final ApiClient apiClient;

  CategoryServiceImpl({required this.apiClient});

  @override
  Future<List<Category>> getCategories({String? type}) async {
    print('[CategoryService] Fetching categories with type: $type');
    try {
      final queryParams = <String, String>{};
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      // We want a flat list for dropdowns, so hierarchy=false (or omit)
      // queryParams['hierarchy'] = 'false'; 

      final response = await apiClient.get('/categories', queryParams: queryParams);
      
      print('[CategoryService] Response Status: ${response.statusCode}');
      // print('[CategoryService] Response Body: ${response.body}'); // Can be verbose

      if (response.statusCode == 200) {
        final List<dynamic> categoryJsonList = jsonDecode(response.body);
        // The API for flat list directly returns List<CategoryJson>
        return categoryJsonList.map((json) => Category.fromJson(json)).toList();
      } else {
        String errorMessage = 'Failed to load categories.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) { /* Ignore if error response is not JSON */ }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('[CategoryService] Exception: ${e.toString()}');
      throw Exception('Error fetching categories: ${e.toString()}');
    }
  }
}
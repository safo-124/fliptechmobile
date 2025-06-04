// lib/features/products/presentation/screens/product_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Adjust paths as needed
import '../cubit/product_form_cubit.dart';
import '../../../../data/models/category_model.dart'; 
import '../../../../shared_widgets/loading_dialog.dart'; // Create this simple dialog

class ProductFormScreen extends StatefulWidget {
  // Optionally pass a ProductListing object for editing mode
  // final ProductListing? productToEdit;
  // const ProductFormScreen({super.key, this.productToEdit});

  const ProductFormScreen({super.key}); // For create mode initially

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _materialsController = TextEditingController(); // For comma-separated materials
  final _dimensionsController = TextEditingController();
  final _skuController = TextEditingController();
  final _shippingDetailsController = TextEditingController();

  String? _selectedCategoryId;
  String _selectedStatus = 'DRAFT'; // Default status

  @override
  void initState() {
    super.initState();
    // If editing, pre-fill form:
    // if (widget.productToEdit != null) {
    //   final p = widget.productToEdit!;
    //   _titleController.text = p.title;
    //   _descriptionController.text = p.description;
    //   _priceController.text = p.price.toString();
    //   _stockQuantityController.text = p.stockQuantity?.toString() ?? '';
    //   _materialsController.text = p.materials.join(', ');
    //   _dimensionsController.text = p.dimensions ?? '';
    //   _skuController.text = p.sku ?? '';
    //   _shippingDetailsController.text = p.shippingDetails ?? '';
    //   _selectedCategoryId = p.categoryId;
    //   _selectedStatus = p.status;
    //   // Handle pre-filling images if editing (more complex)
    // }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    _materialsController.dispose();
    _dimensionsController.dispose();
    _skuController.dispose();
    _shippingDetailsController.dispose();
    super.dispose();
  }

  void _submitProductForm() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      // Basic validation for category
      if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
        Fluttertoast.showToast(msg: "Please select a category.", backgroundColor: Colors.orange[700]);
        return;
      }
      
      // Image validation - ensure at least one image is picked for a new product (optional)
      // if (widget.productToEdit == null && context.read<ProductFormCubit>().selectedImages.isEmpty) {
      //   Fluttertoast.showToast(msg: "Please add at least one image.", backgroundColor: Colors.orange[700]);
      //   return;
      // }

      final productData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'currency': 'GHS', // Or from a selector if you support multiple
        'stockQuantity': int.tryParse(_stockQuantityController.text.trim()), // Nullable if empty
        'materials': _materialsController.text.trim().split(',').map((m) => m.trim()).where((m) => m.isNotEmpty).toList(),
        'dimensions': _dimensionsController.text.trim(),
        'sku': _skuController.text.trim(),
        'shippingDetails': _shippingDetailsController.text.trim(),
        'categoryId': _selectedCategoryId,
        'status': _selectedStatus.toUpperCase(),
      };
      context.read<ProductFormCubit>().createProduct(productData);
    }
  }

  Widget _buildImagePicker(BuildContext context, ProductFormState state) {
    List<XFile> currentImages = [];
    if (state is ProductFormImagesSelected) {
      currentImages = state.images;
    } else if (context.read<ProductFormCubit>().selectedImages.isNotEmpty) {
        // Fallback to cubit's internal list if state hasn't caught up (e.g., initial build after pick)
        currentImages = context.read<ProductFormCubit>().selectedImages;
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Product Images (up to 5)", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ...currentImages.map((imageFile) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(imageFile.path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: IconButton(
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        icon: Icon(Icons.remove_circle, color: Colors.redAccent[100]),
                        onPressed: () => context.read<ProductFormCubit>().removeImage(imageFile),
                      ),
                    ),
                  ],
                )),
            if (currentImages.length < 5) // Limit to 5 images
              GestureDetector(
                onTap: () => context.read<ProductFormCubit>().pickImages(multiple: true),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Icon(Icons.add_a_photo_outlined, color: Colors.grey[500], size: 30),
                ),
              ),
          ],
        ),
         if (state is ProductFormImagePicking) Padding(
           padding: const EdgeInsets.only(top: 8.0),
           child: Text("Picking images...", style: TextStyle(color: Colors.tealAccent[200])),
         ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Add New Product'), // Change to 'Edit Product' if editing
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<ProductFormCubit, ProductFormState>(
        listener: (context, state) {
          if (state is ProductFormSuccess) {
            Fluttertoast.showToast(msg: "Product created successfully!", backgroundColor: Colors.green);
            Navigator.of(context).pop(); // Go back to product list after success
          } else if (state is ProductFormError && state.message.isNotEmpty) {
            // Avoid showing toast if message is empty (e.g. from image picking error handled by UI change)
            if (!(state.message.toLowerCase().contains("failed to pick images"))){
                 Fluttertoast.showToast(msg: "Error: ${state.message}", backgroundColor: Colors.redAccent[700]);
            }
          }
        },
        builder: (context, state) {
          List<Category> categories = [];
          bool areCategoriesLoading = true;

          if (state is ProductFormCategoriesLoaded) {
            categories = state.categories;
            areCategoriesLoading = false;
          } else if (state is ProductFormError && state.categories != null) {
            categories = state.categories!; // Use categories even if other error occurred
            areCategoriesLoading = false;
          } else if (state is ProductFormImagePicking || state is ProductFormImagesSelected || state is ProductFormSubmitting || state is ProductFormSuccess){
            // Try to get categories from a previous loaded state if current state doesn't have them
             final cubit = context.read<ProductFormCubit>();
             if(cubit.state is ProductFormCategoriesLoaded) {
               categories = (cubit.state as ProductFormCategoriesLoaded).categories;
               areCategoriesLoading = false;
             } else if (cubit.state is ProductFormError && (cubit.state as ProductFormError).categories != null) {
               categories = (cubit.state as ProductFormError).categories!;
               areCategoriesLoading = false;
             }
          }


          bool isSubmitting = state is ProductFormSubmitting;
          if (isSubmitting) {
             // Optionally show a full-screen loading dialog or inline loader
             // For simplicity, the button will show a loader.
             // WidgetsBinding.instance.addPostFrameCallback((_) => LoadingDialog.show(context));
          } else {
             // WidgetsBinding.instance.addPostFrameCallback((_) => LoadingDialog.hide(context));
          }


          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    TextFormField(controller: _titleController, decoration: InputDecoration(labelText: 'Product Title', hintText: 'e.g., Handmade Kente Scarf'), validator: (v) => v!.isEmpty ? 'Title is required' : null),
                    SizedBox(height: 16),
                    // Description
                    TextFormField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Description', hintText: 'Detailed description of your product...'), maxLines: 4, validator: (v) => v!.isEmpty ? 'Description is required' : null),
                    SizedBox(height: 16),
                    // Price
                    TextFormField(controller: _priceController, decoration: InputDecoration(labelText: 'Price (GHS)', hintText: 'e.g., 50.00', prefixText: '₵ '), keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty || double.tryParse(v) == null || double.parse(v) <=0 ? 'Valid price is required' : null),
                    SizedBox(height: 16),
                    // Stock Quantity
                    TextFormField(controller: _stockQuantityController, decoration: InputDecoration(labelText: 'Stock Quantity (Optional)', hintText: 'e.g., 10'), keyboardType: TextInputType.number, validator: (v) { if (v!.isNotEmpty && int.tryParse(v) == null) return 'Must be a valid number'; return null;}),
                    SizedBox(height: 16),
                    
                    // Category Dropdown
                    if (areCategoriesLoading)
                       Column(children: [Text('Loading categories...', style: TextStyle(color: Colors.grey[400])), SizedBox(height: 10), CircularProgressIndicator(strokeWidth: 2)])
                    else if (categories.isEmpty && !areCategoriesLoading)
                       Text('No product categories found. Please add them in the admin panel.', style: TextStyle(color: Colors.orangeAccent))
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
                        hint: Text('Select a category', style: TextStyle(color: Colors.grey[500])),
                        isExpanded: true,
                        dropdownColor: Colors.grey[850],
                        style: TextStyle(color: Colors.white),
                        items: categories.map((Category category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name, style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategoryId = newValue;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Please select a category' : null,
                      ),
                    SizedBox(height: 16),

                    // Image Picker UI
                    _buildImagePicker(context, state),
                    SizedBox(height: 16),
                    
                    // Materials (comma-separated)
                    TextFormField(controller: _materialsController, decoration: InputDecoration(labelText: 'Materials (comma-separated)', hintText: 'e.g., Cotton, Beads, Dye'),),
                    SizedBox(height: 16),
                    // Dimensions
                    TextFormField(controller: _dimensionsController, decoration: InputDecoration(labelText: 'Dimensions (Optional)', hintText: 'e.g., 10cm x 5cm x 2cm'),),
                    SizedBox(height: 16),
                    // SKU
                    TextFormField(controller: _skuController, decoration: InputDecoration(labelText: 'SKU (Optional)', hintText: 'e.g., KENTE-SCARF-001'),),
                    SizedBox(height: 16),
                    // Shipping Details
                    TextFormField(controller: _shippingDetailsController, decoration: InputDecoration(labelText: 'Shipping Details (Optional)', hintText: 'e.g., Ships in 2-3 days...'), maxLines: 3,),
                    SizedBox(height: 16),

                    // Status Dropdown
                     DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
                        isExpanded: true,
                        dropdownColor: Colors.grey[850],
                        style: TextStyle(color: Colors.white),
                        items: ['DRAFT', 'ACTIVE', 'INACTIVE'].map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status.replaceAll('_', ' ').toLowerCase().capitalize(), style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if(newValue != null) {
                            setState(() { _selectedStatus = newValue; });
                          }
                        },
                      ),
                    SizedBox(height: 32),

                    ElevatedButton(
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16)),
                      ),
                      onPressed: isSubmitting ? null : _submitProductForm,
                      child: isSubmitting 
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                          : Text('Create Product'), // Update to 'Save Product' if editing
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper extension for capitalizing strings (optional)
extension StringExtension on String {
    String capitalize() {
      if (this.isEmpty) return "";
      return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
    }
}
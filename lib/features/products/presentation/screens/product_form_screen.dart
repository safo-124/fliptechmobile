// lib/features/products/presentation/screens/product_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Adjust paths as needed
import '../cubit/product_form_cubit.dart';
import '../../../../data/models/category_model.dart';
// Import StringExtension for capitalizeWords if it's in a separate utils file
// import '../../../../core/utils/string_extensions.dart';


// Helper extension for capitalizing strings (can be in a utils file)
extension StringExtension on String {
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}


class ProductFormScreen extends StatefulWidget {
  // final ProductListing? productToEdit; // For edit mode later
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
  final _materialsController = TextEditingController(); 
  final _dimensionsController = TextEditingController();
  final _skuController = TextEditingController();
  final _shippingDetailsController = TextEditingController();

  String? _selectedCategoryId;
  String _selectedStatus = 'DRAFT'; 

  @override
  void initState() {
    super.initState();
    // context.read<ProductFormCubit>().fetchCategories(); // Cubit constructor already does this
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
      if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
        Fluttertoast.showToast(msg: "Please select a product category.", backgroundColor: Colors.orange[700]);
        return;
      }
      if (context.read<ProductFormCubit>().selectedImages.isEmpty) {
         Fluttertoast.showToast(msg: "Please add at least one product image.", backgroundColor: Colors.orange[700]);
        return;
      }
      FocusScope.of(context).unfocus();

      final productData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'currency': 'GHS',
        'stockQuantity': _stockQuantityController.text.trim().isEmpty ? null : int.tryParse(_stockQuantityController.text.trim()),
        'materials': _materialsController.text.trim().split(',').map((m) => m.trim()).where((m) => m.isNotEmpty).toList(),
        'dimensions': _dimensionsController.text.trim().isNotEmpty ? _dimensionsController.text.trim() : null,
        'sku': _skuController.text.trim().isNotEmpty ? _skuController.text.trim() : null,
        'shippingDetails': _shippingDetailsController.text.trim().isNotEmpty ? _shippingDetailsController.text.trim() : null,
        'categoryId': _selectedCategoryId,
        'status': _selectedStatus.toUpperCase(),
      };
      context.read<ProductFormCubit>().createProduct(productData);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[300]),
      ),
    );
  }

  Widget _buildImagePickerUI(BuildContext context, ProductFormState currentState) {
    final List<XFile> currentImages = context.read<ProductFormCubit>().selectedImages;
    final bool isPicking = currentState is ProductFormImagePicking;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Product Images (Drag to reorder, max 5 recommended)", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[850]?.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: [
              ...currentImages.map((imageFile) => Stack(
                    clipBehavior: Clip.none,
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
                        top: -8,
                        right: -8,
                        child: InkWell(
                          onTap: () => context.read<ProductFormCubit>().removeImage(imageFile),
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  )),
              if (currentImages.length < 5)
                GestureDetector(
                  onTap: isPicking ? null : () => context.read<ProductFormCubit>().pickImages(multiple: true),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8.0),
                      // CORRECTED BORDER STYLE
                      border: Border.all(color: Colors.grey[700]!, style: BorderStyle.solid), 
                    ),
                    child: isPicking 
                        ? Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.secondary)))
                        : Icon(Icons.add_a_photo_outlined, color: Colors.grey[500], size: 30),
                  ),
                ),
            ],
          ),
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
        title: Text('List New Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.grey[900],
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<ProductFormCubit, ProductFormState>(
        listener: (context, state) {
          if (state is ProductFormSuccess) {
            Fluttertoast.showToast(msg: "Product '${state.product.title}' listed for approval!", backgroundColor: Colors.green);
            Navigator.of(context).pop(true);
          } else if (state is ProductFormError && state.message.isNotEmpty) {
            if (!(state.message.toLowerCase().contains("failed to pick images"))) {
               Fluttertoast.showToast(msg: "Error: ${state.message}", backgroundColor: Colors.redAccent[700], toastLength: Toast.LENGTH_LONG);
            }
          }
        },
        builder: (context, state) {
          List<Category> categories = [];
          bool areCategoriesLoading = true;

          // Logic to get categories from various states (as before)
          if (state is ProductFormCategoriesLoaded) {
            categories = state.categories;
            areCategoriesLoading = false;
          } else if (state is ProductFormError && state.categories != null) {
            categories = state.categories!;
            areCategoriesLoading = false;
          } else if (state is ProductFormImagePicking || state is ProductFormImagesSelected || state is ProductFormSubmitting || state is ProductFormSuccess) {
             final cubitCurrentState = context.read<ProductFormCubit>().state;
             if (cubitCurrentState is ProductFormCategoriesLoaded) categories = cubitCurrentState.categories;
             else if (cubitCurrentState is ProductFormError && cubitCurrentState.categories != null) categories = cubitCurrentState.categories!;
             areCategoriesLoading = categories.isEmpty && !(cubitCurrentState is ProductFormError && cubitCurrentState.categories != null);
          } else if (state is ProductFormInitial || state is ProductFormLoadingCategories) {
            areCategoriesLoading = true;
          }
          
          bool isSubmitting = state is ProductFormSubmitting;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle("Basic Information"),
                    TextFormField(controller: _titleController, decoration: InputDecoration(labelText: 'Product Title*', hintText: 'e.g., Handmade Beaded Necklace', prefixIcon: Icon(Icons.title_rounded, color: Colors.grey[500])), validator: (v) => v!.trim().isEmpty ? 'Title is required' : null),
                    SizedBox(height: 16),
                    TextFormField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Full Description*', hintText: 'Materials, story, care instructions...', prefixIcon: Icon(Icons.description_outlined, color: Colors.grey[500]), alignLabelWithHint: true), maxLines: 5, minLines: 3, validator: (v) => v!.trim().isEmpty ? 'Description is required' : null),
                    SizedBox(height: 16),
                    
                    if (areCategoriesLoading) 
                      Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width:16), Text('Loading product categories...', style: TextStyle(color: Colors.grey[400]))]))
                    else if (categories.isEmpty && !areCategoriesLoading) 
                      Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text('No product categories found. Please add them via the admin panel.', style: TextStyle(color: Colors.orangeAccent)))
                    else 
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(labelText: 'Product Category*', prefixIcon: Icon(Icons.category_outlined, color: Colors.grey[500])),
                        hint: Text('Select a category', style: TextStyle(color: Colors.grey[500])),
                        isExpanded: true, dropdownColor: Colors.grey[850], style: TextStyle(color: Colors.white),
                        items: categories.map((Category category) => DropdownMenuItem<String>(value: category.id, child: Text(category.name, style: TextStyle(color: Colors.white)))).toList(),
                        onChanged: (String? newValue) => setState(() => _selectedCategoryId = newValue),
                        validator: (value) => value == null || value.isEmpty ? 'Please select a category' : null,
                      ),
                    SizedBox(height: 16),

                    _buildSectionTitle("Pricing & Stock"),
                    TextFormField(controller: _priceController, decoration: InputDecoration(labelText: 'Price (GHS)*', hintText: 'e.g., 75.50', prefixText: '₵ ', prefixIcon: Icon(Icons.attach_money, color: Colors.grey[500])), keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty || double.tryParse(v.trim()) == null || double.parse(v.trim()) <=0 ? 'Valid price is required' : null),
                    SizedBox(height: 16),
                    TextFormField(controller: _stockQuantityController, decoration: InputDecoration(labelText: 'Stock Quantity (Optional)', hintText: 'e.g., 10, leave empty if unlimited/made-to-order', prefixIcon: Icon(Icons.inventory_2_outlined, color: Colors.grey[500])), keyboardType: TextInputType.number, validator: (v) { if (v!.isNotEmpty && (int.tryParse(v.trim()) == null || int.parse(v.trim()) < 0)) return 'Must be a valid non-negative number'; return null;}),
                    SizedBox(height: 16),
                    TextFormField(controller: _skuController, decoration: InputDecoration(labelText: 'SKU (Optional)', hintText: 'e.g., NECK-BD-001', prefixIcon: Icon(Icons.qr_code_scanner_outlined, color: Colors.grey[500]))),
                    SizedBox(height: 16),

                    _buildSectionTitle("Product Specifics & Images"), // Renamed section
                    _buildImagePickerUI(context, state), 
                    SizedBox(height: 16),
                    TextFormField(controller: _materialsController, decoration: InputDecoration(labelText: 'Materials (comma-separated)', hintText: 'e.g., Glass beads, Nylon thread, Silver clasp', prefixIcon: Icon(Icons.science_outlined, color: Colors.grey[500]))),
                    SizedBox(height: 16),
                    TextFormField(controller: _dimensionsController, decoration: InputDecoration(labelText: 'Dimensions (Optional)', hintText: 'e.g., Length: 45cm, Pendant: 3cm x 2cm', prefixIcon: Icon(Icons.straighten_outlined, color: Colors.grey[500]))),
                    SizedBox(height: 16),
                    TextFormField(controller: _shippingDetailsController, decoration: InputDecoration(labelText: 'Shipping Details (Optional)', hintText: 'e.g., Ships in 1-2 business days via EMS', prefixIcon: Icon(Icons.local_shipping_outlined, color: Colors.grey[500]), alignLabelWithHint: true), maxLines: 3, minLines: 2),
                    SizedBox(height: 16),

                    _buildSectionTitle("Listing Status"),
                     DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(labelText: 'Initial Listing Status', prefixIcon: Icon(Icons.toggle_on_outlined, color: Colors.grey[500])),
                        isExpanded: true, dropdownColor: Colors.grey[850], style: TextStyle(color: Colors.white),
                        items: ['DRAFT', 'PENDING_APPROVAL'].map((String status) {
                          return DropdownMenuItem<String>(value: status, child: Text(status.replaceAll('_', ' ').capitalizeWords(), style: TextStyle(color: Colors.white)));
                        }).toList(),
                        onChanged: (String? newValue) { if(newValue != null) setState(() => _selectedStatus = newValue);},
                      ),
                    SizedBox(height: 40),

                    ElevatedButton(
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16)),
                        textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                      ),
                      onPressed: isSubmitting ? null : _submitProductForm,
                      child: isSubmitting 
                          ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                          : Text('List My Product'),
                    ),
                    SizedBox(height: 20),
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
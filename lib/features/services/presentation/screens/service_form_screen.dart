// lib/features/services/presentation/screens/service_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Adjust paths as needed
import '../cubit/service_form_cubit.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/service_listing_model.dart'; // For Enums

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

class ServiceFormScreen extends StatefulWidget {
  // final ServiceListing? serviceToEdit; // For edit mode later
  const ServiceFormScreen({super.key});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _priceUnitController = TextEditingController();
  final _serviceAreaController = TextEditingController();
  final _typicalDurationController = TextEditingController();

  ServicePriceTypeEnum _selectedPriceType = ServicePriceTypeEnum.CONTACT_FOR_QUOTE;
  ServiceLocationTypeEnum _selectedLocationType = ServiceLocationTypeEnum.ARTISAN_LOCATION;
  String? _selectedCategoryId;
  String _selectedStatus = 'DRAFT'; // Default status for new service

  @override
  void initState() {
    super.initState();
    // If editing, pre-fill logic would go here
    // Fetch categories when the cubit is initialized (which it does)
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _priceUnitController.dispose();
    _serviceAreaController.dispose();
    _typicalDurationController.dispose();
    super.dispose();
  }

  void _submitServiceForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
        Fluttertoast.showToast(msg: "Please select a service category.", backgroundColor: Colors.orange[700], textColor: Colors.white);
        return;
      }
      FocusScope.of(context).unfocus();

      final serviceData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'priceType': servicePriceTypeEnumToString(_selectedPriceType), // Ensure this helper exists
        'price': _priceController.text.isNotEmpty ? double.tryParse(_priceController.text.trim()) : null,
        'priceUnit': _priceUnitController.text.trim().isNotEmpty ? _priceUnitController.text.trim() : null,
        'currency': 'GHS',
        'locationType': _selectedLocationType.toString().split('.').last, // Converts enum to string
        'serviceArea': _serviceAreaController.text.trim().isNotEmpty ? _serviceAreaController.text.trim() : null,
        'typicalDuration': _typicalDurationController.text.trim().isNotEmpty ? _typicalDurationController.text.trim() : null,
        'categoryId': _selectedCategoryId,
        'status': _selectedStatus.toUpperCase(),
        'images': [], // No images for now
      };
      context.read<ServiceFormCubit>().createService(serviceData);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0), // Increased bottom padding
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18, // Consistent section title size
          fontWeight: FontWeight.w600,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  // Helper for text form fields to maintain consistency
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    int maxLines = 1,
    int minLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText + (isOptional ? "" : "*"), // Add asterisk for required
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[500], size: 20) : null,
          alignLabelWithHint: maxLines > 1,
        ),
        style: TextStyle(color: Colors.white),
        maxLines: maxLines,
        minLines: minLines,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        validator: validator ?? (isOptional ? null : (v) => v!.trim().isEmpty ? '$labelText is required' : null),
      ),
    );
  }
  
  // Helper for dropdown form fields
  Widget _buildDropdownFormField<T>({
    required String labelText,
    T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
    String? hintText,
    IconData? prefixIcon,
    bool isOptional = false,
  }){
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText + (isOptional ? "" : "*"),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[500], size: 20) : null,
        ),
        hint: hintText != null ? Text(hintText, style: TextStyle(color: Colors.grey[500])) : null,
        isExpanded: true,
        dropdownColor: Colors.grey[850],
        style: TextStyle(color: Colors.white),
        iconEnabledColor: Colors.grey[400],
        items: items,
        onChanged: onChanged,
        validator: validator ?? (isOptional ? null : (v) => v == null ? '$labelText is required' : null),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('List New Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.grey[900],
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<ServiceFormCubit, ServiceFormState>(
        listener: (context, state) {
          if (state is ServiceFormSuccess) {
            Fluttertoast.showToast(msg: "Service listed successfully for approval!", backgroundColor: Colors.green);
            Navigator.of(context).pop(true); 
          } else if (state is ServiceFormError && state.message.isNotEmpty) {
            if (!(state.message.toLowerCase().contains("failed to pick images"))) { // This condition might be irrelevant now
              Fluttertoast.showToast(msg: "Error: ${state.message}", backgroundColor: Colors.redAccent[700], toastLength: Toast.LENGTH_LONG);
            }
          }
        },
        builder: (context, state) {
          List<Category> categories = [];
          bool areCategoriesLoading = true;

          if (state is ServiceFormCategoriesLoaded) {
            categories = state.categories;
            areCategoriesLoading = false;
          } else if (state is ServiceFormError && state.categories != null) {
            categories = state.categories!;
            areCategoriesLoading = false;
          } else {
             final cubitCurrentState = context.read<ServiceFormCubit>().state;
             if (cubitCurrentState is ServiceFormCategoriesLoaded) categories = cubitCurrentState.categories;
             else if (cubitCurrentState is ServiceFormError && cubitCurrentState.categories != null) categories = cubitCurrentState.categories!;
             areCategoriesLoading = categories.isEmpty && !(cubitCurrentState is ServiceFormError && cubitCurrentState.categories != null);
          }
          
          bool isSubmitting = state is ServiceFormSubmitting;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle("Service Information"),
                    _buildTextFormField(controller: _titleController, labelText: 'Service Title', hintText: 'e.g., Custom Tailoring for Gowns', prefixIcon: Icons.title_rounded, textCapitalization: TextCapitalization.sentences),
                    _buildTextFormField(controller: _descriptionController, labelText: 'Service Description', hintText: 'Describe the service you offer...', prefixIcon: Icons.description_outlined, minLines: 3, maxLines: 5, textCapitalization: TextCapitalization.sentences),
                    
                    if (areCategoriesLoading) 
                      Padding(padding: const EdgeInsets.symmetric(vertical: 16.0), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.secondary)), SizedBox(width:16), Text('Loading service categories...', style: TextStyle(color: Colors.grey[400]))]))
                    else if (categories.isEmpty && !areCategoriesLoading) 
                      Padding(padding: const EdgeInsets.symmetric(vertical: 16.0), child: Text('No service categories found. Add "SERVICE" type categories via admin panel.', style: TextStyle(color: Colors.orangeAccent)))
                    else 
                      _buildDropdownFormField<String>(
                        labelText: 'Service Category',
                        prefixIcon: Icons.category_outlined,
                        value: _selectedCategoryId,
                        hintText: 'Select a category',
                        items: categories.map((Category category) => DropdownMenuItem<String>(value: category.id, child: Text(category.name, style: TextStyle(color: Colors.white)))).toList(),
                        onChanged: (String? newValue) => setState(() => _selectedCategoryId = newValue),
                        validator: (value) => value == null || value.isEmpty ? 'Please select a category' : null,
                      ),

                    _buildSectionTitle("Pricing Details"),
                    _buildDropdownFormField<ServicePriceTypeEnum>(
                      labelText: 'Pricing Type',
                      prefixIcon: Icons.sell_outlined,
                      value: _selectedPriceType,
                      items: ServicePriceTypeEnum.values.map((type) {
                        return DropdownMenuItem<ServicePriceTypeEnum>(
                          value: type,
                          child: Text(servicePriceTypeEnumToString(type).replaceAll('_', ' ').capitalizeWords(), style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (ServicePriceTypeEnum? newValue) {
                        if (newValue != null) setState(() => _selectedPriceType = newValue);
                      },
                    ),

                    if (_selectedPriceType == ServicePriceTypeEnum.FIXED || 
                        _selectedPriceType == ServicePriceTypeEnum.PER_HOUR || 
                        _selectedPriceType == ServicePriceTypeEnum.PER_DAY) ...[
                      _buildTextFormField(
                        controller: _priceController, 
                        labelText: 'Price (GHS)', 
                        hintText: 'e.g., 150.00', 
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.numberWithOptions(decimal: true), 
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Price is required for this pricing type';
                          if (double.tryParse(v.trim()) == null || double.parse(v.trim()) <=0) return 'Valid positive price is required';
                          return null;
                        }
                      ),
                      if (_selectedPriceType == ServicePriceTypeEnum.PER_HOUR || _selectedPriceType == ServicePriceTypeEnum.PER_DAY)
                        _buildTextFormField(
                          controller: _priceUnitController, 
                          labelText: 'Price Unit', 
                          hintText: _selectedPriceType == ServicePriceTypeEnum.PER_HOUR ? 'e.g., per hour, per design' : 'e.g., per day, per session',
                          prefixIcon: Icons.timelapse,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Price unit is required' : null,
                        ),
                    ],
                    
                    _buildSectionTitle("Location & Duration"),
                    _buildDropdownFormField<ServiceLocationTypeEnum>(
                      labelText: 'Service Delivery',
                      prefixIcon: Icons.location_on_outlined,
                      value: _selectedLocationType,
                       items: ServiceLocationTypeEnum.values.map((type) {
                        return DropdownMenuItem<ServiceLocationTypeEnum>(
                          value: type,
                          child: Text(type.toString().split('.').last.replaceAll('_', ' ').capitalizeWords(), style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (ServiceLocationTypeEnum? newValue) {
                        if (newValue != null) setState(() => _selectedLocationType = newValue);
                      },
                    ),

                    if (_selectedLocationType == ServiceLocationTypeEnum.ON_SITE)
                      _buildTextFormField(
                        controller: _serviceAreaController, 
                        labelText: 'Service Area / Regions', 
                        hintText: 'e.g., Accra, Tema; or "Nationwide"', 
                        prefixIcon: Icons.map_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Service area is required for on-site services' : null
                      ),

                    _buildTextFormField(
                      controller: _typicalDurationController, 
                      labelText: 'Typical Duration', 
                      hintText: 'e.g., 2-3 hours, 1 week',
                      prefixIcon: Icons.timer_outlined,
                      isOptional: true // Make this optional by not providing a default validator
                    ),
                                        
                    _buildSectionTitle("Listing Control"),
                     _buildDropdownFormField<String>(
                        labelText: 'Initial Status',
                        prefixIcon: Icons.toggle_on_outlined,
                        value: _selectedStatus,
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
                      onPressed: isSubmitting ? null : _submitServiceForm,
                      child: isSubmitting 
                          ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                          : Text('List My Service'),
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
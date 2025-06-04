// lib/features/services/presentation/widgets/artisan_service_card.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../data/models/service_listing_model.dart'; // Adjust path

// Helper to capitalize strings (can be in a utils file)
extension StringExtension on String {
    String capitalizeWords() {
      if (this.isEmpty) return this;
      return this.split(' ').map((word) {
        if (word.isEmpty) return '';
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }
}


class ArtisanServiceCard extends StatelessWidget {
  final ServiceListing service;

  const ArtisanServiceCard({super.key, required this.service});

  void _showToast(String message) {
      Fluttertoast.showToast(msg: message);
  }

  Color _getStatusColor(String status, BuildContext context) {
    // ... (same _getStatusColor helper as in ArtisanProductCard)
    switch (status.toUpperCase()) {
      case 'ACTIVE': return Colors.greenAccent[400]!;
      case 'DRAFT': return Colors.blueAccent[100]!;
      case 'INACTIVE': return Colors.orangeAccent[100]!;
      case 'PENDING_APPROVAL': return Colors.yellowAccent[400]!;
      case 'REJECTED': return Colors.redAccent[100]!;
      default: return Colors.grey[500]!;
    }
  }

  String _formatPrice(BuildContext context) {
    switch (service.priceType) {
      case ServicePriceTypeEnum.FIXED:
      case ServicePriceTypeEnum.PER_HOUR:
      case ServicePriceTypeEnum.PER_DAY:
        return '${service.currency} ${service.price?.toStringAsFixed(2) ?? 'N/A'}${service.priceUnit != null ? "/${service.priceUnit}" : ""}';
      case ServicePriceTypeEnum.CONTACT_FOR_QUOTE:
        return 'Contact for Quote';
      case ServicePriceTypeEnum.PROJECT_BASED:
        return 'Project-Based Price';
      default:
        return 'N/A';
    }
  }


  @override
  Widget build(BuildContext context) {
    String displayImageUrl = service.images.isNotEmpty 
        ? service.images[0] 
        : 'https://via.placeholder.com/300x200.png?text=Service';

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      color: Colors.grey[850],
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.images.isNotEmpty)
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Image.network(
                displayImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Center(child: Icon(Icons.construction_outlined, color: Colors.grey[600], size: 40)),
                // ... (loadingBuilder as in ArtisanProductCard)
              ),
            )
          else
            Container( // Placeholder if no image
              height: 100,
              width: double.infinity,
              color: Colors.grey[800],
              child: Center(child: Icon(Icons.construction_sharp, color: Colors.grey[600], size: 40)),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  _formatPrice(context),
                  style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Location: ${service.locationType.toString().split('.').last.replaceAll('_', ' ').capitalizeWords()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                 if (service.serviceArea != null && service.serviceArea!.isNotEmpty)
                  Text(
                    'Area: ${service.serviceArea}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 6),
                Chip(
                  label: Text(
                    service.status.replaceAll('_', ' ').toLowerCase().capitalizeWords(), 
                    style: TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w600)
                  ),
                  backgroundColor: _getStatusColor(service.status, context).withOpacity(0.8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[700], thickness: 0.5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blueAccent[100]),
                  label: Text('Edit', style: TextStyle(color: Colors.blueAccent[100], fontSize: 13, fontWeight: FontWeight.normal)),
                  onPressed: () { /* TODO: Navigate to Edit Service Screen */ _showToast('Edit ${service.title} (TBD)'); },
                ),
                TextButton.icon(
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.redAccent[100]),
                  label: Text('Delete', style: TextStyle(color: Colors.redAccent[100], fontSize: 13, fontWeight: FontWeight.normal)),
                  onPressed: () { /* TODO: Show delete confirmation */ _showToast('Delete ${service.title} (TBD)'); },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
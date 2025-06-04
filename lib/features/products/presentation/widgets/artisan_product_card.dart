// lib/features/products/presentation/widgets/artisan_product_card.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // For placeholder actions
import '../../../../data/models/product_listing_model.dart'; // Adjust path

class ArtisanProductCard extends StatelessWidget {
  final ProductListing product;

  const ArtisanProductCard({super.key, required this.product});

  void _showToast(String message) {
      Fluttertoast.showToast(msg: message, gravity: ToastGravity.BOTTOM);
  }

  Color _getStatusColor(String status, BuildContext context) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.greenAccent[400]!;
      case 'DRAFT':
        return Colors.blueAccent[100]!;
      case 'INACTIVE':
        return Colors.orangeAccent[100]!;
      case 'PENDING_APPROVAL':
        return Colors.yellowAccent[400]!;
      case 'REJECTED':
        return Colors.redAccent[100]!;
      default:
        return Colors.grey[500]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayImageUrl = product.images.isNotEmpty 
        ? product.images[0] 
        : 'https://via.placeholder.com/300x200.png?text=No+Image'; // Placeholder

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      color: Colors.grey[850], // Dark card background
      clipBehavior: Clip.antiAlias, // Ensures image corners are rounded with card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150, // Fixed height for the image
            width: double.infinity,
            child: Image.network(
              displayImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                Container(
                  color: Colors.grey[800],
                  child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey[600], size: 40)),
                ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[800],
                  child: Center(child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  )),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${product.currency} ${product.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        product.status.replaceAll('_', ' ').toLowerCase().capitalize(), 
                        style: TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w600)
                      ),
                      backgroundColor: _getStatusColor(product.status, context).withOpacity(0.8),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      labelPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    Text(
                      'Stock: ${product.stockQuantity ?? 'N/A'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
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
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    // TODO: Navigate to Edit Product Screen with product.id
                    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductFormScreen(productToEdit: product)));
                    _showToast('Edit "${product.title}" (TBD)');
                  },
                ),
                TextButton.icon(
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.redAccent[100]),
                  label: Text('Delete', style: TextStyle(color: Colors.redAccent[100], fontSize: 13, fontWeight: FontWeight.normal)),
                   style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    // TODO: Show delete confirmation dialog then call delete API
                    _showToast('Delete "${product.title}" (TBD)');
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Helper extension for capitalizing strings
extension StringExtension on String {
    String capitalize() {
      if (this.isEmpty) return this;
      if (this.length == 1) return this.toUpperCase();
      return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
    }
}
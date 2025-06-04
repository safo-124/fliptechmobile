// lib/shared_widgets/product_card_skeleton.dart
import 'package:flutter/material.dart';
// Assuming your Skeleton widget is here or from a package:
import '../components/ui/skeleton.dart'; // If you have a custom or Shadcn-like Skeleton
// If you don't have a specific Skeleton widget, you can use Containers with grey color.

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0, // Subtle elevation
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      color: Colors.grey[850], // Dark card background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // Consistent rounding
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(height: 140, width: double.infinity, radius: 6), // Image placeholder
            SizedBox(height: 10),
            Skeleton(height: 16, width: MediaQuery.of(context).size.width * 0.6, radius: 4), // Title
            SizedBox(height: 6),
            Skeleton(height: 14, width: MediaQuery.of(context).size.width * 0.3, radius: 4), // Price
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton(height: 20, width: 60, radius: 10), // Status chip
                Skeleton(height: 12, width: 70, radius: 4),  // Stock
              ],
            ),
             SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Skeleton(height: 30, width: 70, radius: 6), // Edit button
                SizedBox(width: 8),
                Skeleton(height: 30, width: 70, radius: 6), // Delete button
              ],
            )
          ],
        ),
      ),
    );
  }
}
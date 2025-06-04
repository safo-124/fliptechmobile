// lib/shared_widgets/service_card_skeleton.dart
import 'package:flutter/material.dart';
import '../components/ui/skeleton.dart'; // Assuming your path to Skeleton

class ServiceCardSkeleton extends StatelessWidget {
  const ServiceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(height: 100, width: double.infinity, radius: 6), // Image placeholder
            SizedBox(height: 10),
            Skeleton(height: 16, width: MediaQuery.of(context).size.width * 0.7, radius: 4), // Title
            SizedBox(height: 6),
            Skeleton(height: 14, width: MediaQuery.of(context).size.width * 0.4, radius: 4), // Price Type / Location
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton(height: 20, width: 60, radius: 10), // Status chip
                Skeleton(height: 12, width: 70, radius: 4),  // Duration
              ],
            ),
             SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Skeleton(height: 30, width: 70, radius: 6), 
                SizedBox(width: 8),
                Skeleton(height: 30, width: 70, radius: 6), 
              ],
            )
          ],
        ),
      ),
    );
  }
}
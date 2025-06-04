// lib/components/ui/skeleton.dart
import 'package:flutter/material.dart';

class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    this.height,
    this.width,
    this.radius = 4.0, // Default corner radius
    this.color,
    this.margin = EdgeInsets.zero,
  });

  final double? height;
  final double? width;
  final double radius;
  final Color? color;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    // Use a color that fits your dark theme.
    // Colors.grey[800] or a slightly lighter shade of your dark background elements.
    final baseColor = color ?? Colors.grey[800]; // Default skeleton color

    return Container(
      margin: margin,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      // You could add a shimmer animation here later using a package like `shimmer`
      // child: Shimmer.fromColors(
      //   baseColor: baseColor!,
      //   highlightColor: Colors.grey[700]!, // Or a slightly lighter shade
      //   child: Container(
      //     decoration: BoxDecoration(
      //       color: Colors.white, // This color is what the shimmer "shines" on
      //       borderRadius: BorderRadius.all(Radius.circular(radius)),
      //     ),
      //   ),
      // ),
    );
  }
}
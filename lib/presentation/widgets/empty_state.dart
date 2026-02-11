import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({super.key, required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppDimensions.iconLg, color: AppColors.inkSoft),
          SizedBox(height: AppDimensions.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: AppDimensions.textSm),
          ),
        ],
      ),
    );
  }
}

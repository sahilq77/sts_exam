import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stsexam/utility/app_images.dart';
import '../../app_colors.dart';
import '../../controller/bottomnavigation/bottom_navigation_controller.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavigationController());
    return Container(
      height: 70.0,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              assetPath: AppImages.homeIcon,
              label: 'Home',
              controller: controller,
            ),
            _buildNavItem(
              index: 1,
              assetPath: AppImages.resultIcon,
              label: 'Result',
              controller: controller,
            ),
            _buildNavItem(
              index: 2,
              assetPath: AppImages.receiptIcon,
              label: 'Payment Receipt',
              controller: controller,
            ),
            _buildNavItem(
              index: 3,
              assetPath: AppImages.profileIcon,
              label: 'My Profile',
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String assetPath,
    required String label,
    required BottomNavigationController controller,
  }) {
    final isSelected = controller.selectedIndex.value == index;
    final iconColor = isSelected ? AppColors.primaryColor : Colors.grey;
    final textColor = isSelected ? AppColors.primaryColor : Colors.grey;
    final fontWeight = isSelected ? FontWeight.w600 : FontWeight.normal;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              assetPath,
              width: 20.0,
              height: 20.0,
              color: iconColor,
              colorBlendMode: BlendMode.srcIn,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.error, size: 20.0, color: Colors.red),
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12.0,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const CustomBottomNavBar({
    super.key,
    this.currentIndex = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF001919),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem('images/icons/home_Bottom.png', 'images/icons/selectedHome_Bottom.png', 0),
              const SizedBox(width: 30),
              _buildNavItem('images/icons/settings_Bottom.png', 'images/icons/selectedSettings_Bottom.png', 3),
            ],
          ),
          Positioned(
            top: -35,
            left: 0,
            right: 0,
            child: Center(
              child: _buildTrainingNavItem(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String iconPath, String selectedIconPath, int index) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Image.asset(
        isSelected ? selectedIconPath : iconPath,
        width: 30,
        height: 30,
        color: isSelected ? const Color(0xFF65EAE8) : Colors.white,
      ),
    );
  }

  Widget _buildTrainingNavItem() {
    final bool isSelected = currentIndex == 1;
    return GestureDetector(
      onTap: () => onTap(1),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF001919),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF001919),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Color(0xFF001919) : Color(0xFF001919),
                width: 1,
              ),
            ),
            child: Center(
              child: Image.asset(
                isSelected ? 'images/icons/selectedTraining_Bottom.png' : 'images/icons/Training_Bottom.png',
                width: 70,
                height: 70,
                color: isSelected ? const Color(0xFF65EAE8) : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
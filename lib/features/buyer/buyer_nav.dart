import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'buyer_home_screen.dart';

class BuyerNav extends StatefulWidget {
  const BuyerNav({super.key});

  @override
  State<BuyerNav> createState() => _BuyerNavState();
}

class _BuyerNavState extends State<BuyerNav> {
  int _currentIndex = 0;

  static const Color primaryGreen = Color(0xFF1E633F);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const BuyerHomeScreen(),
      _buildPlaceholderScreen("আমার দর"),
      _buildPlaceholderScreen("ফসল খুঁজুন"),
      _buildPlaceholderScreen("চ্যাট"),
      _buildPlaceholderScreen("প্রোফাইল"),
    ];
  }

  Widget _buildPlaceholderScreen(String title) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F0),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Center(
        child: Text(
          "$title স্ক্রিন শীঘ্রই আসছে...",
          style: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _navItems = const [
    {"label": "হোম", "icon": Icons.home_rounded, "unselectedIcon": Icons.home_outlined},
    {"label": "আমার দর", "icon": Icons.receipt_long_rounded, "unselectedIcon": Icons.receipt_long_outlined},
    {"label": "ফসল খুঁজুন", "icon": Icons.search_rounded, "unselectedIcon": Icons.search_outlined},
    {"label": "চ্যাট", "icon": Icons.chat_bubble_rounded, "unselectedIcon": Icons.chat_bubble_outline_rounded},
    {"label": "প্রোফাইল", "icon": Icons.person_rounded, "unselectedIcon": Icons.person_outline_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: const Border(
            top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final isSelected = _currentIndex == index;
                final item = _navItems[index];

                return InkWell(
                  onTap: () => setState(() => _currentIndex = index),
                  borderRadius: BorderRadius.circular(16.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF0FDF4) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected
                              ? item["icon"] as IconData
                              : item["unselectedIcon"] as IconData,
                          color: isSelected ? primaryGreen : const Color(0xFF9CA3AF),
                          size: 24.sp,
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          item["label"] as String,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? primaryGreen : const Color(0xFF6B7280),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: EdgeInsets.only(top: 2.h),
                            width: 4.w,
                            height: 4.w,
                            decoration: const BoxDecoration(
                              color: primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          SizedBox(height: 4.w),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

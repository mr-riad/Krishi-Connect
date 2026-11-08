import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi_connect/features/login_screen.dart';
import 'package:krishi_connect/helpers/all_routes.dart';
import 'package:krishi_connect/helpers/navigation_service.dart';

import '../../gen/colors.gen.dart';

class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({super.key});

  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
                decoration: const BoxDecoration(color: primaryGreen),
                child: Column(
                  children: [
                    Container(
                      width: 82.w,
                      height: 82.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 46.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'মো: আলম হোসেন',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 14.sp,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'আলম ট্রেডার্স',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'ক্রেতা',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat('৮', 'সক্রিয় দর'),
                        _buildDivider(),
                        _buildStat('৪৫', 'মোট চ্যাট'),
                        _buildDivider(),
                        _buildStat('১২', 'কেনা ফসল'),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ব্যবসার তথ্য',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildInfoCard([
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'মোবাইল',
                        '01812-345678',
                      ),
                      _buildInfoRow(
                        Icons.store_outlined,
                        'ব্যবসার নাম',
                        'আলম ট্রেডার্স',
                      ),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'জেলা',
                        'রাজশাহী',
                      ),
                      _buildInfoRow(
                        Icons.category_outlined,
                        'ব্যবসার ধরন',
                        'শস্য ক্রয়-বিক্রয়',
                      ),
                    ]),

                    SizedBox(height: 20.h),

                    Text(
                      'সেটিংস',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    _buildMenuCard([
                      _buildMenuItem(
                        Icons.edit_outlined,
                        'প্রোফাইল সম্পাদনা',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        Icons.notifications_outlined,
                        'নোটিফিকেশন',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        Icons.history_rounded,
                        'ক্রয়ের ইতিহাস',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        Icons.help_outline_rounded,
                        'সাহায্য',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        Icons.logout_rounded,
                        'লগআউট',
                        isDestructive: true,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              title: Text(
                                'লগআউট?',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              content: Text(
                                'আপনি কি লগআউট করতে চান?',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('না'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    NavigationService.navigateTo(
                                      Routes.loginScreen,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                  child: const Text('হ্যাঁ, লগআউট'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ]),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36.h,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: primaryGreen),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label, {
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isDestructive
                  ? Colors.red.shade500
                  : const Color(0xFF374151),
            ),
            SizedBox(width: 14.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDestructive
                    ? Colors.red.shade600
                    : const Color(0xFF111827),
              ),
            ),
            const Spacer(),
            if (!isDestructive)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: const Color(0xFFD1D5DB),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi_connect/helpers/all_routes.dart';
import 'package:krishi_connect/helpers/navigation_service.dart';

import '../../gen/colors.gen.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

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
              // Profile Header Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
                decoration: const BoxDecoration(color: primaryGreen),
                child: Column(
                  children: [
                    // Avatar
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
                      'মো: রফিকুল ইসলাম',
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
                          Icons.location_on_outlined,
                          size: 14.sp,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'বাগমারা, রাজশাহী',
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
                        'কৃষক',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildProfileStat('৫', 'মোট পোস্ট'),
                        _buildDivider(),
                        _buildProfileStat('১২', 'মোট কল'),
                        _buildDivider(),
                        _buildProfileStat('৩', 'সক্রিয়'),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Info Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ব্যক্তিগত তথ্য',
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
                        '01712-345678',
                      ),
                      _buildInfoRow(Icons.map_outlined, 'জেলা', 'রাজশাহী'),
                      _buildInfoRow(
                        Icons.location_city_outlined,
                        'উপজেলা',
                        'বাগমারা',
                      ),
                      _buildInfoRow(
                        Icons.agriculture_outlined,
                        'জমির পরিমাণ',
                        '৩ বিঘা',
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

                    // Menu Items
                    _buildMenuCard([
                      _buildMenuItem(
                        Icons.edit_outlined,
                        'প্রোফাইল সম্পাদনা',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        Icons.notifications_outlined,
                        'নোটিফিকেশন সেটিংস',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        Icons.language_outlined,
                        'ভাষা পরিবর্তন',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        Icons.help_outline_rounded,
                        'সাহায্য ও সহায়তা',
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

  Widget _buildProfileStat(String value, String label) {
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

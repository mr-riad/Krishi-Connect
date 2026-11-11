import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  int _selectedSeason = 0;
  final List<String> _seasons = ['রবি', 'খরিফ-১', 'খরিফ-২'];

  final List<Map<String, dynamic>> _seasonData = [
    {
      'season': 'রবি',
      'months': 'নভেম্বর – মার্চ',
      'current': 'ডিসেম্বর',
      'tip': 'এখন চাষের উপযুক্ত',
      'crops': [
        {'name': 'গম', 'sow': 'নভেম্বর–ডিসেম্বর', 'harvest': 'মার্চ–এপ্রিল', 'icon': '🌾'},
        {'name': 'সরিষা', 'sow': 'অক্টোবর–নভেম্বর', 'harvest': 'ফেব্রুয়ারি–মার্চ', 'icon': '🌻'},
        {'name': 'আলু', 'sow': 'অক্টোবর–নভেম্বর', 'harvest': 'জানুয়ারি–ফেব্রুয়ারি', 'icon': '🥔'},
        {'name': 'মসুর', 'sow': 'অক্টোবর–নভেম্বর', 'harvest': 'মার্চ–এপ্রিল', 'icon': '🫘'},
        {'name': 'পেঁয়াজ', 'sow': 'নভেম্বর–ডিসেম্বর', 'harvest': 'মার্চ–এপ্রিল', 'icon': '🧅'},
      ],
    },
    {
      'season': 'খরিফ-১',
      'months': 'মার্চ – জুন',
      'current': 'এপ্রিল',
      'tip': 'এখন বপন সময়',
      'crops': [
        {'name': 'আউশ ধান', 'sow': 'মার্চ–এপ্রিল', 'harvest': 'জুলাই–আগস্ট', 'icon': '🌾'},
        {'name': 'মুগ', 'sow': 'ফেব্রুয়ারি–মার্চ', 'harvest': 'মে–জুন', 'icon': '🫘'},
        {'name': 'তিল', 'sow': 'মার্চ–এপ্রিল', 'harvest': 'জুন–জুলাই', 'icon': '🌿'},
        {'name': 'গ্রীষ্মকালীন সবজি', 'sow': 'ফেব্রুয়ারি–মার্চ', 'harvest': 'মে–জুলাই', 'icon': '🥦'},
      ],
    },
    {
      'season': 'খরিফ-২',
      'months': 'জুন – নভেম্বর',
      'current': 'আগস্ট',
      'tip': 'আমন মৌসুম চলছে',
      'crops': [
        {'name': 'আমন ধান', 'sow': 'জুন–আগস্ট', 'harvest': 'নভেম্বর–ডিসেম্বর', 'icon': '🌾'},
        {'name': 'আখ', 'sow': 'জানুয়ারি–মার্চ', 'harvest': 'নভেম্বর–মার্চ', 'icon': '🎋'},
        {'name': 'শীতকালীন সবজি বপন', 'sow': 'আগস্ট–সেপ্টেম্বর', 'harvest': 'নভেম্বর–জানুয়ারি', 'icon': '🥬'},
        {'name': 'পাট', 'sow': 'মার্চ–মে', 'harvest': 'জুলাই–আগস্ট', 'icon': '🪢'},
      ],
    },
  ];

  Map<String, dynamic> get _current => _seasonData[_selectedSeason];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Padding(
              padding: EdgeInsets.only(right: 16.w, top: 12.h),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'F-08 · কৃষক',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: primaryGreen,
                    ),
                  ),
                ),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'মৌসুমি ফসল ক্যালেন্ডার',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),

            // Season Tabs
            SizedBox(
              height: 40.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _seasons.length,
                separatorBuilder: (context, index) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final isSelected = _selectedSeason == index;
                  return InkWell(
                    onTap: () => setState(() => _selectedSeason = index),
                    borderRadius: BorderRadius.circular(20.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected ? primaryGreen : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        _seasons[index],
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 14.h),

            // Season Info Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: primaryGreen.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: primaryGreen, size: 18.sp),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _current['tip'],
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          _current['current'],
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      _current['months'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Crops list
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: (_current['crops'] as List).length,
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final crop = (_current['crops'] as List)[index] as Map<String, dynamic>;
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Text(crop['icon'], style: TextStyle(fontSize: 28.sp)),
                        SizedBox(width: 14.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crop['name'],
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'বপন: ${crop['sow']}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              'কাটা: ${crop['harvest']}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

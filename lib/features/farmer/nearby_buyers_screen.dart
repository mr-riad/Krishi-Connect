import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';

class NearbyBuyersScreen extends StatefulWidget {
  const NearbyBuyersScreen({super.key});

  @override
  State<NearbyBuyersScreen> createState() => _NearbyBuyersScreenState();
}

class _NearbyBuyersScreenState extends State<NearbyBuyersScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final List<Map<String, dynamic>> _entries = [
    {
      'name': 'রহিম ট্রেডার্স',
      'type': 'ক্রেতা',
      'distance': '২.৩',
      'crop': 'ধান, গম',
      'phone': '০১৭১১-১২৩৪৫৬',
    },
    {
      'name': 'বাগমারা হাট',
      'type': 'বাজার',
      'distance': '৩.৮',
      'crop': 'সব ধরনের ফসল',
      'phone': '',
    },
    {
      'name': 'আলম এন্টারপ্রাইজ',
      'type': 'ক্রেতা',
      'distance': '৫.১',
      'crop': 'সবজি, ফল',
      'phone': '০১৮২২-৯৮৭৬৫৪',
    },
    {
      'name': 'তানোর কৃষি বাজার',
      'type': 'বাজার',
      'distance': '৬.৭',
      'crop': 'সব ধরনের ফসল',
      'phone': '',
    },
    {
      'name': 'করিম ফ্রেশ',
      'type': 'ক্রেতা',
      'distance': '৮.২',
      'crop': 'আলু, পেঁয়াজ',
      'phone': '০১৯৩৩-৫৫৪৪৩৩',
    },
  ];

  void _call(Map<String, dynamic> entry) {
    if (entry['phone'] == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${entry['name']}-এর যোগাযোগ নম্বর পাওয়া যায়নি'),
          backgroundColor: Colors.grey.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${entry['name']}-কে কল করা হচ্ছে: ${entry['phone']}'),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
                    'F-05 · কৃষক',
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
                    'কাছের ক্রেতা ও বাজার',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),

            // Filter chips (জেলা / উপজেলা)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: ['জেলা', 'উপজেলা'].map((label) {
                  return Container(
                    margin: EdgeInsets.only(right: 10.w),
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 12.h),

            // Map placeholder
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                width: double.infinity,
                height: 150.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 40.sp, color: primaryGreen.withValues(alpha: 0.5)),
                    SizedBox(height: 8.h),
                    Text(
                      'ম্যাপ',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryGreen.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      'GPS সক্রিয় করুন',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Buyers & Markets list
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _entries.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  final isBuyer = entry['type'] == 'ক্রেতা';
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.025),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 46.w,
                          height: 46.w,
                          decoration: BoxDecoration(
                            color: isBuyer ? const Color(0xFFF0FDF4) : const Color(0xFFFEF3C7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isBuyer ? Icons.person_rounded : Icons.storefront_rounded,
                            color: isBuyer ? primaryGreen : const Color(0xFFD97706),
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry['name'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                '${entry['distance']} কিমি · ${entry['crop']}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Call Button
                        GestureDetector(
                          onTap: () => _call(entry),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: primaryGreen,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.phone_rounded, size: 14.sp, color: Colors.white),
                                SizedBox(width: 4.w),
                                Text(
                                  'কল',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

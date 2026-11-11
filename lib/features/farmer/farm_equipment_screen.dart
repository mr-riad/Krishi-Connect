import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';
import '../../helpers/call_helper.dart';

class FarmEquipmentScreen extends StatefulWidget {
  const FarmEquipmentScreen({super.key});

  @override
  State<FarmEquipmentScreen> createState() => _FarmEquipmentScreenState();
}

class _FarmEquipmentScreenState extends State<FarmEquipmentScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['ট্রাক্টর', 'হারভেস্টার', 'পাওয়ার টিলার'];

  final List<Map<String, dynamic>> _equipment = [
    {
      'name': 'জনতা ট্রাক্টর সার্ভিস',
      'owner': 'রফিকুল ইসলাম',
      'upazila': 'বাগমারা',
      'rate': '৮০০',
      'unit': 'বিঘা/দিন',
      'type': 0,
      'phone': '01712-345678',
      'available': true,
    },
    {
      'name': 'সোনালী ট্রাক্টর',
      'owner': 'আবুল কাসেম',
      'upazila': 'গোদাগাড়ী',
      'rate': '৭৫০',
      'unit': 'বিঘা/দিন',
      'type': 0,
      'phone': '01819-234567',
      'available': true,
    },
    {
      'name': 'আধুনিক হারভেস্টার',
      'owner': 'মুকুল মিয়া',
      'upazila': 'তানোর',
      'rate': '৩,৫০০',
      'unit': 'বিঘা',
      'type': 1,
      'phone': '01723-456789',
      'available': false,
    },
    {
      'name': 'কৃষি হারভেস্টার সার্ভিস',
      'owner': 'শামসুল হক',
      'upazila': 'পবা',
      'rate': '৩,২০০',
      'unit': 'বিঘা',
      'type': 1,
      'phone': '01918-765432',
      'available': true,
    },
    {
      'name': 'গ্রামীণ পাওয়ার টিলার',
      'owner': 'জয়নাল আবেদিন',
      'upazila': 'মোহনপুর',
      'rate': '৪৫০',
      'unit': 'বিঘা/দিন',
      'type': 2,
      'phone': '01714-223344',
      'available': true,
    },
    {
      'name': 'রহিম পাওয়ার টিলার',
      'owner': 'আব্দুর রহিম',
      'upazila': 'দুর্গাপুর',
      'rate': '৪০০',
      'unit': 'বিঘা/দিন',
      'type': 2,
      'phone': '01815-334455',
      'available': true,
    },
  ];

  List<Map<String, dynamic>> get _filtered =>
      _equipment.where((e) => e['type'] == _selectedCategoryIndex).toList();

  void _showCallSheet(Map<String, dynamic> item) {
    showDirectCallBottomSheet(
      context: context,
      name: item['owner'] as String,
      phone: (item['phone'] ?? '01712-345678') as String,
      roleOrType: 'যন্ত্রের মালিক',
      subtitle: "${item['name']} · ভাড়া: ৳${item['rate']} / ${item['unit']}",
      location: item['upazila'] as String?,
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
                    'F-10 · কৃষক',
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
                    'কৃষি যন্ত্রপাতি',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),

            // Category Chips
            SizedBox(
              height: 40.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategoryIndex = index),
                    borderRadius: BorderRadius.circular(20.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected ? primaryGreen : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        _categories[index],
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

            // List
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _filtered.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = _filtered[index];
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
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0FDF4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.agriculture_rounded, color: primaryGreen, size: 22.sp),
                        ),
                        SizedBox(width: 12.w),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                '${item['owner']} · ${item['upazila']}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                'ভাড়া ৳${item['rate']} / ${item['unit']}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Call Button
                        GestureDetector(
                          onTap: () => _showCallSheet(item),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: item['available'] as bool ? primaryGreen : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.phone_in_talk_rounded, size: 14.sp, color: Colors.white),
                                SizedBox(width: 4.w),
                                Text(
                                  'সরাসরি কল',
                                  style: TextStyle(
                                    fontSize: 12.sp,
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

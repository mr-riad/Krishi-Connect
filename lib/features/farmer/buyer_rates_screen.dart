import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';

class BuyerRatesScreen extends StatefulWidget {
  const BuyerRatesScreen({super.key});

  @override
  State<BuyerRatesScreen> createState() => _BuyerRatesScreenState();
}

class _BuyerRatesScreenState extends State<BuyerRatesScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  int _selectedCategoryIndex = 0;

  final List<String> _categories = ['সব', 'ধান', 'সবজি', 'ফল'];

  final List<Map<String, dynamic>> _allRates = [
    {
      'buyer': 'রহিম ট্রেডার্স',
      'crop': 'বোরো ধান',
      'rate': '৩৮',
      'demand': '১০০০ কেজি',
      'location': 'রাজশাহী',
      'type': 'ধান',
      'isNew': true,
    },
    {
      'buyer': 'আলম ব্যবসায়ী',
      'crop': 'আলু (ডায়মন্ড)',
      'rate': '৩৫',
      'demand': '৫০০ কেজি',
      'location': 'বগুড়া',
      'type': 'সবজি',
      'isNew': true,
    },
    {
      'buyer': 'করিম এন্টারপ্রাইজ',
      'crop': 'পেঁয়াজ',
      'rate': '৭৮',
      'demand': '৩০০ কেজি',
      'location': 'পাবনা',
      'type': 'সবজি',
      'isNew': false,
    },
    {
      'buyer': 'নাসির ফ্রেশ',
      'crop': 'আম (হিমসাগর)',
      'rate': '১২০',
      'demand': '২০০ কেজি',
      'location': 'চাঁপাইনবাবগঞ্জ',
      'type': 'ফল',
      'isNew': false,
    },
    {
      'buyer': 'মামুন ট্রেডিং',
      'crop': 'আমন ধান',
      'rate': '৪০',
      'demand': '৮০০ কেজি',
      'location': 'দিনাজপুর',
      'type': 'ধান',
      'isNew': false,
    },
    {
      'buyer': 'রাশেদ গ্রুপ',
      'crop': 'টমেটো',
      'rate': '৪৫',
      'demand': '২৫০ কেজি',
      'location': 'রংপুর',
      'type': 'সবজি',
      'isNew': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredRates {
    if (_selectedCategoryIndex == 0) return _allRates;
    final cat = _categories[_selectedCategoryIndex];
    return _allRates.where((r) => r['type'] == cat).toList();
  }

  void _showContactSheet(Map<String, dynamic> rate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                rate['buyer'],
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '${rate['crop']} · ৳${rate['rate']}/কেজি · ${rate['demand']}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF4B5563),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14.sp, color: const Color(0xFF6B7280)),
                  SizedBox(width: 4.w),
                  Text(
                    rate['location'],
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${rate['buyer']}-কে কল করা হচ্ছে...'),
                        backgroundColor: primaryGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone_rounded),
                  label: Text(
                    'কল করুন',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
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
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ক্রেতার দর',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'ক্রেতারা কোন ফসলের কত দর দিচ্ছেন',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Category Filter
            SizedBox(
              height: 40.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => SizedBox(width: 10.w),
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

            // Rates List
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _filteredRates.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final rate = _filteredRates[index];
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 46.w,
                          height: 46.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0FDF4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.storefront_outlined, color: primaryGreen, size: 22.sp),
                        ),
                        SizedBox(width: 12.w),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    rate['crop'],
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  if (rate['isNew'] as bool) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        'নতুন',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                          color: primaryGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                '${rate['buyer']} · ${rate['location']}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Text(
                                    '৳${rate['rate']}/কেজি',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    '· ${rate['demand']}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Call Button
                        GestureDetector(
                          onTap: () => _showContactSheet(rate),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
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

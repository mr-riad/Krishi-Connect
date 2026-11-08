import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';

class AgriNewsScreen extends StatefulWidget {
  const AgriNewsScreen({super.key});

  @override
  State<AgriNewsScreen> createState() => _AgriNewsScreenState();
}

class _AgriNewsScreenState extends State<AgriNewsScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  int _selectedTab = 0;
  final List<String> _tabs = ['সব', 'ভর্তুকি', 'ঘোষণা', 'ঋণ'];

  final List<Map<String, dynamic>> _news = [
    {
      'category': 'ভর্তুকি',
      'title': 'কৃষি ভর্তুকিতে সার পাবেন ৩০ লাখ কৃষক',
      'date': '১২ অক্টোবর',
      'source': 'কৃষি মন্ত্রণালয়',
      'color': const Color(0xFFDCFCE7),
      'textColor': Color(0xFF166534),
    },
    {
      'category': 'ঘোষণা',
      'title': 'ধানের ন্যূনতম সরকারি মূল্য বৃদ্ধির সিদ্ধান্ত',
      'date': '১০ অক্টোবর',
      'source': 'খাদ্য মন্ত্রণালয়',
      'color': const Color(0xFFFEF3C7),
      'textColor': Color(0xFF92400E),
    },
    {
      'category': 'ঋণ',
      'title': 'কৃষি ব্যাংক থেকে সহজ শর্তে ৫০,০০০ টাকা পর্যন্ত ঋণ',
      'date': '৮ অক্টোবর',
      'source': 'বাংলাদেশ কৃষি ব্যাংক',
      'color': const Color(0xFFEDE9FE),
      'textColor': Color(0xFF5B21B6),
    },
    {
      'category': 'ঘোষণা',
      'title': 'বন্যা ক্ষতিগ্রস্ত কৃষকদের জন্য বিশেষ পুনর্বাসন প্যাকেজ',
      'date': '৬ অক্টোবর',
      'source': 'দুর্যোগ ব্যবস্থাপনা মন্ত্রণালয়',
      'color': const Color(0xFFFEF3C7),
      'textColor': Color(0xFF92400E),
    },
    {
      'category': 'ভর্তুকি',
      'title': 'সেচ সুবিধায় ৭০% ভর্তুকি পাবেন ক্ষুদ্র কৃষকরা',
      'date': '৪ অক্টোবর',
      'source': 'কৃষি মন্ত্রণালয়',
      'color': const Color(0xFFDCFCE7),
      'textColor': Color(0xFF166534),
    },
    {
      'category': 'ঋণ',
      'title': 'প্রবাসী কল্যাণ ব্যাংক কৃষকদের বিনা জামানতে ঋণ দেবে',
      'date': '২ অক্টোবর',
      'source': 'অর্থ মন্ত্রণালয়',
      'color': const Color(0xFFEDE9FE),
      'textColor': Color(0xFF5B21B6),
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedTab == 0) return _news;
    return _news.where((n) => n['category'] == _tabs[_selectedTab]).toList();
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
                    'F-11 · কৃষক',
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
                    'সরকারি ও কৃষি খবর',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),

            // Category Tabs
            SizedBox(
              height: 40.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _tabs.length,
                separatorBuilder: (_, _) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final isSelected = _selectedTab == index;
                  return InkWell(
                    onTap: () => setState(() => _selectedTab = index),
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
                        _tabs[index],
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

            // News List
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _filtered.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
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
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: item['color'] as Color,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            item['category'] as String,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: item['textColor'] as Color,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 12.sp, color: const Color(0xFF9CA3AF)),
                            SizedBox(width: 4.w),
                            Text(
                              item['date'] as String,
                              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                            ),
                            SizedBox(width: 10.w),
                            Text('·', style: TextStyle(color: const Color(0xFF9CA3AF))),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                item['source'] as String,
                                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                                overflow: TextOverflow.ellipsis,
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

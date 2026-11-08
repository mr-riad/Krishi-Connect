import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';
import '../../helpers/call_helper.dart';

class AdvisoryScreen extends StatefulWidget {
  const AdvisoryScreen({super.key});

  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  late TabController _tabController;

  final List<Map<String, dynamic>> _callSpecialists = [
    {
      'title': 'কৃষি কল সেন্টার (টোল ফ্রি)',
      'subtitle': 'সরকারি সরাসরি কৃষি ও বালাই পরামর্শ সেবা',
      'officer': 'বিশেষজ্ঞ কৃষিবিদ টিম',
      'phone': '16123',
      'isEmergency': true,
      'badge': 'টোল ফ্রি',
      'icon': Icons.support_agent_rounded,
      'color': const Color(0xFFDCFCE7),
      'iconColor': const Color(0xFF16A34A),
    },
    {
      'title': 'উপজেলা কৃষি কর্মকর্তা (UAO)',
      'subtitle': 'সার, বীজ ও সাধারণ ফসল ব্যবস্থাপনা',
      'officer': 'মো: আতিকুর রহমান',
      'phone': '01712-001122',
      'isEmergency': false,
      'badge': 'বাগমারা',
      'icon': Icons.agriculture_rounded,
      'color': const Color(0xFFE0F2FE),
      'iconColor': const Color(0xFF0284C7),
    },
    {
      'title': 'উদ্ভিদ সংরক্ষণ কর্মকর্তা',
      'subtitle': 'ফসলের রোগ ও পোকা-মাকড় দমন বিশেষজ্ঞ',
      'officer': 'ড. মো: কামরুল হাসান',
      'phone': '01713-112233',
      'isEmergency': false,
      'badge': 'রোগ বিশেষজ্ঞ',
      'icon': Icons.eco_outlined,
      'color': const Color(0xFFFEF3C7),
      'iconColor': const Color(0xFFD97706),
    },
    {
      'title': 'প্রাণিসম্পদ কর্মকর্তা',
      'subtitle': 'গরু-ছাগল, হাঁস-মুরগি পালন ও চিকিৎসা',
      'officer': 'ডা: ফরিদা ইয়াসমিন',
      'phone': '01714-223344',
      'isEmergency': false,
      'badge': 'প্রাণিসম্পদ',
      'icon': Icons.pets_outlined,
      'color': const Color(0xFFFCE7F3),
      'iconColor': const Color(0xFFDB2777),
    },
    {
      'title': 'উপজেলা মৎস্য কর্মকর্তা',
      'subtitle': 'মাছ চাষ, পোনা ও পুকুর ব্যবস্থাপনা',
      'officer': 'মো: তরিকুল ইসলাম',
      'phone': '01715-334455',
      'isEmergency': false,
      'badge': 'মৎস্য',
      'icon': Icons.water_drop_outlined,
      'color': const Color(0xFFE0E7FF),
      'iconColor': const Color(0xFF4F46E5),
    },
  ];

  final List<Map<String, dynamic>> _tips = [
    {
      'title': 'ধানের ব্লাস্ট রোগ',
      'desc':
          'ধানে ব্লাস্ট রোগ দেখা দিলে ট্রাইসাইক্লাজোল ৭৫% WP ০.৬ গ্রাম/লিটার পানিতে মিশিয়ে স্প্রে করুন।',
      'icon': Icons.eco_outlined,
      'color': const Color(0xFFDCFCE7),
      'iconColor': const Color(0xFF16A34A),
    },
    {
      'title': 'সেচের সঠিক সময়',
      'desc':
          'বোরো ধানে সকালে সেচ দিন। দুপুরে সেচ দিলে পানির বাষ্পীভবন বেশি হয় এবং গাছের ক্ষতি হতে পারে।',
      'icon': Icons.water_drop_outlined,
      'color': const Color(0xFFE0F2FE),
      'iconColor': const Color(0xFF0284C7),
    },
    {
      'title': 'সার প্রয়োগ পদ্ধতি',
      'desc':
          'ইউরিয়া সার তিন ভাগে দিন: রোপণের সময়, ১৫ দিন পর এবং ৩০ দিন পর। এতে ফসলের ফলন বাড়বে।',
      'icon': Icons.science_outlined,
      'color': const Color(0xFFFEF3C7),
      'iconColor': const Color(0xFFD97706),
    },
    {
      'title': 'আলুর রোগ প্রতিরোধ',
      'desc':
          'আলু চাষে লেট ব্লাইট রোগ থেকে বাঁচতে মেটালেক্সিল + ম্যানকোজেব ২ গ্রাম/লিটার পানিতে স্প্রে করুন।',
      'icon': Icons.grass_outlined,
      'color': const Color(0xFFFCE7F3),
      'iconColor': const Color(0xFFDB2777),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _callSpecialist(Map<String, dynamic> item) {
    showDirectCallBottomSheet(
      context: context,
      name: item['title'] as String,
      phone: item['phone'] as String,
      roleOrType: item['badge'] as String?,
      subtitle: '${item['officer']} · ${item['subtitle']}',
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'কৃষি পরামর্শ ও সেবা',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'বিশেষজ্ঞদের সাথে সরাসরি কল করে পরামর্শ নিন',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle:
                    TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                unselectedLabelStyle:
                    TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'সরাসরি কল পরামর্শ'),
                  Tab(text: 'কৃষি টিপস'),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Direct Call Advisory List
                  ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      // Featured 16123 Emergency Toll Free Card
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF15803D), Color(0xFF16A34A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18.r),
                          boxShadow: [
                            BoxShadow(
                              color: primaryGreen.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.support_agent_rounded,
                                        color: Colors.white,
                                        size: 24.sp,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      'কৃষি কল সেন্টার ১৬১২৩',
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    'টোল ফ্রি',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'যেকোনো অপারেটর থেকে ১৬১২৩ নম্বরে বিনামূল্যে কল করে কৃষি, মৎস্য ও প্রাণিসম্পদ কর্মকর্তাদের সাথে সরাসরি কথা বলুন।',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.white.withValues(alpha: 0.95),
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 14.h),
                            SizedBox(
                              width: double.infinity,
                              height: 44.h,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    makeDirectCall(context, '16123',
                                        contactName: 'কৃষি কল সেন্টার'),
                                icon: const Icon(Icons.phone_in_talk_rounded),
                                label: Text(
                                  '১৬১২৩ নম্বরে সরাসরি কল করুন',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryGreen,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      Text(
                        'উপজেলা ও বিভাগীয় কর্মকর্তা',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // Specialist list items
                      ..._callSpecialists
                          .where((item) => item['phone'] != '16123')
                          .map((item) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
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
                          child: Row(
                            children: [
                              Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  color: item['color'] as Color,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: item['iconColor'] as Color,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '${item['officer']} · ${item['badge']}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF4B5563),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      item['phone'] as String,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () => _callSpecialist(item),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryGreen,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.phone_in_talk_rounded,
                                        size: 14.sp,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'কল',
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
                      }),

                      SizedBox(height: 20.h),
                    ],
                  ),

                  // Tab 2: Tips
                  ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    itemCount: _tips.length,
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final tip = _tips[index];
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                color: tip['color'] as Color,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                tip['icon'] as IconData,
                                color: tip['iconColor'] as Color,
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tip['title']!,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    tip['desc']!,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF4B5563),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

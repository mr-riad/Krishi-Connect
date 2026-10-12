import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FarmerScreen extends StatelessWidget {
  const FarmerScreen({super.key});

  static const Color primaryGreen = Color(0xFF1E633F);
  static const Color bgColor = Color(0xFFF4F6F0);

  final List<Map<String, dynamic>> services = const [
    {
      "title": "ক্রেতার দর",
      "icon": Icons.bar_chart_rounded,
    },
    {
      "title": "কাছের ক্রেতা",
      "icon": Icons.location_on_outlined,
    },
    {
      "title": "রোগ নির্ণয়",
      "icon": Icons.search_rounded,
    },
    {
      "title": "সাথী ফসল",
      "icon": Icons.eco_outlined,
    },
    {
      "title": "ফসল ক্যালেন্ডার",
      "icon": Icons.calendar_month_outlined,
    },
    {
      "title": "কৃষি যন্ত্র",
      "icon": Icons.agriculture_rounded,
    },
    {
      "title": "সরকারি খবর",
      "icon": Icons.feed_outlined,
    },
    {
      "title": "কমিউনিটি",
      "icon": Icons.chat_bubble_outline_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),

              // Header: Greeting, Name, Location & Notification Bell
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "আসসালামু আলাইকুম",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "[কৃষকের নাম]",
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14.sp,
                              color: const Color(0xFF6B7280),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              "[উপজেলা], [জেলা]",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Bell Icon Button
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none_rounded),
                      color: const Color(0xFF1F2937),
                      iconSize: 22.sp,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              SizedBox(height: 18.h),

              // Weather Alert Card (আবহাওয়া সতর্কতা)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE68A),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloudy_snowing,
                        color: const Color(0xFF92400E),
                        size: 26.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "আবহাওয়া সতর্কতা",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF78350F),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            "আজ ভারী বৃষ্টির সম্ভাবনা। কাটা ফসল ঢেকে রাখুন।",
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF92400E),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Big CTA Button: আমার ফসল বিক্রির পোস্ট দিন
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                  label: Text(
                    "আমার ফসল বিক্রির পোস্ট দিন",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 22.h),

              // Section: সব সেবা
              Text(
                "সব সেবা",
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),

              SizedBox(height: 12.h),

              // 8 Services Grid (4 columns)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(7.w),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0FDF4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              service["icon"] as IconData,
                              color: primaryGreen,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            service["title"] as String,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF374151),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

// Alias for FarmerHomeScreen compatibility
typedef FarmerHomeScreen = FarmerScreen;

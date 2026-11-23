import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';
import '../../models/weather_machinery_news_models.dart';
import '../../services/api_service.dart';
import 'farm_equipment_screen.dart';
import 'farmer_community_screen.dart';
import 'crop_calendar_screen.dart';
import 'intercropping_screen.dart';
import 'nearby_buyers_screen.dart';
import 'agri_news_screen.dart';
import 'weather_alerts_screen.dart';

class FarmerScreen extends StatefulWidget {
  final VoidCallback? onGoToPost;
  final VoidCallback? onGoToBuyerRates;
  final VoidCallback? onGoToAdvisory;

  const FarmerScreen({
    super.key,
    this.onGoToPost,
    this.onGoToBuyerRates,
    this.onGoToAdvisory,
  });

  @override
  State<FarmerScreen> createState() => _FarmerScreenState();
}

class _FarmerScreenState extends State<FarmerScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  WeatherAlert? _latestAlert;
  bool _weatherLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final res = await KrishiApiService.instance.getMyWeatherAlerts(limit: 1);
      final page = WeatherAlertPage.fromJson(res);
      if (mounted) {
        setState(() {
          _latestAlert = page.items.isNotEmpty ? page.items.first : null;
          _weatherLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _weatherLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onGoToPost = widget.onGoToPost;
    final onGoToBuyerRates = widget.onGoToBuyerRates;
    final onGoToAdvisory = widget.onGoToAdvisory;
    final List<Map<String, dynamic>> services = [
      {'title': 'ক্রেতার দর', 'icon': Icons.bar_chart_rounded, 'onTap': onGoToBuyerRates},
      {
        'title': 'কাছের ক্রেতা',
        'icon': Icons.location_on_outlined,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyBuyersScreen())),
      },
      {'title': 'রোগ নির্ণয়', 'icon': Icons.search_rounded, 'onTap': onGoToAdvisory},
      {'title': 'সাথী ফসল', 'icon': Icons.eco_outlined, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IntercroppingScreen()))},
      {
        'title': 'ফসল ক্যালেন্ডার',
        'icon': Icons.calendar_month_outlined,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CropCalendarScreen())),
      },
      {
        'title': 'কৃষি যন্ত্র',
        'icon': Icons.agriculture_rounded,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmEquipmentScreen())),
      },
      {
        'title': 'সরকারি খবর',
        'icon': Icons.feed_outlined,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgriNewsScreen())),
      },
      {
        'title': 'কমিউনিটি',
        'icon': Icons.people_outline_rounded,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerCommunityScreen())),
      },
    ];

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
                          'আসসালামু আলাইকুম',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'মো: রফিকুল ইসলাম',
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
                              'বাগমারা, রাজশাহী',
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

              // Weather Alert Card
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WeatherAlertsScreen(),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: _latestAlert != null
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: _latestAlert != null
                          ? const Color(0xFFFCD34D)
                          : const Color(0xFF6EE7B7),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _latestAlert != null
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                            : const Color(0xFF10B981).withValues(alpha: 0.10),
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
                          _latestAlert != null
                              ? Icons.cloudy_snowing
                              : Icons.wb_sunny_outlined,
                          color: _latestAlert != null
                              ? const Color(0xFF92400E)
                              : const Color(0xFF065F46),
                          size: 26.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _weatherLoading
                            ? SizedBox(
                                height: 20.h,
                                child: const LinearProgressIndicator(),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _latestAlert != null
                                        ? 'আবহাওয়া সতর্কতা'
                                        : 'আবহাওয়া স্বাভাবিক',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: _latestAlert != null
                                          ? const Color(0xFF78350F)
                                          : const Color(0xFF065F46),
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    _latestAlert?.bodyBn ??
                                        'আজ আবহাওয়া পরিষ্কার। চাষাবাদের জন্য উপযুক্ত।',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w500,
                                      color: _latestAlert != null
                                          ? const Color(0xFF92400E)
                                          : const Color(0xFF065F46),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: _latestAlert != null
                            ? const Color(0xFF92400E)
                            : const Color(0xFF065F46),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Big CTA Button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: onGoToPost,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                  label: Text(
                    'আমার ফসল বিক্রির পোস্ট দিন',
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
                'সব সেবা',
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
                  final onTap = service['onTap'] as VoidCallback?;
                  return InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: onTap,
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
                              service['icon'] as IconData,
                              color: primaryGreen,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            service['title'] as String,
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';
import '../../helpers/call_helper.dart';
import '../../models/weather_machinery_news_models.dart';
import '../../services/api_service.dart';

class FarmEquipmentScreen extends StatefulWidget {
  const FarmEquipmentScreen({super.key});

  @override
  State<FarmEquipmentScreen> createState() => _FarmEquipmentScreenState();
}

class _FarmEquipmentScreenState extends State<FarmEquipmentScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  /// Category entries: [Bengali label, API enum value or null for 'all']
  static const List<(String, String?)> _categories = [
    ('সব', null),
    ('ট্রাক্টর', 'tractor'),
    ('হারভেস্টার', 'harvester'),
    ('পাওয়ার টিলার', 'power_tiller'),
    ('থ্রেশার', 'thresher'),
    ('সেচ পাম্প', 'irrigation_pump'),
    ('স্প্রেয়ার', 'sprayer'),
  ];

  int _selectedCategoryIndex = 0;
  List<MachineryItem> _items = [];
  bool _loading = false;
  String? _error;

  final _api = KrishiApiService.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final typeKey = _categories[_selectedCategoryIndex].$2;
      final res = await _api.getMachinery(
        machineryType: typeKey,
        limit: 50,
      );
      final page = MachineryPage.fromJson(res);
      if (mounted) {
        setState(() {
          _items = page.items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'ডেটা লোড করতে সমস্যা হয়েছে।\n$e';
          _loading = false;
        });
      }
    }
  }

  void _showCallSheet(MachineryItem item) {
    showDirectCallBottomSheet(
      context: context,
      name: item.ownerName,
      phone: item.phone,
      roleOrType: 'যন্ত্রের মালিক',
      subtitle: '${item.machineryTypeBn} · ${item.formattedRate}',
      location: item.upazila ?? item.district,
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
                separatorBuilder: (_, _) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return InkWell(
                    onTap: () {
                      if (_selectedCategoryIndex != index) {
                        setState(() => _selectedCategoryIndex = index);
                        _loadData();
                      }
                    },
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
                        _categories[index].$1,
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

            // Content
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.grey),
              SizedBox(height: 12.h),
              Text(
                'ডেটা লোড করা যায়নি',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6.h),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('আবার চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture_rounded, size: 52.sp, color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            Text(
              'এই বিভাগে কোনো যন্ত্র নেই',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      color: primaryGreen,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _items.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final item = _items[index];
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
                  child: Icon(
                    Icons.agriculture_rounded,
                    color: primaryGreen,
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
                        item.brandModel != null && item.brandModel!.isNotEmpty
                            ? item.brandModel!
                            : item.machineryTypeBn,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${item.ownerName} · ${item.upazila ?? item.district}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'ভাড়া ${item.formattedRate}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: primaryGreen,
                        ),
                      ),
                      if (!item.isAvailable) ...[
                        SizedBox(height: 2.h),
                        Text(
                          item.availabilityBn,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Call Button
                GestureDetector(
                  onTap: () => _showCallSheet(item),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: item.isAvailable ? primaryGreen : Colors.grey.shade400,
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
    );
  }
}

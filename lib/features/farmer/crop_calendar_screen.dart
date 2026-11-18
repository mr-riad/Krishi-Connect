import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/colors.gen.dart';
import '../../services/api_service.dart';
import 'intercropping_screen.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final _api = KrishiApiService.instance;

  bool _isLoading = true;
  String? _error;

  // Full calendar data from backend
  String _currentMonthBn = '';
  Map<String, dynamic>? _currentSeasonData;
  List<Map<String, dynamic>> _seasons = [];

  int _selectedSeason = 0;

  @override
  void initState() {
    super.initState();
    _fetchCalendar();
  }

  Future<void> _fetchCalendar() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getFullCalendar();

      _currentMonthBn = data['current_month_bn'] ?? '';
      _currentSeasonData = data['current_season'];

      final seasonsList = data['seasons'] as List<dynamic>? ?? [];
      _seasons = seasonsList.map((s) => s as Map<String, dynamic>).toList();

      // Auto-select the current season tab
      if (_currentSeasonData != null) {
        final currentSeasonId = _currentSeasonData!['id'];
        for (int i = 0; i < _seasons.length; i++) {
          final seasonInfo = _seasons[i]['season'] as Map<String, dynamic>?;
          if (seasonInfo != null && seasonInfo['id'] == currentSeasonId) {
            _selectedSeason = i;
            break;
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'ডাটা লোড করতে সমস্যা হচ্ছে। আবার চেষ্টা করুন।';
      });
      debugPrint('[CropCalendar] Error: $e');
    }
  }

  Map<String, dynamic> get _currentSeasonCalendar =>
      _seasons.isNotEmpty ? _seasons[_selectedSeason] : {};

  Map<String, dynamic> get _seasonMeta =>
      _currentSeasonCalendar['season'] as Map<String, dynamic>? ?? {};

  List<Map<String, dynamic>> get _crops {
    final cropsList = _currentSeasonCalendar['crops'] as List<dynamic>? ?? [];
    return cropsList.map((c) => c as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _fetchCalendar,
              icon: const Icon(Icons.refresh),
              label: const Text('আবার চেষ্টা করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              final seasonInfo =
                  _seasons[index]['season'] as Map<String, dynamic>? ?? {};
              final isSelected = _selectedSeason == index;
              return InkWell(
                onTap: () => setState(() => _selectedSeason = index),
                borderRadius: BorderRadius.circular(20.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? primaryGreen
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    seasonInfo['name_bn'] ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF374151),
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
                Icon(
                  Icons.calendar_today_rounded,
                  color: primaryGreen,
                  size: 18.sp,
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentSeasonCalendar['tip_bn'] ?? '',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      _currentMonthBn,
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
                  _seasonMeta['months_bn'] ?? '',
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
            itemCount: _crops.length,
            separatorBuilder: (context, index) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final crop = _crops[index];
              final companions =
                  (crop['companions'] as List<dynamic>?)?.cast<String>() ?? [];
              return GestureDetector(
                onTap: companions.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IntercroppingScreen(
                              cropId: crop['id'] ?? '',
                              cropNameBn: crop['name_bn'] ?? '',
                            ),
                          ),
                        );
                      }
                    : null,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        crop['icon'] ?? '🌱',
                        style: TextStyle(fontSize: 28.sp),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crop['name_bn'] ?? '',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'বপন: ${crop['sow_bn'] ?? ''}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              'কাটা: ${crop['harvest_bn'] ?? ''}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            if (crop['companion_note_bn'] != null &&
                                (crop['companion_note_bn'] as String)
                                    .isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.eco_outlined,
                                    size: 12.sp,
                                    color: primaryGreen,
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      crop['companion_note_bn'],
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (companions.isNotEmpty)
                        Icon(
                          Icons.chevron_right_rounded,
                          color: const Color(0xFF9CA3AF),
                          size: 22.sp,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

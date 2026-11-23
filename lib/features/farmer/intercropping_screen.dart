import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';
import '../../services/api_service.dart';

/// Intercropping (সাথী ফসল) Screen.
///
/// Two modes:
///   1. **cropId provided** → shows companions for that specific crop
///      (from `/intercrop/companions/{crop_id}` + `/intercrop/crop/{crop_id}`)
///   2. **No cropId** → shows all intercrop combo guides, filterable by season
///      (from `/intercrop`)
class IntercroppingScreen extends StatefulWidget {
  final String? cropId;
  final String? cropNameBn;

  const IntercroppingScreen({super.key, this.cropId, this.cropNameBn});

  @override
  State<IntercroppingScreen> createState() => _IntercroppingScreenState();
}

class _IntercroppingScreenState extends State<IntercroppingScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final _api = KrishiApiService.instance;

  bool _isLoading = true;
  String? _error;

  // For crop-specific view
  Map<String, dynamic>? _cropInfo;
  List<Map<String, dynamic>> _companionCrops = [];

  // For combo guide view
  List<Map<String, dynamic>> _combos = [];
  int _selectedSeasonFilter = 0; // 0 = all
  final List<Map<String, String>> _seasonFilters = [
    {'id': '', 'name_bn': 'সব মৌসুম'},
    {'id': 'rabi', 'name_bn': 'রবি'},
    {'id': 'kharif1', 'name_bn': 'খরিফ-১'},
    {'id': 'kharif2', 'name_bn': 'খরিফ-২'},
  ];

  // For crop-specific combo guides
  List<Map<String, dynamic>> _cropCombos = [];

  bool get _isCropSpecific => widget.cropId != null && widget.cropId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isCropSpecific) {
      _fetchCropCompanions();
    } else {
      _fetchAllCombos();
    }
  }

  Future<void> _fetchCropCompanions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch companions and combo guides in parallel
      final results = await Future.wait([
        _api.getCompanions(widget.cropId!),
        _api.getIntercropByCrop(widget.cropId!),
      ]);

      final companionsData = results[0];
      final combosData = results[1];

      _cropInfo = companionsData['crop'] as Map<String, dynamic>?;

      final companionsList =
          companionsData['companion_crops'] as List<dynamic>? ?? [];
      _companionCrops =
          companionsList.map((c) => c as Map<String, dynamic>).toList();

      final combosList = combosData['combos'] as List<dynamic>? ?? [];
      _cropCombos =
          combosList.map((c) => c as Map<String, dynamic>).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'ডাটা লোড করতে সমস্যা হচ্ছে। আবার চেষ্টা করুন।';
      });
      debugPrint('[Intercrop] Error: $e');
    }
  }

  Future<void> _fetchAllCombos({String? seasonId}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getIntercropGuide(seasonId: seasonId);

      final combosList = data['combos'] as List<dynamic>? ?? [];
      _combos = combosList.map((c) => c as Map<String, dynamic>).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'ডাটা লোড করতে সমস্যা হচ্ছে। আবার চেষ্টা করুন।';
      });
      debugPrint('[Intercrop] Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_isLoading)
              const Expanded(
                  child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(child: _buildError())
            else if (_isCropSpecific)
              Expanded(child: _buildCropSpecificView())
            else
              Expanded(child: _buildAllCombosView()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
              child:
                  const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              _isCropSpecific
                  ? '${widget.cropNameBn ?? ''} — সাথী ফসল'
                  : 'সাথী ফসল গাইড',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
              style:
                  TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _isCropSpecific
                  ? _fetchCropCompanions
                  : _fetchAllCombos,
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

  // ─── Crop-specific view ─────────────────────────────────────────────────

  Widget _buildCropSpecificView() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        // Main crop info card
        if (_cropInfo != null) _buildMainCropCard(_cropInfo!),
        SizedBox(height: 16.h),

        // Companion crops section
        if (_companionCrops.isNotEmpty) ...[
          Text(
            'সাথী ফসলসমূহ',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 10.h),
          ..._companionCrops.map((c) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _buildCompanionCard(c),
              )),
        ] else
          _buildEmptyState('এই ফসলের জন্য কোনো সাথী ফসল পাওয়া যায়নি।'),

        // Intercrop combo guides for this crop
        if (_cropCombos.isNotEmpty) ...[
          SizedBox(height: 20.h),
          Text(
            'আন্তঃফসল রেসিপি',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 10.h),
          ..._cropCombos.map((c) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildComboCard(c),
              )),
        ],

        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildMainCropCard(Map<String, dynamic> crop) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryGreen.withValues(alpha: 0.08),
            primaryGreen.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(crop['icon'] ?? '🌱', style: TextStyle(fontSize: 42.sp)),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop['name_bn'] ?? '',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  crop['name_en'] ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    _buildInfoChip(
                        Icons.spa_outlined, 'বপন: ${crop['sow_bn'] ?? ''}'),
                    SizedBox(width: 8.w),
                  ],
                ),
                SizedBox(height: 4.h),
                _buildInfoChip(Icons.agriculture_outlined,
                    'কাটা: ${crop['harvest_bn'] ?? ''}'),
                if (crop['companion_note_bn'] != null &&
                    (crop['companion_note_bn'] as String).isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    crop['companion_note_bn'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: primaryGreen,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: const Color(0xFF6B7280)),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanionCard(Map<String, dynamic> crop) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(crop['icon'] ?? '🌱',
                  style: TextStyle(fontSize: 24.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop['name_bn'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  crop['name_en'] ?? '',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'বপন: ${crop['sow_bn'] ?? ''} · কাটা: ${crop['harvest_bn'] ?? ''}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.eco_rounded, color: primaryGreen, size: 20.sp),
        ],
      ),
    );
  }

  // ─── All combos view ─────────────────────────────────────────────────────

  Widget _buildAllCombosView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Season filter chips
        SizedBox(
          height: 40.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _seasonFilters.length,
            separatorBuilder: (_, _) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final isSelected = _selectedSeasonFilter == index;
              return InkWell(
                onTap: () {
                  setState(() => _selectedSeasonFilter = index);
                  final sid = _seasonFilters[index]['id']!;
                  _fetchAllCombos(
                      seasonId: sid.isNotEmpty ? sid : null);
                },
                borderRadius: BorderRadius.circular(20.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                      horizontal: 18.w, vertical: 8.h),
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
                    _seasonFilters[index]['name_bn']!,
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

        // Info banner
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12.r),
              border:
                  Border.all(color: primaryGreen.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    color: primaryGreen, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'আন্তঃফসল চাষে একই জমি থেকে অতিরিক্ত আয় এবং মাটির উর্বরতা বৃদ্ধি হয়।',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF166534),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 14.h),

        // Combo cards
        Expanded(
          child: _combos.isEmpty
              ? _buildEmptyState(
                  'এই মৌসুমে কোনো আন্তঃফসল গাইড পাওয়া যায়নি।')
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _combos.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (_, index) =>
                      _buildComboCard(_combos[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildComboCard(Map<String, dynamic> combo) {
    final seasonMap = {
      'rabi': 'রবি',
      'kharif1': 'খরিফ-১',
      'kharif2': 'খরিফ-২',
    };
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.eco_rounded,
                    color: primaryGreen, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      combo['title_bn'] ?? '',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      combo['title_en'] ?? '',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  seasonMap[combo['season_id']] ?? combo['season_id'] ?? '',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Benefit
          _buildComboDetail(
            Icons.trending_up_rounded,
            'সুবিধা',
            combo['benefit_bn'] ?? '',
            const Color(0xFF059669),
          ),
          SizedBox(height: 8.h),

          // Method
          _buildComboDetail(
            Icons.construction_rounded,
            'পদ্ধতি',
            combo['method_bn'] ?? '',
            const Color(0xFF2563EB),
          ),
          SizedBox(height: 10.h),

          // Expected benefit badge
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                  color: const Color(0xFFFDE047).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded,
                    color: const Color(0xFFCA8A04), size: 16.sp),
                SizedBox(width: 8.w),
                Text(
                  'প্রত্যাশিত ফলাফল: ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF854D0E),
                  ),
                ),
                Expanded(
                  child: Text(
                    combo['expected_benefit'] ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF854D0E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComboDetail(
      IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: iconColor),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF374151),
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grass_rounded, size: 56.sp, color: const Color(0xFFD1D5DB)),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

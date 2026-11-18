import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/colors.gen.dart';
import '../../helpers/call_helper.dart';
import '../../models/crop_disease_models.dart';
import '../../services/api_service.dart';
import 'disease_detail_screen.dart';
import 'submit_disease_report_screen.dart';

class AdvisoryScreen extends StatefulWidget {
  final int initialTabIndex;

  const AdvisoryScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final _api = KrishiApiService.instance;
  late TabController _tabController;

  // ═══════════════════════════════════════════════════════════
  //  STATE: DIAGNOSIS ENGINE
  // ═══════════════════════════════════════════════════════════
  String _selectedCrop = 'paddy';
  String _selectedPart = 'leaf';
  String _selectedSeason = 'kharif';
  final TextEditingController _symptomsInputController = TextEditingController();
  bool _isDiagnosing = false;
  DiagnosisResponse? _diagnosisResult;
  String? _diagnosisError;

  final List<Map<String, String>> _cropsList = [
    {'id': 'paddy', 'name': 'ধান', 'icon': '🌾'},
    {'id': 'potato', 'name': 'আলু', 'icon': '🥔'},
    {'id': 'tomato', 'name': 'টমেটো', 'icon': '🍅'},
    {'id': 'jute', 'name': 'পাট', 'icon': '🌿'},
    {'id': 'wheat', 'name': 'গম', 'icon': '🌾'},
    {'id': 'mustard', 'name': 'সরিষা', 'icon': '🌱'},
    {'id': 'onion', 'name': 'পেঁয়াজ', 'icon': '🧅'},
    {'id': 'brinjal', 'name': 'বেগুন', 'icon': '🍆'},
    {'id': 'chili', 'name': 'মরিচ', 'icon': '🌶️'},
    {'id': 'sugarcane', 'name': 'আখ', 'icon': '🎋'},
  ];

  final List<Map<String, String>> _plantParts = [
    {'id': 'leaf', 'name': 'পাতা'},
    {'id': 'stem', 'name': 'কাণ্ড'},
    {'id': 'fruit', 'name': 'ফল / দানা'},
    {'id': 'root', 'name': 'শিকড়'},
    {'id': 'flower', 'name': 'ফুল / শীষ'},
  ];

  final List<String> _quickSymptomChips = [
    'পাতায় বাদামি দাগ',
    'ডায়মন্ড আকারের দাগ',
    'সাদা পাউডার ছাঁচ',
    'গাছ নেতিয়ে পড়ছে',
    'পাতা কুঁকড়ে যাচ্ছে',
    'ফল পচে যাওয়া',
    'পাতা হলুদ হচ্ছে',
    'কালো দাগ',
  ];

  // ═══════════════════════════════════════════════════════════
  //  STATE: DISEASE DATABASE
  // ═══════════════════════════════════════════════════════════
  List<CropDisease> _diseases = [];
  bool _isLoadingDiseases = false;
  String? _diseaseError;
  String? _diseaseCropFilter;
  String? _diseaseCategoryFilter;
  final TextEditingController _diseaseSearchController = TextEditingController();

  // ═══════════════════════════════════════════════════════════
  //  STATE: FARMING TIPS
  // ═══════════════════════════════════════════════════════════
  List<FarmingTip> _tips = [];
  bool _isLoadingTips = false;
  String? _tipsError;
  String? _tipCategoryFilter;
  final TextEditingController _tipSearchController = TextEditingController();

  final List<Map<String, String>> _tipCategories = [
    {'id': '', 'name': 'সব ক্যাটাগরি'},
    {'id': 'soil', 'name': 'মাটি ও জমি'},
    {'id': 'irrigation', 'name': 'সেচ ব্যবস্থাপনা'},
    {'id': 'fertilizer', 'name': 'সার প্রয়োগ'},
    {'id': 'pest_management', 'name': 'বালাই দমন (IPM)'},
    {'id': 'seed', 'name': 'উন্নত বীজ'},
    {'id': 'post_harvest', 'name': 'সংগ্রহোত্তর'},
    {'id': 'organic', 'name': 'জৈব কৃষি'},
    {'id': 'weather', 'name': 'আবহাওয়া'},
    {'id': 'integrated_farming', 'name': 'সমন্বিত কৃষি'},
  ];

  // ═══════════════════════════════════════════════════════════
  //  STATE: FIELD REPORTS
  // ═══════════════════════════════════════════════════════════
  List<DiseaseReport> _reports = [];
  bool _isLoadingReports = false;

  // ═══════════════════════════════════════════════════════════
  //  CALL SPECIALISTS DIRECTORY
  // ═══════════════════════════════════════════════════════════
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
    );

    // Initial loads
    _fetchDiseases();
    _fetchTips();
    _fetchReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _symptomsInputController.dispose();
    _diseaseSearchController.dispose();
    _tipSearchController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  //  API: DIAGNOSIS
  // ─────────────────────────────────────────────────────────
  Future<void> _diagnoseDisease() async {
    final text = _symptomsInputController.text.trim();
    if (text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কমপক্ষে ৫ অক্ষরে লক্ষণ বর্ণনা করুন')),
      );
      return;
    }

    setState(() {
      _isDiagnosing = true;
      _diagnosisError = null;
    });

    try {
      final res = await _api.diagnoseDisease(
        crop: _selectedCrop,
        symptoms: text,
        affectedPart: _selectedPart,
        season: _selectedSeason,
      );
      setState(() {
        _diagnosisResult = DiagnosisResponse.fromJson(res);
        _isDiagnosing = false;
      });
    } catch (e) {
      setState(() {
        _isDiagnosing = false;
        _diagnosisError = 'রোগ নির্ণয় করতে সমস্যা হয়েছে। নেটওয়ার্ক চেক করুন।';
      });
      debugPrint('[Diagnose] Error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  API: DISEASES
  // ─────────────────────────────────────────────────────────
  Future<void> _fetchDiseases() async {
    setState(() {
      _isLoadingDiseases = true;
      _diseaseError = null;
    });

    try {
      final data = await _api.getDiseases(
        crop: _diseaseCropFilter,
        category: _diseaseCategoryFilter,
        q: _diseaseSearchController.text.trim().isNotEmpty
            ? _diseaseSearchController.text.trim()
            : null,
        limit: 50,
      );
      final page = DiseasePage.fromJson(data);
      setState(() {
        _diseases = page.items;
        _isLoadingDiseases = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDiseases = false;
        _diseaseError = 'রোগের ডাটাবেজ লোড করা যায়নি।';
      });
      debugPrint('[Diseases] Error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  API: TIPS
  // ─────────────────────────────────────────────────────────
  Future<void> _fetchTips() async {
    setState(() {
      _isLoadingTips = true;
      _tipsError = null;
    });

    try {
      final data = await _api.getTips(
        category: _tipCategoryFilter != null && _tipCategoryFilter!.isNotEmpty
            ? _tipCategoryFilter
            : null,
        q: _tipSearchController.text.trim().isNotEmpty
            ? _tipSearchController.text.trim()
            : null,
        limit: 50,
      );
      final page = TipPage.fromJson(data);
      setState(() {
        _tips = page.items;
        _isLoadingTips = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTips = false;
        _tipsError = 'কৃষি টিপস লোড করা যায়নি।';
      });
      debugPrint('[Tips] Error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  API: REPORTS
  // ─────────────────────────────────────────────────────────
  Future<void> _fetchReports() async {
    setState(() => _isLoadingReports = true);
    try {
      final data = await _api.getDiseaseReports(limit: 10);
      final list = (data['items'] as List<dynamic>? ?? []);
      setState(() {
        _reports = list.map((e) => DiseaseReport.fromJson(e as Map<String, dynamic>)).toList();
        _isLoadingReports = false;
      });
    } catch (e) {
      setState(() => _isLoadingReports = false);
      debugPrint('[Reports] Error: $e');
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
            // Top Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'কৃষি পরামর্শ ও রোগ নির্ণয়',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'রোগ নির্ণয়, প্রতিকার, ডাটাবেজ ও বিশেষজ্ঞ সেবা',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      final refreshed = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubmitDiseaseReportScreen(),
                        ),
                      );
                      if (refreshed == true) {
                        _fetchReports();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: primaryGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_alert_rounded, size: 16.sp, color: primaryGreen),
                          SizedBox(width: 4.w),
                          Text(
                            'মাঠ রিপোর্ট',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: primaryGreen,
                            ),
                          ),
                        ],
                      ),
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
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                unselectedLabelStyle: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'রোগ নির্ণয়'),
                  Tab(text: 'রোগ তথ্যভাণ্ডার'),
                  Tab(text: 'কৃষি টিপস'),
                  Tab(text: 'বিশেষজ্ঞ কল'),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDiagnosisTab(),
                  _buildDiseaseDatabaseTab(),
                  _buildTipsTab(),
                  _buildCallAdvisoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  TAB 1: DISEASE DIAGNOSIS
  // ═══════════════════════════════════════════════════════════
  Widget _buildDiagnosisTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF047857), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search_rounded, color: Colors.white, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'লক্ষণ দেখে তাৎক্ষণিক রোগ নির্ণয়',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'আক্রান্ত ফসল ও লক্ষণের বিবরণ দিন, সঠিক প্রতিকার জানুন',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 1. Crop Selector
          _buildFormLabel('১. আক্রান্ত ফসল নির্বাচন করুন'),
          SizedBox(height: 8.h),
          SizedBox(
            height: 38.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _cropsList.length,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final c = _cropsList[index];
                final isSelected = _selectedCrop == c['id'];
                return InkWell(
                  onTap: () => setState(() => _selectedCrop = c['id']!),
                  borderRadius: BorderRadius.circular(20.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? primaryGreen : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected ? primaryGreen : const Color(0xFFD1D5DB),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(c['icon']!, style: TextStyle(fontSize: 14.sp)),
                        SizedBox(width: 6.w),
                        Text(
                          c['name']!,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 14.h),

          // 2. Affected Plant Part
          _buildFormLabel('২. আক্রান্ত অংশ ও মৌসুম'),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedPart,
                      items: _plantParts.map((p) {
                        return DropdownMenuItem<String>(
                          value: p['id'],
                          child: Text(
                            'অংশ: ${p['name']}',
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPart = val);
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedSeason,
                      items: const [
                        DropdownMenuItem(value: 'kharif', child: Text('খরিফ')),
                        DropdownMenuItem(value: 'rabi', child: Text('রবি')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSeason = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // 3. Quick Symptoms Chips
          _buildFormLabel('৩. দ্রুত লক্ষণ নির্বাচন করুন (ট্যাপ করুন)'),
          SizedBox(height: 6.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: _quickSymptomChips.map((chip) {
              return ActionChip(
                label: Text(chip, style: TextStyle(fontSize: 11.5.sp)),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                onPressed: () {
                  final current = _symptomsInputController.text.trim();
                  if (current.isEmpty) {
                    _symptomsInputController.text = chip;
                  } else if (!current.contains(chip)) {
                    _symptomsInputController.text = '$current, $chip';
                  }
                },
              );
            }).toList(),
          ),

          SizedBox(height: 10.h),

          // Symptoms Input
          TextField(
            controller: _symptomsInputController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'গাছের পাতা, কাণ্ড বা ফলের কী পরিবর্তন দেখতে পাচ্ছেন বিস্তারিত লিখুন...',
              hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: primaryGreen, width: 1.5),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Diagnose Button
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton.icon(
              onPressed: _isDiagnosing ? null : _diagnoseDisease,
              icon: _isDiagnosing
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.psychology_rounded, size: 20),
              label: Text(
                _isDiagnosing ? 'রোগ বিশ্লেষণ করা হচ্ছে...' : 'রোগ নির্ণয় ও প্রতিকার খুঁজুন',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Diagnosis Result View
          if (_diagnosisError != null)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                _diagnosisError!,
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFFB91C1C)),
              ),
            ),

          if (_diagnosisResult != null) _buildDiagnosisResultView(_diagnosisResult!),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildDiagnosisResultView(DiagnosisResponse res) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Advice Box
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_rounded, color: primaryGreen, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'কৃষি পরামর্শ সারসংক্ষেপ',
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                res.generalAdviceBn,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF1F2937),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        Text(
          'মিল থাকা রোগসমূহ (${res.matches.length}টি পাওয়া গেছে)',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 8.h),

        ...res.matches.map((m) {
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(14.w),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.nameBn,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            '${m.cropBn} · ${m.name}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: m.matchPercent >= 60
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'মিল: ${m.matchPercent}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: m.matchPercent >= 60
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Top remedies
                if (m.topRemedies.isNotEmpty) ...[
                  Text(
                    'কার্যকর প্রতিকার:',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: primaryGreen,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  ...m.topRemedies.map((r) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded, color: primaryGreen, size: 14.sp),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              r,
                              style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF374151)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DiseaseDetailScreen(diseaseId: m.diseaseId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('সম্পূর্ণ তথ্য ও সতর্কতা দেখুন'),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryGreen,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  TAB 2: DISEASE DATABASE
  // ═══════════════════════════════════════════════════════════
  Widget _buildDiseaseDatabaseTab() {
    return Column(
      children: [
        // Search & Crop Filter Bar
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 8.h),
          child: Column(
            children: [
              TextField(
                controller: _diseaseSearchController,
                onSubmitted: (_) => _fetchDiseases(),
                decoration: InputDecoration(
                  hintText: 'রোগের নাম বা লক্ষণ দিয়ে খুঁজুন...',
                  hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6B7280)),
                  suffixIcon: _diseaseSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _diseaseSearchController.clear();
                            _fetchDiseases();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                height: 34.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _cropFilterChip(null, 'সব ফসল'),
                    _cropFilterChip('paddy', 'ধান'),
                    _cropFilterChip('potato', 'আলু'),
                    _cropFilterChip('tomato', 'টমেটো'),
                    _cropFilterChip('jute', 'পাট'),
                    _cropFilterChip('wheat', 'গম'),
                    _cropFilterChip('mustard', 'সরিষা'),
                    _cropFilterChip('onion', 'পেঁয়াজ'),
                    _cropFilterChip('brinjal', 'বেগুন'),
                    _cropFilterChip('chili', 'মরিচ'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: _isLoadingDiseases
              ? const Center(child: CircularProgressIndicator())
              : _diseaseError != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_diseaseError!, style: TextStyle(fontSize: 14.sp)),
                          ElevatedButton(
                            onPressed: _fetchDiseases,
                            child: const Text('আবার চেষ্টা করুন'),
                          ),
                        ],
                      ),
                    )
                  : _diseases.isEmpty
                      ? const Center(child: Text('কোনো রোগ পাওয়া যায়নি'))
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                          itemCount: _diseases.length,
                          separatorBuilder: (context, index) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final d = _diseases[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DiseaseDetailScreen(
                                      diseaseId: d.id,
                                      disease: d,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(14.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44.w,
                                      height: 44.w,
                                      decoration: BoxDecoration(
                                        color: primaryGreen.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(Icons.eco_outlined, color: primaryGreen, size: 22.sp),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  d.nameBn,
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.w800,
                                                    color: const Color(0xFF111827),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                                decoration: BoxDecoration(
                                                  color: d.severity == 'high'
                                                      ? const Color(0xFFFEE2E2)
                                                      : const Color(0xFFFEF3C7),
                                                  borderRadius: BorderRadius.circular(6.r),
                                                ),
                                                child: Text(
                                                  d.severityBn,
                                                  style: TextStyle(
                                                    fontSize: 10.5.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: d.severity == 'high'
                                                        ? const Color(0xFFDC2626)
                                                        : const Color(0xFFD97706),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            'ফসল: ${d.cropBn} · ${d.categoryBn}',
                                            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            d.symptomsBn,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4B5563)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
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

  Widget _cropFilterChip(String? cropId, String label) {
    final isSelected = _diseaseCropFilter == cropId;
    return Padding(
      padding: EdgeInsets.only(right: 6.w),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12.sp)),
        selected: isSelected,
        backgroundColor: Colors.white,
        selectedColor: primaryGreen.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? primaryGreen : const Color(0xFF374151),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(color: isSelected ? primaryGreen : const Color(0xFFD1D5DB)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        onSelected: (_) {
          setState(() => _diseaseCropFilter = cropId);
          _fetchDiseases();
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  TAB 3: FARMING TIPS
  // ═══════════════════════════════════════════════════════════
  Widget _buildTipsTab() {
    return Column(
      children: [
        // Category Pills
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 6.h),
          child: Column(
            children: [
              TextField(
                controller: _tipSearchController,
                onSubmitted: (_) => _fetchTips(),
                decoration: InputDecoration(
                  hintText: 'টিপস খুঁজুন (উদা: সেচ, সার, বীজ)...',
                  hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6B7280)),
                  suffixIcon: _tipSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _tipSearchController.clear();
                            _fetchTips();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                height: 34.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tipCategories.length,
                  separatorBuilder: (context, index) => SizedBox(width: 6.w),
                  itemBuilder: (context, index) {
                    final cat = _tipCategories[index];
                    final isSelected = (_tipCategoryFilter ?? '') == cat['id'];
                    return FilterChip(
                      label: Text(cat['name']!, style: TextStyle(fontSize: 12.sp)),
                      selected: isSelected,
                      backgroundColor: Colors.white,
                      selectedColor: primaryGreen.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: isSelected ? primaryGreen : const Color(0xFF374151),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      side: BorderSide(color: isSelected ? primaryGreen : const Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      onSelected: (_) {
                        setState(() => _tipCategoryFilter = cat['id']);
                        _fetchTips();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Tips List
        Expanded(
          child: _isLoadingTips
              ? const Center(child: CircularProgressIndicator())
              : _tipsError != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_tipsError!, style: TextStyle(fontSize: 14.sp)),
                          ElevatedButton(onPressed: _fetchTips, child: const Text('আবার চেষ্টা করুন')),
                        ],
                      ),
                    )
                  : _tips.isEmpty
                      ? const Center(child: Text('কোনো টিপস পাওয়া যায়নি'))
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                          itemCount: _tips.length,
                          separatorBuilder: (context, index) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final tip = _tips[index];
                            return Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          tip.categoryBn,
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w700,
                                            color: primaryGreen,
                                          ),
                                        ),
                                      ),
                                      if (tip.season.isNotEmpty) ...[
                                        SizedBox(width: 6.w),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            tip.season.join(", "),
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFFD97706),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    tip.titleBn,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    tip.bodyBn,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF4B5563),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  TAB 4: CALL DIRECTORY & FIELD REPORTS
  // ═══════════════════════════════════════════════════════════
  Widget _buildCallAdvisoryTab() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      children: [
        // Emergency 16123 Toll Free Card
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
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
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
                  onPressed: () => makeDirectCall(
                    context,
                    '16123',
                    contactName: 'কৃষি কল সেন্টার',
                  ),
                  icon: const Icon(Icons.phone_in_talk_rounded),
                  label: Text(
                    '১৬১২৩ নম্বরে সরাসরি কল করুন',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 18.h),

        // Specialist Directory
        Text(
          'উপজেলা ও বিভাগীয় কর্মকর্তা',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 10.h),

        ..._callSpecialists.where((item) => item['phone'] != '16123').map((item) {
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  onTap: () {
                    showDirectCallBottomSheet(
                      context: context,
                      name: item['title'] as String,
                      phone: item['phone'] as String,
                      roleOrType: item['badge'] as String?,
                      subtitle: '${item['officer']} · ${item['subtitle']}',
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone_in_talk_rounded, size: 14.sp, color: Colors.white),
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

        SizedBox(height: 16.h),

        // Community Field Reports List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'সাম্প্রতিক মাঠ রোগ রিপোর্টসমূহ',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: _fetchReports,
            ),
          ],
        ),
        SizedBox(height: 8.h),

        if (_isLoadingReports)
          const Center(child: CircularProgressIndicator())
        else if (_reports.isEmpty)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'এখনো কোনো মাঠ রিপোর্ট নেই। আপনি প্রথম রিপোর্ট জমা দিন!',
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
              ),
            ),
          )
        else
          ..._reports.map((r) {
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ফসল: ${r.crop} ${r.diseaseName != null ? "(${r.diseaseName})" : ""}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          r.district,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    r.symptomsDescription,
                    style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF4B5563)),
                  ),
                ],
              ),
            );
          }),

        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildFormLabel(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF374151),
      ),
    );
  }
}

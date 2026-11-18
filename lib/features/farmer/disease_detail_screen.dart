import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/colors.gen.dart';
import '../../helpers/call_helper.dart';
import '../../models/crop_disease_models.dart';
import '../../services/api_service.dart';
import 'submit_disease_report_screen.dart';

/// Detailed view for a specific crop disease.
/// Displays symptoms, causes, remedies (chemical & organic), prevention, and severity.
class DiseaseDetailScreen extends StatefulWidget {
  final String diseaseId;
  final CropDisease? disease;

  const DiseaseDetailScreen({
    super.key,
    required this.diseaseId,
    this.disease,
  });

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final _api = KrishiApiService.instance;

  CropDisease? _disease;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.disease != null) {
      _disease = widget.disease;
      _isLoading = false;
    } else {
      _fetchDetail();
    }
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getDiseaseDetail(widget.diseaseId);
      setState(() {
        _disease = CropDisease.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'রোগের তথ্য লোড করতে সমস্যা হয়েছে।';
      });
      debugPrint('[DiseaseDetail] Error: $e');
    }
  }

  Color _severityColor(String sev) {
    switch (sev.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
      default:
        return const Color(0xFF10B981);
    }
  }

  Color _severityBg(String sev) {
    switch (sev.toLowerCase()) {
      case 'high':
        return const Color(0xFFFEE2E2);
      case 'medium':
        return const Color(0xFFFEF3C7);
      case 'low':
      default:
        return const Color(0xFFD1FAE5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827), size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          _disease?.nameBn ?? 'রোগের বিস্তারিত',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : _disease != null
                    ? _buildContent(_disease!)
                    : const SizedBox.shrink(),
      ),
      bottomNavigationBar: _disease != null
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        makeDirectCall(context, '16123', contactName: 'কৃষি কল সেন্টার');
                      },
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                      label: Text(
                        'কল করুন (১৬১২৩)',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: const BorderSide(color: primaryGreen),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubmitDiseaseReportScreen(
                              initialCrop: _disease!.crop,
                              initialDiseaseName: _disease!.nameBn,
                              initialSeverity: _disease!.severity,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.report_problem_outlined, size: 18),
                      label: Text(
                        'মাঠ রিপোর্ট দিন',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 50.sp, color: Colors.grey),
            SizedBox(height: 12.h),
            Text(
              _error ?? 'ত্রুটি দেখা দিয়েছে',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _fetchDetail,
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              child: const Text('আবার চেষ্টা করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CropDisease d) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.nameBn,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            d.name,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _severityBg(d.severity),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'তীব্রতা: ${d.severityBn}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: _severityColor(d.severity),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    _buildPill(Icons.eco_rounded, 'ফসল: ${d.cropBn}', primaryGreen, const Color(0xFFDCFCE7)),
                    _buildPill(Icons.category_rounded, d.categoryBn, const Color(0xFF0284C7), const Color(0xFFE0F2FE)),
                    if (d.season.isNotEmpty)
                      _buildPill(Icons.calendar_today_rounded, 'মৌসুম: ${d.season.join(", ")}', const Color(0xFFD97706), const Color(0xFFFEF3C7)),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Symptoms Card
          _buildSectionCard(
            title: 'রোগের লক্ষণসমূহ (Symptoms)',
            icon: Icons.visibility_outlined,
            iconColor: const Color(0xFFDC2626),
            content: Text(
              d.symptomsBn,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF374151),
                height: 1.55,
              ),
            ),
          ),

          SizedBox(height: 14.h),

          // Causes Card
          if (d.causesBn.isNotEmpty) ...[
            _buildSectionCard(
              title: 'রোগের কারণ ও অনুকূল পরিবেশ (Causes)',
              icon: Icons.biotech_outlined,
              iconColor: const Color(0xFF8B5CF6),
              content: Text(
                d.causesBn,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF374151),
                  height: 1.55,
                ),
              ),
            ),
            SizedBox(height: 14.h),
          ],

          // Remedies Card (প্রতিকার)
          if (d.remediesBn.isNotEmpty) ...[
            _buildSectionCard(
              title: 'কার্যকর প্রতিকার ও বালাইনাশক (Remedies)',
              icon: Icons.healing_rounded,
              iconColor: primaryGreen,
              content: Column(
                children: d.remediesBn.asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 3.h),
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: primaryGreen.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              color: const Color(0xFF1F2937),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 14.h),
          ],

          // Prevention Card (প্রতিরোধ)
          if (d.preventionBn.isNotEmpty) ...[
            _buildSectionCard(
              title: 'আগাম প্রতিরোধমূলক ব্যবস্থা (Prevention)',
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF2563EB),
              content: Column(
                children: d.preventionBn.map((p) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded, color: const Color(0xFF2563EB), size: 18.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            p,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              color: const Color(0xFF1F2937),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 14.h),
          ],

          // Affected parts Card
          if (d.affectedParts.isNotEmpty) ...[
            _buildSectionCard(
              title: 'আক্রান্ত গাছের অংশ (Affected Parts)',
              icon: Icons.park_outlined,
              iconColor: const Color(0xFF059669),
              content: Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: d.affectedParts.map((part) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      part,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
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
              Icon(icon, color: iconColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          Divider(color: const Color(0xFFF3F4F6), height: 20.h),
          content,
        ],
      ),
    );
  }

  Widget _buildPill(IconData icon, String label, Color textColor, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: textColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}


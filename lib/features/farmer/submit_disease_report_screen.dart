import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/colors.gen.dart';
import '../../services/api_service.dart';

/// Screen for farmers to submit a field disease report to the community & agricultural officers.
/// Connected to `POST /disease-reports`.
class SubmitDiseaseReportScreen extends StatefulWidget {
  final String? initialCrop;
  final String? initialDiseaseName;
  final String? initialSeverity;

  const SubmitDiseaseReportScreen({
    super.key,
    this.initialCrop,
    this.initialDiseaseName,
    this.initialSeverity,
  });

  @override
  State<SubmitDiseaseReportScreen> createState() => _SubmitDiseaseReportScreenState();
}

class _SubmitDiseaseReportScreenState extends State<SubmitDiseaseReportScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final _api = KrishiApiService.instance;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _cropController;
  late TextEditingController _diseaseNameController;
  late TextEditingController _symptomsController;
  late TextEditingController _districtController;
  late TextEditingController _upazilaController;
  late TextEditingController _notesController;

  String _severity = 'medium';
  bool _isSubmitting = false;

  final List<Map<String, String>> _cropsList = [
    {'id': 'paddy', 'name': 'ধান (Paddy)'},
    {'id': 'potato', 'name': 'আলু (Potato)'},
    {'id': 'tomato', 'name': 'টমেটো (Tomato)'},
    {'id': 'jute', 'name': 'পাট (Jute)'},
    {'id': 'wheat', 'name': 'গম (Wheat)'},
    {'id': 'mustard', 'name': 'সরিষা (Mustard)'},
    {'id': 'onion', 'name': 'পেঁয়াজ (Onion)'},
    {'id': 'brinjal', 'name': 'বেগুন (Brinjal)'},
    {'id': 'chili', 'name': 'মরিচ (Chili)'},
    {'id': 'sugarcane', 'name': 'আখ (Sugarcane)'},
  ];

  @override
  void initState() {
    super.initState();
    _cropController = TextEditingController(text: widget.initialCrop ?? 'paddy');
    _diseaseNameController = TextEditingController(text: widget.initialDiseaseName ?? '');
    _symptomsController = TextEditingController();
    _districtController = TextEditingController(text: 'কুমিল্লা');
    _upazilaController = TextEditingController();
    _notesController = TextEditingController();
    if (widget.initialSeverity != null) {
      _severity = widget.initialSeverity!;
    }
  }

  @override
  void dispose() {
    _cropController.dispose();
    _diseaseNameController.dispose();
    _symptomsController.dispose();
    _districtController.dispose();
    _upazilaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final body = <String, dynamic>{
        'crop': _cropController.text.trim(),
        'disease_name': _diseaseNameController.text.trim().isNotEmpty
            ? _diseaseNameController.text.trim()
            : null,
        'symptoms_description': _symptomsController.text.trim(),
        'severity': _severity,
        'district': _districtController.text.trim(),
        'upazila': _upazilaController.text.trim().isNotEmpty
            ? _upazilaController.text.trim()
            : null,
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      };

      await _api.createDiseaseReport(body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('আপনার ফসলের রোগ রিপোর্ট সফলভাবে জমা হয়েছে!'),
          backgroundColor: primaryGreen,
        ),
      );
      Navigator.maybePop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('রিপোর্ট জমা দিতে সমস্যা হয়েছে। আবার চেষ্টা করুন।'),
          backgroundColor: Colors.redAccent,
        ),
      );
      debugPrint('[SubmitReport] Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
          'মাঠ রোগ রিপোর্ট জমা দিন',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: const Color(0xFF2563EB), size: 22.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'আপনার জমিতে দেখা দেওয়া রোগের বিবরণ জমা দিলে স্থানীয় কৃষি কর্মকর্তা ও পার্শ্ববর্তী কৃষকরা সতর্ক হতে পারবেন।',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: const Color(0xFF1E40AF),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18.h),

                // Crop Selection
                _buildLabel('আক্রান্ত ফসল *'),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _cropsList.any((c) => c['id'] == _cropController.text)
                          ? _cropController.text
                          : _cropsList.first['id'],
                      items: _cropsList.map((c) {
                        return DropdownMenuItem<String>(
                          value: c['id'],
                          child: Text(
                            c['name']!,
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _cropController.text = val);
                      },
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                // Disease Name (optional)
                _buildLabel('রোগের নাম (যদি জানা থাকে)'),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _diseaseNameController,
                  decoration: _inputDecoration(hint: 'উদা: ধানের ব্লাস্ট বা আলুর লেট ব্লাইট'),
                ),

                SizedBox(height: 14.h),

                // Symptoms Description (required, min 10 chars)
                _buildLabel('রোগের লক্ষণের বিস্তারিত বিবরণ *'),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _symptomsController,
                  maxLines: 4,
                  validator: (val) {
                    if (val == null || val.trim().length < 10) {
                      return 'কমপক্ষে ১০ অক্ষরে লক্ষণ বর্ণনা করুন';
                    }
                    return null;
                  },
                  decoration: _inputDecoration(
                    hint: 'পাতার রং, দাগের ধরন, ছাঁচ বা পোকার উপস্থিতি বিস্তারিত লিখুন...',
                  ),
                ),

                SizedBox(height: 14.h),

                // Severity Level
                _buildLabel('রোগের তীব্রতা / বিস্তারের মাত্রা *'),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    _severityChip('low', 'কম (Low)', const Color(0xFF10B981)),
                    SizedBox(width: 8.w),
                    _severityChip('medium', 'মাঝারি (Medium)', const Color(0xFFF59E0B)),
                    SizedBox(width: 8.w),
                    _severityChip('high', 'মারাত্মক (High)', const Color(0xFFEF4444)),
                  ],
                ),

                SizedBox(height: 14.h),

                // District & Upazila
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('জেলা *'),
                          SizedBox(height: 6.h),
                          TextFormField(
                            controller: _districtController,
                            validator: (val) => val == null || val.trim().isEmpty ? 'জেলা লিখুন' : null,
                            decoration: _inputDecoration(hint: 'উদা: কুমিল্লা'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('উপজেলা'),
                          SizedBox(height: 6.h),
                          TextFormField(
                            controller: _upazilaController,
                            decoration: _inputDecoration(hint: 'উদা: লাকসাম'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Additional Notes
                _buildLabel('অতিরিক্ত মন্তব্য / নোট (ঐচ্ছিক)'),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: _inputDecoration(hint: 'কোন কীটনাশক প্রয়োগ করেছিলেন কিনা...'),
                ),

                SizedBox(height: 24.h),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitReport,
                    icon: _isSubmitting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                    label: Text(
                      _isSubmitting ? 'জমা দেওয়া হচ্ছে...' : 'রিপোর্ট জমা দিন',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF374151),
      ),
    );
  }

  Widget _severityChip(String val, String label, Color color) {
    final isSelected = _severity == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _severity = val),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFD1D5DB),
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: isSelected ? color : const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
    );
  }
}

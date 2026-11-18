import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_constants.dart';
import '../../gen/colors.gen.dart';
import '../../helpers/di.dart';
import '../../helpers/toast.dart';
import '../../models/weather_machinery_news_models.dart';
import '../../services/api_service.dart';

class WeatherAlertsScreen extends StatefulWidget {
  const WeatherAlertsScreen({super.key});

  @override
  State<WeatherAlertsScreen> createState() => _WeatherAlertsScreenState();
}

class _WeatherAlertsScreenState extends State<WeatherAlertsScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  bool _isLoading = true;
  String? _errorMessage;
  List<WeatherAlert> _alerts = [];
  int _selectedFilterIndex = 0;

  final List<Map<String, String>> _filterOptions = [
    {'label': 'সব', 'severity': ''},
    {'label': 'বিপদসংকেত', 'severity': 'danger'},
    {'label': 'সতর্কতা', 'severity': 'warning'},
    {'label': 'তথ্য', 'severity': 'info'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final district = appData.read(kKeySelectedLocation)?.toString();
      Map<String, dynamic> res;
      try {
        // Try my alerts first (targeted to user district)
        res = await KrishiApiService.instance.getMyWeatherAlerts();
      } catch (_) {
        // Fallback to public alerts endpoint
        res = await KrishiApiService.instance.getWeatherAlerts(district: district);
      }

      final page = WeatherAlertPage.fromJson(res);
      setState(() {
        _alerts = page.items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'আবহাওয়া তথ্য লোড করতে সমস্যা হয়েছে: $e';
        _isLoading = false;
      });
    }
  }

  List<WeatherAlert> get _filteredAlerts {
    final filterSeverity = _filterOptions[_selectedFilterIndex]['severity']!;
    if (filterSeverity.isEmpty) return _alerts;
    return _alerts
        .where((a) => a.severity.toLowerCase() == filterSeverity.toLowerCase())
        .toList();
  }

  Color _severityBgColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'danger':
        return const Color(0xFFFEE2E2);
      case 'warning':
        return const Color(0xFFFEF3C7);
      case 'info':
      default:
        return const Color(0xFFE0F2FE);
    }
  }

  Color _severityTextColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'danger':
        return const Color(0xFF991B1B);
      case 'warning':
        return const Color(0xFF92400E);
      case 'info':
      default:
        return const Color(0xFF075985);
    }
  }

  Color _severityBorderColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'danger':
        return const Color(0xFFFCA5A5);
      case 'warning':
        return const Color(0xFFFCD34D);
      case 'info':
      default:
        return const Color(0xFFBAE6FD);
    }
  }

  IconData _alertIcon(String alertType) {
    switch (alertType.toLowerCase()) {
      case 'storm':
        return Icons.thunderstorm_rounded;
      case 'heavy_rain':
        return Icons.water_drop_rounded;
      case 'flood':
        return Icons.flood_rounded;
      case 'cyclone':
        return Icons.cyclone_rounded;
      case 'heatwave':
        return Icons.wb_sunny_rounded;
      case 'frost':
        return Icons.ac_unit_rounded;
      case 'drought':
        return Icons.grain_rounded;
      case 'general':
      default:
        return Icons.cloud_outlined;
    }
  }

  void _showAlertDetail(WeatherAlert alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: _severityBgColor(alert.severity),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _alertIcon(alert.alertType),
                    color: _severityTextColor(alert.severity),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: _severityBgColor(alert.severity),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: _severityBorderColor(alert.severity)),
                        ),
                        child: Text(
                          '${alert.severityBn} · ${alert.alertTypeBn}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: _severityTextColor(alert.severity),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        alert.titleBn,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            const Divider(),
            SizedBox(height: 10.h),
            Text(
              'বিস্তারিত সতর্কবার্তা:',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              alert.bodyBn,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
            SizedBox(height: 14.h),
            if (alert.targetDistricts.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined, size: 16.sp, color: primaryGreen),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'আক্রান্ত এলাকা: ${alert.targetDistricts.join(', ')}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
            if (alert.source != null && alert.source!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.verified_outlined, size: 16.sp, color: Colors.blue),
                  SizedBox(width: 6.w),
                  Text(
                    'উৎস: ${alert.source}',
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
            if (alert.validUntil != null && alert.validUntil!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 16.sp, color: Colors.orange),
                  SizedBox(width: 6.w),
                  Text(
                    'কার্যকারিতা: ${alert.validUntil!.split('T').first}',
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'ঠিক আছে',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAlertDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final districtController = TextEditingController();
    String selectedSeverity = 'warning';
    String selectedType = 'storm';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'সতর্কতা বার্তা সম্প্রচার (FCM)',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedSeverity,
                  decoration: const InputDecoration(labelText: 'তীব্রতা'),
                  items: const [
                    DropdownMenuItem(value: 'danger', child: Text('বিপদসংকেত (Danger)')),
                    DropdownMenuItem(value: 'warning', child: Text('সতর্কতা (Warning)')),
                    DropdownMenuItem(value: 'info', child: Text('তথ্য (Info)')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedSeverity = v ?? 'warning'),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'ধরন'),
                  items: const [
                    DropdownMenuItem(value: 'storm', child: Text('ঝড়')),
                    DropdownMenuItem(value: 'heavy_rain', child: Text('ভারী বৃষ্টি')),
                    DropdownMenuItem(value: 'flood', child: Text('বন্যা')),
                    DropdownMenuItem(value: 'cyclone', child: Text('সাইক্লোন')),
                    DropdownMenuItem(value: 'heatwave', child: Text('তাপপ্রবাহ')),
                    DropdownMenuItem(value: 'general', child: Text('সাধারণ')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedType = v ?? 'storm'),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'শিরোনাম (বাংলায়)',
                    hintText: 'উদা: ভারী বৃষ্টির সতর্কতা',
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: bodyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'বিস্তারিত বার্তা',
                    hintText: 'উদা: আগামী ২৪ ঘণ্টায় ভারী বৃষ্টির সম্ভাবনা রয়েছে...',
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: districtController,
                  decoration: const InputDecoration(
                    labelText: 'জেলা (খালি রাখলে সবার কাছে যাবে)',
                    hintText: 'উদা: Rajshahi, Dhaka',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              onPressed: () async {
                if (titleController.text.trim().isEmpty || bodyController.text.trim().isEmpty) {
                  Toast.showToast(message: 'শিরোনাম ও বিবরণ আবশ্যক');
                  return;
                }
                Navigator.pop(dialogCtx);
                try {
                  final districts = districtController.text.trim().isEmpty
                      ? <String>[]
                      : districtController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                  await KrishiApiService.instance.createWeatherAlert({
                    'alert_type': selectedType,
                    'severity': selectedSeverity,
                    'title_bn': titleController.text.trim(),
                    'body_bn': bodyController.text.trim(),
                    'target_districts': districts,
                    'source': 'কৃষি সংযোগ আবহাওয়া সেল',
                  });

                  Toast.showToast(message: 'সতর্কতা সম্প্রচার ও নোটিফিকেশন পাঠানো হয়েছে');
                  _fetchAlerts();
                } catch (e) {
                  Toast.showToast(message: 'সতর্কতা পাঠাতে ব্যর্থ: $e');
                }
              },
              child: const Text('পাঠান ও পুশ করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'আবহাওয়া সতর্কতা ও বার্তা',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_rounded, color: primaryGreen),
            tooltip: 'সতর্কতা তৈরি ও পাঠান',
            onPressed: _showCreateAlertDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF374151)),
            onPressed: _fetchAlerts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilterIndex == index;
                  return InkWell(
                    onTap: () => setState(() => _selectedFilterIndex = index),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryGreen : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected ? primaryGreen : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        _filterOptions[index]['label']!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryGreen))
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_off_rounded, size: 48.sp, color: Colors.grey),
                              SizedBox(height: 10.h),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
                              ),
                              SizedBox(height: 12.h),
                              ElevatedButton(
                                onPressed: _fetchAlerts,
                                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                                child: const Text('আবার চেষ্টা করুন', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredAlerts.isEmpty
                        ? RefreshIndicator(
                            onRefresh: _fetchAlerts,
                            color: primaryGreen,
                            child: ListView(
                              padding: EdgeInsets.all(24.w),
                              children: [
                                SizedBox(height: 60.h),
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.all(20.w),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFDCFCE7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.wb_sunny_rounded, color: primaryGreen, size: 48.sp),
                                  ),
                                ),
                                SizedBox(height: 18.h),
                                Text(
                                  'আবহাওয়া স্বাভাবিক আছে',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  'এই মুহূর্তে আপনার এলাকায় কোনো চরম আবহাওয়া বা দুর্যোগের সতর্কতা নেই।',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchAlerts,
                            color: primaryGreen,
                            child: ListView.separated(
                              padding: EdgeInsets.all(16.w),
                              itemCount: _filteredAlerts.length,
                              separatorBuilder: (context, index) => SizedBox(height: 12.h),
                              itemBuilder: (context, index) {
                                final alert = _filteredAlerts[index];
                                final bgColor = _severityBgColor(alert.severity);
                                final textColor = _severityTextColor(alert.severity);
                                final borderColor = _severityBorderColor(alert.severity);

                                return InkWell(
                                  onTap: () => _showAlertDetail(alert),
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(color: borderColor),
                                      boxShadow: [
                                        BoxShadow(
                                          color: textColor.withValues(alpha: 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10.w),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _alertIcon(alert.alertType),
                                            color: textColor,
                                            size: 24.sp,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(6.r),
                                                    ),
                                                    child: Text(
                                                      alert.severityBn,
                                                      style: TextStyle(
                                                        fontSize: 10.5.sp,
                                                        fontWeight: FontWeight.w800,
                                                        color: textColor,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 6.w),
                                                  Text(
                                                    '· ${alert.alertTypeBn}',
                                                    style: TextStyle(
                                                      fontSize: 11.5.sp,
                                                      fontWeight: FontWeight.w600,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 6.h),
                                              Text(
                                                alert.titleBn,
                                                style: TextStyle(
                                                  fontSize: 14.5.sp,
                                                  fontWeight: FontWeight.w800,
                                                  color: textColor,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                alert.bodyBn,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12.5.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: textColor.withValues(alpha: 0.9),
                                                  height: 1.3,
                                                ),
                                              ),
                                              SizedBox(height: 8.h),
                                              Row(
                                                children: [
                                                  if (alert.targetDistricts.isNotEmpty) ...[
                                                    Icon(Icons.location_on_outlined, size: 12.sp, color: textColor),
                                                    SizedBox(width: 3.w),
                                                    Expanded(
                                                      child: Text(
                                                        alert.targetDistricts.join(', '),
                                                        style: TextStyle(fontSize: 11.sp, color: textColor),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ] else ...[
                                                    Icon(Icons.public_rounded, size: 12.sp, color: textColor),
                                                    SizedBox(width: 3.w),
                                                    Text(
                                                      'সারা বাংলাদেশ',
                                                      style: TextStyle(fontSize: 11.sp, color: textColor),
                                                    ),
                                                  ],
                                                  const Spacer(),
                                                  Icon(Icons.arrow_forward_ios_rounded, size: 12.sp, color: textColor),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

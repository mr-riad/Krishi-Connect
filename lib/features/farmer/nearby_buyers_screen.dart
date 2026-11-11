// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';
import '../../helpers/call_helper.dart';
import '../../models/krishi_models.dart';
import '../../services/api_service.dart';
import '../shared/chat_screen.dart';

class NearbyBuyersScreen extends StatefulWidget {
  const NearbyBuyersScreen({super.key});

  @override
  State<NearbyBuyersScreen> createState() => _NearbyBuyersScreenState();
}

class _NearbyBuyersScreenState extends State<NearbyBuyersScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  final TextEditingController _districtCtrl = TextEditingController();
  final TextEditingController _upazilaCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMsg;
  List<BuyerRate> _buyerRates = [];

  @override
  void initState() {
    super.initState();
    _fetchNearbyBuyers();
  }

  @override
  void dispose() {
    _districtCtrl.dispose();
    _upazilaCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchNearbyBuyers() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final res = await KrishiApiService.instance.getRates(
        district: _districtCtrl.text.trim().isEmpty ? null : _districtCtrl.text.trim(),
        upazila: _upazilaCtrl.text.trim().isEmpty ? null : _upazilaCtrl.text.trim(),
        sort: 'newest',
        limit: 50,
      );
      if (!mounted) return;
      final items = (res['items'] as List<dynamic>?) ?? [];
      setState(() {
        _buyerRates = items.map((e) => BuyerRate.fromJson(e as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMsg = 'কাছের ক্রেতা লোড করতে সমস্যা হয়েছে';
      });
    }
  }

  Future<void> _callBuyer(BuyerRate rate) async {
    if (rate.buyerPhone != null && rate.buyerPhone!.isNotEmpty) {
      showDirectCallBottomSheet(
        context: context,
        phone: rate.buyerPhone!,
        name: rate.buyerName ?? rate.cropName,
        roleOrType: 'ক্রেতা',
        subtitle: '${rate.cropName} (৳${rate.ratePerUnit.toStringAsFixed(0)}/${rate.unitLabel})',
        location: rate.locationLabel,
      );
      return;
    }
    try {
      final callData = await KrishiApiService.instance
          .triggerCall(targetUid: rate.buyerId, rateId: rate.id);
      final phone = callData['phone'] as String?;
      if (phone != null && mounted) {
        showDirectCallBottomSheet(
          context: context,
          phone: phone,
          name: callData['target_name'] as String? ?? rate.buyerName ?? rate.cropName,
          roleOrType: 'ক্রেতা',
          subtitle: '${rate.cropName} (৳${rate.ratePerUnit.toStringAsFixed(0)}/${rate.unitLabel})',
          location: rate.locationLabel,
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ক্রেতার নম্বর পাওয়া যায়নি'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _chatBuyer(BuyerRate rate) async {
    try {
      final conv = await KrishiApiService.instance.startConversation(
        participantId: rate.buyerId,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conv['id'] as String,
            peerName: rate.buyerName ?? 'ক্রেতা',
            peerPhone: rate.buyerPhone,
            listingTitle: '${rate.cropName} (দর: ৳${rate.ratePerUnit.toStringAsFixed(0)}/${rate.unitLabel})',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('চ্যাট শুরু করতে সমস্যা হয়েছে'),
          backgroundColor: Colors.red.shade700,
        ),
      );
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
            // Top Bar
            Padding(
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'কাছের ক্রেতা ও বাজার',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _fetchNearbyBuyers,
                    icon: Icon(Icons.refresh_rounded, color: primaryGreen, size: 22.sp),
                  ),
                ],
              ),
            ),

            // District & Upazila filter
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _districtCtrl,
                        style: TextStyle(fontSize: 13.sp),
                        onSubmitted: (_) => _fetchNearbyBuyers(),
                        decoration: InputDecoration(
                          hintText: 'জেলা লিখুন...',
                          hintStyle: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                          prefixIcon: Icon(Icons.location_city, size: 16.sp, color: const Color(0xFF6B7280)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _upazilaCtrl,
                        style: TextStyle(fontSize: 13.sp),
                        onSubmitted: (_) => _fetchNearbyBuyers(),
                        decoration: InputDecoration(
                          hintText: 'উপজেলা...',
                          hintStyle: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                          prefixIcon: Icon(Icons.pin_drop_outlined, size: 16.sp, color: const Color(0xFF6B7280)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _fetchNearbyBuyers,
                    child: Container(
                      width: 42.h,
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.search, color: Colors.white, size: 20.sp),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Results List
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMsg != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 40.sp, color: Colors.red.shade400),
                      SizedBox(height: 10.h),
                      Text(_errorMsg!, style: TextStyle(fontSize: 13.sp, color: Colors.red.shade600)),
                      SizedBox(height: 12.h),
                      ElevatedButton(
                        onPressed: _fetchNearbyBuyers,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                        child: const Text('পুনরায় চেষ্টা করুন', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              )
            else if (_buyerRates.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'কোনো ক্রেতা পাওয়া যায়নি',
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchNearbyBuyers,
                  color: primaryGreen,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _buyerRates.length,
                    itemBuilder: (ctx, i) {
                      final rate = _buyerRates[i];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42.w,
                                  height: 42.w,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDCFCE7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.storefront_outlined,
                                      color: primaryGreen, size: 22.sp),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rate.buyerName ?? 'ক্রেতা',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '${rate.cropName} • ৳${rate.ratePerUnit.toStringAsFixed(0)}/${rate.unitLabel}',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 14.sp, color: const Color(0xFF6B7280)),
                                SizedBox(width: 4.w),
                                Text(
                                  rate.locationLabel,
                                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4B5563)),
                                ),
                                if (rate.demandQuantity != null) ...[
                                  SizedBox(width: 14.w),
                                  Icon(Icons.inventory_2_outlined, size: 14.sp, color: const Color(0xFF6B7280)),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${rate.demandQuantity!.toStringAsFixed(0)} ${rate.unitLabel}',
                                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4B5563)),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: 36.h,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _callBuyer(rate),
                                      icon: Icon(Icons.call_outlined, size: 15.sp),
                                      label: Text('সরাসরি কল',
                                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryGreen,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 36.h,
                                    child: OutlinedButton.icon(
                                      onPressed: () => _chatBuyer(rate),
                                      icon: Icon(Icons.chat_outlined, size: 15.sp),
                                      label: Text('চ্যাট',
                                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: primaryGreen,
                                        side: const BorderSide(color: primaryGreen),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

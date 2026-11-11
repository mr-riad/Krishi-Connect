// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/colors.gen.dart';
import '../../models/krishi_models.dart';
import '../../services/api_service.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  List<CropListing> _myPosts = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadMyPosts();
  }

  Future<void> _loadMyPosts() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final raw = await KrishiApiService.instance.getMyListings();
      if (!mounted) return;
      setState(() {
        _myPosts = raw
            .map((e) => CropListing.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } on DioException catch (dioErr) {
      if (!mounted) return;
      final status = dioErr.response?.statusCode;
      String msg = 'পোস্ট লোড করতে সমস্যা হয়েছে ($status)';
      if (status == 401) {
        msg = 'লগইন অনুমোদিত নয় (401 Unauthorized)। অনুগ্রহ করে পুনরায় লগইন করুন।';
      }
      setState(() {
        _isLoading = false;
        _errorMsg = msg;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMsg = 'সমস্যা: ${e.toString()}';
      });
    }
  }

  Future<void> _confirmDelete(CropListing post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          'পোস্ট মুছবেন?',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'আপনি কি "${post.cropName}" পোস্টটি মুছে ফেলতে চান?',
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('না', style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('মুছুন', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await KrishiApiService.instance.deleteListing(post.id);
      if (!mounted) return;
      setState(() => _myPosts.removeWhere((p) => p.id == post.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${post.cropName} পোস্ট মুছে ফেলা হয়েছে'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('মুছতে সমস্যা হয়েছে। পুনরায় চেষ্টা করুন।'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'আমার পোস্ট',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  IconButton(
                    onPressed: _loadMyPosts,
                    icon: Icon(Icons.refresh_rounded, color: primaryGreen, size: 22.sp),
                    tooltip: 'রিফ্রেশ',
                  ),
                ],
              ),
            ),

            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMsg != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48.sp, color: Colors.red.shade400),
                      SizedBox(height: 12.h),
                      Text(_errorMsg!, style: TextStyle(fontSize: 14.sp, color: Colors.red.shade600)),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadMyPosts,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                        child: const Text('পুনরায় চেষ্টা করুন', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              )
            else if (_myPosts.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined, size: 56.sp, color: const Color(0xFF9CA3AF)),
                      SizedBox(height: 12.h),
                      Text('কোনো পোস্ট নেই', style: TextStyle(fontSize: 16.sp, color: const Color(0xFF6B7280))),
                      SizedBox(height: 6.h),
                      Text('ফসল বিক্রির পোস্ট থেকে নতুন পোস্ট করুন', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadMyPosts,
                  color: primaryGreen,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _myPosts.length,
                    itemBuilder: (ctx, index) => _buildPostCard(_myPosts[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(CropListing post) {
    final isActive = post.status == 'active';
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    post.cropName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isActive ? 'সক্রিয়' : post.status == 'sold' ? 'বিক্রিত' : 'বন্ধ',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: isActive ? const Color(0xFF059669) : Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 16.w,
              runSpacing: 6.h,
              children: [
                _infoChip(Icons.scale_outlined,
                    '${post.quantity} ${post.unitLabel}'),
                _infoChip(Icons.currency_exchange,
                    '৳${post.pricePerUnit.toStringAsFixed(0)}/${post.unitLabel}'),
                _infoChip(Icons.location_on_outlined, post.locationLabel),
                _infoChip(Icons.category_outlined, post.categoryLabel),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Mark as sold
                if (isActive)
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        await KrishiApiService.instance
                            .updateListing(post.id, {'status': 'sold'});
                        _loadMyPosts();
                      } catch (_) {}
                    },
                    icon: Icon(Icons.check_circle_outline, size: 16.sp),
                    label: Text('বিক্রিত', style: TextStyle(fontSize: 13.sp)),
                    style: TextButton.styleFrom(foregroundColor: primaryGreen),
                  ),
                SizedBox(width: 8.w),
                // Delete
                OutlinedButton.icon(
                  onPressed: () => _confirmDelete(post),
                  icon: Icon(Icons.delete_outline, size: 16.sp),
                  label: Text('মুছুন', style: TextStyle(fontSize: 13.sp)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: const Color(0xFF6B7280)),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4B5563)),
        ),
      ],
    );
  }
}

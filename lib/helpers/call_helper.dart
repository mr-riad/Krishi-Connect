import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../gen/colors.gen.dart';

/// Converts Bangla digits (০-৯) to standard English digits (0-9)
String convertBanglaToEnglishDigits(String input) {
  const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  var result = input;
  for (int i = 0; i < 10; i++) {
    result = result.replaceAll(banglaDigits[i], '$i');
  }
  return result;
}

/// Makes a direct phone call using the tel: URI scheme
Future<void> makeDirectCall(
  BuildContext context,
  String rawPhoneNumber, {
  String? contactName,
}) async {
  final cleanNumber = convertBanglaToEnglishDigits(rawPhoneNumber)
      .replaceAll(RegExp(r'[^0-9+]'), '');

  if (cleanNumber.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            contactName != null
                ? '$contactName-এর কোনো ফোন নম্বর পাওয়া যায়নি'
                : 'কোনো বৈধ ফোন নম্বর পাওয়া যায়নি',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return;
  }

  final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);

  try {
    final bool launched = await launchUrl(
      launchUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      // Fallback if externalApplication fails, try default mode
      final bool retry = await launchUrl(launchUri);
      if (!retry && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'সরাসরি কল করা সম্ভব হয়নি। নম্বর: $rawPhoneNumber',
            ),
            backgroundColor: Colors.grey.shade800,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'কপি',
              textColor: Colors.greenAccent,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: rawPhoneNumber));
              },
            ),
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('কল করতে ত্রুটি হয়েছে: $rawPhoneNumber'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Displays a bottom sheet with direct call and copy number options
void showDirectCallBottomSheet({
  required BuildContext context,
  required String name,
  required String phone,
  String? roleOrType,
  String? subtitle,
  String? location,
}) {
  const Color primaryGreen = AppColors.primaryGreen;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0FDF4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.phone_in_talk_rounded,
                        color: primaryGreen,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'সরাসরি কল করুন',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFF6B7280),
                  splashRadius: 20.r,
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // Contact Info Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      if (roleOrType != null && roleOrType.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            roleOrType,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF4B5563),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (location != null && location.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.sp,
                          color: const Color(0xFF6B7280),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(
                        Icons.call_rounded,
                        size: 16.sp,
                        color: primaryGreen,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: primaryGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Call Now Primary Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  makeDirectCall(context, phone, contactName: name);
                },
                icon: const Icon(Icons.phone_rounded),
                label: Text(
                  'এখনই সরাসরি কল করুন',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10.h),

            // Copy Number Secondary Button
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: phone));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$phone নম্বরটি কপি করা হয়েছে'),
                      backgroundColor: primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: Text(
                  'নম্বর কপি করুন',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF374151),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      );
    },
  );
}


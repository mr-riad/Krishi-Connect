import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_constants.dart';
import '../gen/colors.gen.dart';
import '../gen/assets.gen.dart';
import '../helpers/all_routes.dart';
import '../helpers/di.dart';
import '../helpers/navigation_service.dart';
import '../helpers/ui_helpers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isFarmer = true;
  bool _isLoading = false;

  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  ConfirmationResult? _webConfirmationResult;

  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color bgColor = AppColors.bgColor;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String input) {
    String cleanNumber = input.replaceAll(RegExp(r'\s+|-'), '');
    if (cleanNumber.startsWith('+880')) {
      return cleanNumber;
    } else if (cleanNumber.startsWith('880')) {
      return '+$cleanNumber';
    } else if (cleanNumber.startsWith('0')) {
      return '+88$cleanNumber';
    } else {
      return '+880$cleanNumber';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSendOtp() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty) {
      _showError("অনুগ্রহ করে আপনার মোবাইল নম্বরটি লিখুন");
      return;
    }

    if (rawPhone.length < 10) {
      _showError("সঠিক ১১ ডিজিটের মোবাইল নম্বর লিখুন");
      return;
    }

    final formattedPhone = _formatPhoneNumber(rawPhone);

    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        // Firebase Web Auth
        _webConfirmationResult = await _auth.signInWithPhoneNumber(
          formattedPhone,
        );
        setState(() => _isLoading = false);
        _openOtpSheet(formattedPhone);
      } else {
        // Android / iOS Auth
        await _auth.verifyPhoneNumber(
          phoneNumber: formattedPhone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-retrieval or instant verification
            await _onSignInWithCredential(credential, formattedPhone);
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() => _isLoading = false);
            _showError(
              e.message ??
                  "ওটিপি পাঠাতে ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।",
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _verificationId = verificationId;
              _isLoading = false;
            });
            _openOtpSheet(formattedPhone);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("একটি সমস্যা হয়েছে: ${e.toString()}");
    }
  }

  Future<void> _handleUserLoggedIn(User user, String phone) async {
    try {
      // Save user details to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'phone': phone,
        'role': isFarmer ? 'farmer' : 'buyer',
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save local session state
      appData.write(kKeyIsLoggedIn, true);
      appData.write(selectedRole, isFarmer ? 'farmer' : 'buyer');
      appData.write(kPhone, phone);

      if (!mounted) return;
      _showSuccess("লগইন সফল হয়েছে!");

      // Navigate according to selected role
      if (isFarmer) {
        NavigationService.navigateToReplacement(Routes.farmerNav);
      } else {
        NavigationService.navigateToReplacement(Routes.buyerNav);
      }
    } catch (e) {
      _showError("ডাটা সংরক্ষণ করতে সমস্যা হয়েছে: ${e.toString()}");
    }
  }

  Future<void> _onSignInWithCredential(
    AuthCredential credential,
    String phone,
  ) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await _handleUserLoggedIn(user, phone);
      }
    } catch (e) {
      _showError("লগইন সম্পন্ন করতে সমস্যা হয়েছে: ${e.toString()}");
    }
  }

  void _openOtpSheet(String phone) {
    final TextEditingController otpController = TextEditingController();
    bool isVerifying = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 24.h,
                bottom:
                    MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  Text(
                    "ওটিপি যাচাই করুন",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "$phone নম্বরে পাঠানো ৬ সংখ্যার কোডটি লিখুন",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // OTP Input
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    child: TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8,
                        color: const Color(0xFF111827),
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "••••••",
                        hintStyle: TextStyle(
                          fontSize: 24.sp,
                          letterSpacing: 8,
                          color: const Color(0xFF9CA3AF),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: isVerifying
                          ? null
                          : () async {
                              final otp = otpController.text.trim();
                              if (otp.length != 6) {
                                _showError("সঠিক ৬ সংখ্যার ওটিপি কোড লিখুন");
                                return;
                              }

                              setSheetState(() => isVerifying = true);

                              try {
                                if (kIsWeb && _webConfirmationResult != null) {
                                  final userCred = await _webConfirmationResult!
                                      .confirm(otp);
                                  if (bottomSheetContext.mounted) {
                                    Navigator.pop(bottomSheetContext);
                                  }
                                  if (userCred.user != null) {
                                    await _handleUserLoggedIn(
                                      userCred.user!,
                                      phone,
                                    );
                                  }
                                } else if (_verificationId != null) {
                                  final credential =
                                      PhoneAuthProvider.credential(
                                        verificationId: _verificationId!,
                                        smsCode: otp,
                                      );
                                  if (bottomSheetContext.mounted) {
                                    Navigator.pop(bottomSheetContext);
                                  }
                                  await _onSignInWithCredential(
                                    credential,
                                    phone,
                                  );
                                }
                              } catch (e) {
                                setSheetState(() => isVerifying = false);
                                _showError(
                                  "ওটিপি কোডটি সঠিক নয়। পুনরায় চেষ্টা করুন।",
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: isVerifying
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              "যাচাই করে এগিয়ে যান",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _handleSendOtp();
                    },
                    child: Text(
                      "ওটিপি পাননি? পুনরায় পাঠান",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UIHelper.verticalSpaceSmall,
              SizedBox(height: 35.h),

              // Logo container
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(12.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Assets.images.krishiConnectLogo.image(
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          "লোগো",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              UIHelper.verticalSpaceMedium,

              // App Name & Tagline
              Text(
                "কৃষি কানেক্ট",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "কৃষক ও ক্রেতার সরাসরি যোগাযোগ",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4B5563),
                ),
              ),

              SizedBox(height: 36.h),

              // Role Selector Toggle (আমি কৃষক / আমি ক্রেতা)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30.r),
                      onTap: () => setState(() => isFarmer = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: isFarmer ? primaryGreen : Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(
                            color: isFarmer
                                ? primaryGreen
                                : const Color(0xFFD1D5DB),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isFarmer
                                  ? primaryGreen.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "আমি কৃষক",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: isFarmer
                                  ? Colors.white
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30.r),
                      onTap: () => setState(() => isFarmer = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: !isFarmer ? primaryGreen : Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(
                            color: !isFarmer
                                ? primaryGreen
                                : const Color(0xFFD1D5DB),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: !isFarmer
                                  ? primaryGreen.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "আমি ক্রেতা",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: !isFarmer
                                  ? Colors.white
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28.h),

              // Mobile Input Label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "মোবাইল নম্বর",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Mobile Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                  decoration: InputDecoration(
                    hintText: "01XXXXXXXXX",
                    hintStyle: TextStyle(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.normal,
                    ),
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF6B7280),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          "ওটিপি পাঠান",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}

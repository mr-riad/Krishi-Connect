// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_constants.dart';
import '../../helpers/di.dart';

/// Full-screen dedicated token viewer.
/// Shows the current Firebase ID token with options to:
///   • Copy the whole token to clipboard
///   • Force-refresh the token (to get a new 1-hour token)
///   • View the token split into parts
class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  String? _token;
  String? _uid;
  bool _loading = true;
  bool _copied = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _copied = false;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'ব্যবহারকারী লগইন করা নেই';
          _loading = false;
        });
        return;
      }
      final token = await user.getIdToken(forceRefresh);
      // persist fresh token
      if (token != null) appData.write(kKeyAccessToken, token);
      setState(() {
        _token = token;
        _uid = user.uid;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'টোকেন পেতে সমস্যা হয়েছে: $e';
        _loading = false;
      });
    }
  }

  Future<void> _copy() async {
    if (_token == null) return;
    await Clipboard.setData(ClipboardData(text: _token!));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16A34A),
        foregroundColor: Colors.white,
        title: const Text(
          'Firebase Auth Token',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'টোকেন রিফ্রেশ করুন',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : () => _loadToken(forceRefresh: true),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A)))
          : _error != null
              ? _buildError()
              : _buildTokenView(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 56),
            SizedBox(height: 16.h),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700, fontSize: 15.sp),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('আবার চেষ্টা করুন'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
              onPressed: _loadToken,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Info banner ──
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFF16A34A).withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF16A34A)),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'এই টোকেনটি Postman-এ Authorization header-এ Bearer টোকেন হিসেবে ব্যবহার করুন। টোকেন ১ ঘণ্টা মেয়াদী।',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF15803D),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // ── UID ──
          Text(
            'Firebase UID',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 6.h),
          _infoBox(_uid ?? '—'),
          SizedBox(height: 20.h),

          // ── Postman header ──
          Text(
            'Postman Header (কপি করুন)',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 6.h),
          _infoBox('Bearer ${_token ?? ''}', monospace: true, maxLines: 1),
          SizedBox(height: 8.h),

          // ── Copy button ──
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton.icon(
              icon: Icon(_copied ? Icons.check : Icons.copy),
              label: Text(
                _copied ? 'কপি হয়ে গেছে ✓' : 'টোকেন কপি করুন',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _copied ? Colors.green.shade700 : const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: _copy,
            ),
          ),
          SizedBox(height: 20.h),

          // ── Full token ──
          Text(
            'Full Token (Bearer বাদে)',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SelectableText(
              _token ?? '—',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.sp,
                color: const Color(0xFF86EFAC),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // ── Refresh button ──
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('নতুন টোকেন নিন (Refresh)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF16A34A),
                side: const BorderSide(color: Color(0xFF16A34A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () => _loadToken(forceRefresh: true),
            ),
          ),
          SizedBox(height: 12.h),

          // ── Postman instructions ──
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Postman-এ ব্যবহারের নিয়ম:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: Colors.amber.shade900,
                  ),
                ),
                SizedBox(height: 8.h),
                _step('1', 'উপরের বাটন থেকে টোকেন কপি করুন'),
                _step('2', 'Postman-এ Authorization ট্যাবে যান'),
                _step('3', 'Type: Bearer Token সিলেক্ট করুন'),
                _step('4', 'Token ফিল্ডে কপি করা টোকেন পেস্ট করুন'),
                _step('5', 'Base URL: https://krishi-connect-backend.onrender.com'),
              ],
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _infoBox(String text, {bool monospace = false, int maxLines = 3}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: monospace ? 'monospace' : null,
          fontSize: monospace ? 11.5.sp : 13.sp,
          color: const Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _step(String num, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade900),
            ),
          ),
        ],
      ),
    );
  }
}


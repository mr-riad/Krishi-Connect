import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../gen/colors.gen.dart';

class TextFontStyle {
  // Initialising Constructor
  TextFontStyle._();

  // Splash & Onboarding Screens (DMSans)
  static final textStyle28cFFFFFFDMSans900 = TextStyle(
    fontFamily: "DMSans",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.cFFFFFF,
    fontSize: 28.sp,
    fontWeight: FontWeight.w900,
  );

  static final textStyle11c606060DMSans400 = TextStyle(
    fontFamily: "DMSans",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c606060,
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
  );

  // Common Outfit Styles (Size + Color + Font + Weight)
  static final textStyle30c000000Outfit500 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c000000,
    fontSize: 30.sp,
    fontWeight: FontWeight.w500,
  );

  static final textStyle28c111827Outfit800 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c111827,
    fontSize: 28.sp,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );

  static final textStyle24c000000Outfit500 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c000000,
    fontSize: 24.sp,
    fontWeight: FontWeight.w500,
  );

  static final textStyle24c111827Outfit700 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c111827,
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
  );

  static final textStyle22c111827Outfit700 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c111827,
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
  );

  static final textStyle20c000000Outfit500 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c000000,
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
  );

  static final textStyle20c111827Outfit700 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c111827,
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
  );

  static final textStyle18c111827Outfit700 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c111827,
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
  );

  static final textStyle18c111827Outfit600 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c111827,
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
  );

  static final textStyle16cFFFFFFOutfit700 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.cFFFFFF,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
  );

  static final textStyle16c111827Outfit600 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c111827,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  static final textStyle16c1F2937Outfit600 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c1F2937,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  static final textStyle15cFFFFFFOutfit700 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.cFFFFFF,
    fontSize: 15.sp,
    fontWeight: FontWeight.w700,
  );

  static final textStyle15c374151Outfit700 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c374151,
    fontSize: 15.sp,
    fontWeight: FontWeight.w700,
  );

  static final textStyle14c111827Outfit600 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c111827,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
  );

  static final textStyle14c374151Outfit600 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c374151,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
  );

  static final textStyle14c4B5563Outfit500 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c4B5563,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );

  static final textStyle14c4B5563Outfit400 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c4B5563,
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
  );

  static final textStyle14c9CA3AFOutfit400 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c9CA3AF,
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
  );

  static final textStyle13c6B7280Outfit400 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c6B7280,
    fontSize: 13.sp,
    fontWeight: FontWeight.normal,
  );

  static final textStyle12c6B7280Outfit500 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c6B7280,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
  );

  static final textStyle12c1E633FOutfit600 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.primaryGreen,
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
  );

  static final textStyle12c92400EOutfit600 = TextStyle(
    fontFamily: "Outfit",
    fontFamilyFallback: const ['Open Sans', 'Roboto', 'Noto Sans'],
    color: AppColors.c92400E,
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
  );

  // Semantic Aliases for easy access
  static final headlineBold = textStyle22c111827Outfit700;
  static final titleMedium = textStyle16c1F2937Outfit600;
  static final labelMedium = textStyle14c374151Outfit600;
  static final bodyRegular = textStyle14c4B5563Outfit400;
  static final hintRegular = textStyle14c9CA3AFOutfit400;
  static final buttonBold = textStyle16cFFFFFFOutfit700;
}

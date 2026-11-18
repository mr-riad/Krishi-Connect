library;

/// Models for Crop Calendar, Intercropping, Disease Diagnosis, and Farming Tips.

// ═══════════════════════════════════════════════════════════
//  CROP CALENDAR & INTERCROPPING
// ═══════════════════════════════════════════════════════════

class SeasonInfo {
  final String id;
  final String nameBn;
  final String nameEn;
  final String monthsBn;
  final String monthsEn;

  const SeasonInfo({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.monthsBn,
    required this.monthsEn,
  });

  factory SeasonInfo.fromJson(Map<String, dynamic> json) {
    return SeasonInfo(
      id: json['id'] as String? ?? '',
      nameBn: json['name_bn'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      monthsBn: json['months_bn'] as String? ?? '',
      monthsEn: json['months_en'] as String? ?? '',
    );
  }
}

class CropItem {
  final String id;
  final String seasonId;
  final String nameBn;
  final String nameEn;
  final String icon;
  final String category;
  final List<int> sowMonths;
  final List<int> harvestMonths;
  final String sowBn;
  final String harvestBn;
  final List<String> companions;
  final String companionNoteBn;

  const CropItem({
    required this.id,
    required this.seasonId,
    required this.nameBn,
    required this.nameEn,
    required this.icon,
    required this.category,
    required this.sowMonths,
    required this.harvestMonths,
    required this.sowBn,
    required this.harvestBn,
    required this.companions,
    required this.companionNoteBn,
  });

  factory CropItem.fromJson(Map<String, dynamic> json) {
    return CropItem(
      id: json['id'] as String? ?? '',
      seasonId: json['season_id'] as String? ?? '',
      nameBn: json['name_bn'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      icon: json['icon'] as String? ?? '🌱',
      category: json['category'] as String? ?? '',
      sowMonths: (json['sow_months'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      harvestMonths: (json['harvest_months'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      sowBn: json['sow_bn'] as String? ?? '',
      harvestBn: json['harvest_bn'] as String? ?? '',
      companions: (json['companions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      companionNoteBn: json['companion_note_bn'] as String? ?? '',
    );
  }
}

class IntercropCombo {
  final String id;
  final String titleBn;
  final String titleEn;
  final String seasonId;
  final String primaryCrop;
  final List<String> companionCrops;
  final String benefitBn;
  final String methodBn;
  final String expectedBenefit;

  const IntercropCombo({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    required this.seasonId,
    required this.primaryCrop,
    required this.companionCrops,
    required this.benefitBn,
    required this.methodBn,
    required this.expectedBenefit,
  });

  factory IntercropCombo.fromJson(Map<String, dynamic> json) {
    return IntercropCombo(
      id: json['id'] as String? ?? '',
      titleBn: json['title_bn'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      seasonId: json['season_id'] as String? ?? '',
      primaryCrop: json['primary_crop'] as String? ?? '',
      companionCrops: (json['companion_crops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      benefitBn: json['benefit_bn'] as String? ?? '',
      methodBn: json['method_bn'] as String? ?? '',
      expectedBenefit: json['expected_benefit'] as String? ?? '',
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  DISEASE DATABASE & DIAGNOSIS
// ═══════════════════════════════════════════════════════════

class CropDisease {
  final String id;
  final String crop;
  final String cropBn;
  final String name;
  final String nameBn;
  final String category;
  final List<String> affectedParts;
  final String symptomsBn;
  final String causesBn;
  final List<String> remediesBn;
  final List<String> preventionBn;
  final String severity;
  final List<String> season;
  final String? imageHint;

  const CropDisease({
    required this.id,
    required this.crop,
    required this.cropBn,
    required this.name,
    required this.nameBn,
    required this.category,
    required this.affectedParts,
    required this.symptomsBn,
    required this.causesBn,
    required this.remediesBn,
    required this.preventionBn,
    required this.severity,
    required this.season,
    this.imageHint,
  });

  factory CropDisease.fromJson(Map<String, dynamic> json) {
    return CropDisease(
      id: json['id'] as String? ?? '',
      crop: json['crop'] as String? ?? '',
      cropBn: json['crop_bn'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameBn: json['name_bn'] as String? ?? '',
      category: json['category'] as String? ?? '',
      affectedParts: (json['affected_parts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      symptomsBn: json['symptoms_bn'] as String? ?? '',
      causesBn: json['causes_bn'] as String? ?? '',
      remediesBn: (json['remedies_bn'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      preventionBn: (json['prevention_bn'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      severity: json['severity'] as String? ?? 'medium',
      season: (json['season'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageHint: json['image_hint'] as String?,
    );
  }

  /// Severity in Bengali
  String get severityBn {
    switch (severity.toLowerCase()) {
      case 'high':
        return 'মারাত্মক';
      case 'medium':
        return 'মাঝারি';
      case 'low':
        return 'কম ঝুঁকিপূর্ণ';
      default:
        return severity;
    }
  }

  /// Category in Bengali
  String get categoryBn {
    switch (category.toLowerCase()) {
      case 'fungal':
        return 'ছত্রাকজনিত';
      case 'bacterial':
        return 'ব্যাকটেরিয়াজনিত';
      case 'viral':
        return 'ভাইরাসজনিত';
      case 'pest':
        return 'কীটপতঙ্গ / বালাই';
      case 'nutritional':
        return 'পুষ্টির অভাব';
      default:
        return category;
    }
  }
}

class DiseasePage {
  final int total;
  final int limit;
  final int offset;
  final List<CropDisease> items;

  const DiseasePage({
    required this.total,
    required this.limit,
    required this.offset,
    required this.items,
  });

  factory DiseasePage.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List<dynamic>? ?? [];
    return DiseasePage(
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int? ?? 20,
      offset: json['offset'] as int? ?? 0,
      items: list.map((e) => CropDisease.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class DiagnosisMatch {
  final String diseaseId;
  final String name;
  final String nameBn;
  final String cropBn;
  final double matchScore;
  final String severity;
  final List<String> topRemedies;
  final List<String> topPrevention;

  const DiagnosisMatch({
    required this.diseaseId,
    required this.name,
    required this.nameBn,
    required this.cropBn,
    required this.matchScore,
    required this.severity,
    required this.topRemedies,
    required this.topPrevention,
  });

  factory DiagnosisMatch.fromJson(Map<String, dynamic> json) {
    return DiagnosisMatch(
      diseaseId: json['disease_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameBn: json['name_bn'] as String? ?? '',
      cropBn: json['crop_bn'] as String? ?? '',
      matchScore: (json['match_score'] as num? ?? 0).toDouble(),
      severity: json['severity'] as String? ?? 'medium',
      topRemedies: (json['top_remedies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      topPrevention: (json['top_prevention'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  int get matchPercent => (matchScore * 100).round().clamp(0, 100);
}

class DiagnosisResponse {
  final String queryCrop;
  final String querySymptoms;
  final List<DiagnosisMatch> matches;
  final String generalAdviceBn;

  const DiagnosisResponse({
    required this.queryCrop,
    required this.querySymptoms,
    required this.matches,
    required this.generalAdviceBn,
  });

  factory DiagnosisResponse.fromJson(Map<String, dynamic> json) {
    final list = json['matches'] as List<dynamic>? ?? [];
    return DiagnosisResponse(
      queryCrop: json['query_crop'] as String? ?? '',
      querySymptoms: json['query_symptoms'] as String? ?? '',
      matches: list.map((e) => DiagnosisMatch.fromJson(e as Map<String, dynamic>)).toList(),
      generalAdviceBn: json['general_advice_bn'] as String? ?? '',
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  FARMING TIPS
// ═══════════════════════════════════════════════════════════

class FarmingTip {
  final String id;
  final String category;
  final String categoryBn;
  final String titleBn;
  final String bodyBn;
  final List<String> crops;
  final List<String> season;

  const FarmingTip({
    required this.id,
    required this.category,
    required this.categoryBn,
    required this.titleBn,
    required this.bodyBn,
    required this.crops,
    required this.season,
  });

  factory FarmingTip.fromJson(Map<String, dynamic> json) {
    return FarmingTip(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      categoryBn: json['category_bn'] as String? ?? '',
      titleBn: json['title_bn'] as String? ?? '',
      bodyBn: json['body_bn'] as String? ?? '',
      crops: (json['crops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      season: (json['season'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class TipPage {
  final int total;
  final int limit;
  final int offset;
  final List<FarmingTip> items;

  const TipPage({
    required this.total,
    required this.limit,
    required this.offset,
    required this.items,
  });

  factory TipPage.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List<dynamic>? ?? [];
    return TipPage(
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int? ?? 20,
      offset: json['offset'] as int? ?? 0,
      items: list.map((e) => FarmingTip.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  DISEASE REPORT (COMMUNITY SURVEILLANCE)
// ═══════════════════════════════════════════════════════════

class DiseaseReport {
  final String id;
  final String crop;
  final String? diseaseName;
  final String symptomsDescription;
  final String severity;
  final String district;
  final String? upazila;
  final double? latitude;
  final double? longitude;
  final List<String> photoUrls;
  final String? notes;
  final String reportedBy;
  final String? reporterName;
  final String createdAt;
  final String status; // pending | reviewed | resolved

  const DiseaseReport({
    required this.id,
    required this.crop,
    this.diseaseName,
    required this.symptomsDescription,
    required this.severity,
    required this.district,
    this.upazila,
    this.latitude,
    this.longitude,
    required this.photoUrls,
    this.notes,
    required this.reportedBy,
    this.reporterName,
    required this.createdAt,
    required this.status,
  });

  factory DiseaseReport.fromJson(Map<String, dynamic> json) {
    return DiseaseReport(
      id: json['id'] as String? ?? '',
      crop: json['crop'] as String? ?? '',
      diseaseName: json['disease_name'] as String?,
      symptomsDescription: json['symptoms_description'] as String? ?? '',
      severity: json['severity'] as String? ?? 'medium',
      district: json['district'] as String? ?? '',
      upazila: json['upazila'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      photoUrls: (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      notes: json['notes'] as String?,
      reportedBy: json['reported_by'] as String? ?? '',
      reporterName: json['reporter_name'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }
}

library;

/// Models for Feature 3: Push Weather Alerts (FCM-based)
/// and Feature 4: Machinery Directory & Ag-News.

// ═══════════════════════════════════════════════════════════
// FEATURE 3: WEATHER ALERTS & FCM
// ═══════════════════════════════════════════════════════════

class WeatherAlert {
  final String id;
  final String alertType; // storm, heavy_rain, flood, drought, cyclone, frost, heatwave, general
  final String severity; // info, warning, danger
  final String titleBn;
  final String? titleEn;
  final String bodyBn;
  final String? bodyEn;
  final List<String> targetDistricts;
  final String? source;
  final String? validUntil;
  final Map<String, dynamic> extraData;
  final int sentCount;
  final String createdAt;
  final String createdBy;

  const WeatherAlert({
    required this.id,
    required this.alertType,
    required this.severity,
    required this.titleBn,
    this.titleEn,
    required this.bodyBn,
    this.bodyEn,
    required this.targetDistricts,
    this.source,
    this.validUntil,
    required this.extraData,
    required this.sentCount,
    required this.createdAt,
    required this.createdBy,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      id: json['id'] as String? ?? '',
      alertType: json['alert_type'] as String? ?? 'general',
      severity: json['severity'] as String? ?? 'warning',
      titleBn: json['title_bn'] as String? ?? '',
      titleEn: json['title_en'] as String?,
      bodyBn: json['body_bn'] as String? ?? '',
      bodyEn: json['body_en'] as String?,
      targetDistricts: (json['target_districts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      source: json['source'] as String?,
      validUntil: json['valid_until']?.toString(),
      extraData: (json['extra_data'] as Map<String, dynamic>?) ?? {},
      sentCount: (json['sent_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
    );
  }

  /// Severity label in Bengali
  String get severityBn {
    switch (severity.toLowerCase()) {
      case 'danger':
        return 'বিপদসংকেত';
      case 'warning':
        return 'সতর্কতা';
      case 'info':
      default:
        return 'তথ্য ও পূর্বাভাস';
    }
  }

  /// Alert type label in Bengali
  String get alertTypeBn {
    switch (alertType.toLowerCase()) {
      case 'storm':
        return 'ঝড়';
      case 'heavy_rain':
        return 'ভারী বৃষ্টি';
      case 'flood':
        return 'বন্যা';
      case 'drought':
        return 'খরা';
      case 'cyclone':
        return 'ঘূর্ণিঝড়';
      case 'frost':
        return 'শীতল আবহাওয়া';
      case 'heatwave':
        return 'তাপপ্রবাহ';
      case 'general':
      default:
        return 'আবহাওয়া বার্তা';
    }
  }
}

class WeatherAlertPage {
  final int total;
  final int limit;
  final int offset;
  final List<WeatherAlert> items;

  const WeatherAlertPage({
    required this.total,
    required this.limit,
    required this.offset,
    required this.items,
  });

  factory WeatherAlertPage.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List<dynamic>? ?? [];
    return WeatherAlertPage(
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      items: list
          .map((e) => WeatherAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FEATURE 4A: MACHINERY DIRECTORY
// ═══════════════════════════════════════════════════════════

class MachineryItem {
  final String id;
  final String machineryType; // tractor, harvester, power_tiller, rice_transplanter, thresher, irrigation_pump, sprayer, other
  final String? brandModel;
  final String ownerName;
  final String phone;
  final String district;
  final String? upazila;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? ratePerHour;
  final double? ratePerBigha;
  final double? ratePerAcre;
  final String availability; // available, booked, unavailable
  final String? description;
  final List<String> photoUrls;
  final String postedBy;
  final String createdAt;
  final String? updatedAt;
  final double? distanceKm;

  const MachineryItem({
    required this.id,
    required this.machineryType,
    this.brandModel,
    required this.ownerName,
    required this.phone,
    required this.district,
    this.upazila,
    this.address,
    this.latitude,
    this.longitude,
    this.ratePerHour,
    this.ratePerBigha,
    this.ratePerAcre,
    required this.availability,
    this.description,
    required this.photoUrls,
    required this.postedBy,
    required this.createdAt,
    this.updatedAt,
    this.distanceKm,
  });

  factory MachineryItem.fromJson(Map<String, dynamic> json) {
    return MachineryItem(
      id: json['id'] as String? ?? '',
      machineryType: json['machinery_type'] as String? ?? 'other',
      brandModel: json['brand_model'] as String?,
      ownerName: json['owner_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      district: json['district'] as String? ?? '',
      upazila: json['upazila'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      ratePerHour: (json['rate_per_hour'] as num?)?.toDouble(),
      ratePerBigha: (json['rate_per_bigha'] as num?)?.toDouble(),
      ratePerAcre: (json['rate_per_acre'] as num?)?.toDouble(),
      availability: json['availability'] as String? ?? 'available',
      description: json['description'] as String?,
      photoUrls: (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      postedBy: json['posted_by'] as String? ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  /// Machine type in Bengali
  String get machineryTypeBn {
    switch (machineryType.toLowerCase()) {
      case 'tractor':
        return 'ট্রাক্টর';
      case 'harvester':
        return 'হারভেস্টার';
      case 'power_tiller':
        return 'পাওয়ার টিলার';
      case 'rice_transplanter':
        return 'রাইস ট্রান্সপ্লান্টার';
      case 'thresher':
        return 'থ্রেশার';
      case 'irrigation_pump':
        return 'সেচ পাম্প';
      case 'sprayer':
        return 'স্প্রেয়ার';
      case 'other':
      default:
        return 'কৃষি যন্ত্র';
    }
  }

  /// Availability status in Bengali
  String get availabilityBn {
    switch (availability.toLowerCase()) {
      case 'available':
        return 'পাওয়া যাচ্ছে';
      case 'booked':
        return 'বুকড';
      case 'unavailable':
      default:
        return 'অনুপলব্ধ';
    }
  }

  bool get isAvailable => availability.toLowerCase() == 'available';

  /// Formatted rate string
  String get formattedRate {
    if (ratePerBigha != null && ratePerBigha! > 0) {
      return '৳${ratePerBigha!.toStringAsFixed(0)} / বিঘা';
    } else if (ratePerHour != null && ratePerHour! > 0) {
      return '৳${ratePerHour!.toStringAsFixed(0)} / ঘণ্টা';
    } else if (ratePerAcre != null && ratePerAcre! > 0) {
      return '৳${ratePerAcre!.toStringAsFixed(0)} / একর';
    }
    return 'আলোচনা সাপেক্ষে';
  }

  String get locationLabel {
    if (upazila != null && upazila!.trim().isNotEmpty) {
      return '$upazila, $district';
    }
    return district;
  }
}

class MachineryPage {
  final int total;
  final int limit;
  final int offset;
  final List<MachineryItem> items;

  const MachineryPage({
    required this.total,
    required this.limit,
    required this.offset,
    required this.items,
  });

  factory MachineryPage.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List<dynamic>? ?? [];
    return MachineryPage(
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      items: list
          .map((e) => MachineryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FEATURE 4B: AG-NEWS & GOVERNMENT SUBSIDIES
// ═══════════════════════════════════════════════════════════

class NewsItem {
  final String id;
  final String category; // subsidy, policy, price_support, training, technology, weather, general
  final String titleBn;
  final String? titleEn;
  final String bodyBn;
  final String? bodyEn;
  final String? source;
  final String? sourceUrl;
  final String? coverImage;
  final List<String> tags;
  final List<String> targetDistricts;
  final String publishedAt;
  final String? expiresAt;
  final bool isActive;
  final String createdBy;
  final String createdAt;
  final int views;

  const NewsItem({
    required this.id,
    required this.category,
    required this.titleBn,
    this.titleEn,
    required this.bodyBn,
    this.bodyEn,
    this.source,
    this.sourceUrl,
    this.coverImage,
    required this.tags,
    required this.targetDistricts,
    required this.publishedAt,
    this.expiresAt,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.views,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      titleBn: json['title_bn'] as String? ?? '',
      titleEn: json['title_en'] as String?,
      bodyBn: json['body_bn'] as String? ?? '',
      bodyEn: json['body_en'] as String?,
      source: json['source'] as String?,
      sourceUrl: json['source_url'] as String?,
      coverImage: json['cover_image'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      targetDistricts: (json['target_districts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      publishedAt: json['published_at']?.toString() ?? '',
      expiresAt: json['expires_at']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      views: (json['views'] as num?)?.toInt() ?? 0,
    );
  }

  /// Category in Bengali
  String get categoryBn {
    switch (category.toLowerCase()) {
      case 'subsidy':
        return 'ভর্তুকি';
      case 'policy':
        return 'নীতিমালা';
      case 'price_support':
        return 'মূল্য সহায়তা';
      case 'training':
        return 'প্রশিক্ষণ';
      case 'technology':
        return 'প্রযুক্তি';
      case 'weather':
        return 'আবহাওয়া';
      case 'general':
      default:
        return 'সাধারণ সংবাদ';
    }
  }

  /// Formatted publication date in Bengali (e.g. ১২ অক্টোবর)
  String get formattedDate {
    if (publishedAt.isEmpty) return 'আজকের সংবাদ';
    try {
      final dt = DateTime.parse(publishedAt).toLocal();
      const months = [
        'জানুয়ারি',
        'ফেব্রুয়ারি',
        'মার্চ',
        'এপ্রিল',
        'মে',
        'জুন',
        'জুলাই',
        'আগস্ট',
        'সেপ্টেম্বর',
        'অক্টোবর',
        'নভেম্বর',
        'ডিসেম্বর'
      ];
      final monthName = months[dt.month - 1];
      final dayBn = _toBnNumber(dt.day);
      return '$dayBn $monthName';
    } catch (_) {
      return publishedAt.split('T').first;
    }
  }

  static String _toBnNumber(int num) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String s = num.toString();
    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(en[i], bn[i]);
    }
    return s;
  }
}

class NewsCategoryModel {
  final String value;
  final String labelBn;
  final String labelEn;

  const NewsCategoryModel({
    required this.value,
    required this.labelBn,
    required this.labelEn,
  });

  factory NewsCategoryModel.fromJson(Map<String, dynamic> json) {
    return NewsCategoryModel(
      value: json['value'] as String? ?? '',
      labelBn: json['label_bn'] as String? ?? '',
      labelEn: json['label_en'] as String? ?? '',
    );
  }
}

class NewsPage {
  final int total;
  final int limit;
  final int offset;
  final List<NewsItem> items;

  const NewsPage({
    required this.total,
    required this.limit,
    required this.offset,
    required this.items,
  });

  factory NewsPage.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List<dynamic>? ?? [];
    return NewsPage(
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      items: list.map((e) => NewsItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

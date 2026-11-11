/// Model for a Crop Listing from the backend.
class CropListing {
  final String id;
  final String cropName;
  final String category;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double pricePerKg;
  final double quantityKg;
  final String? harvestDate;
  final String? description;
  final String district;
  final String? upazila;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<String> photoUrls;
  final String status;
  final String farmerId;
  final String? farmerName;
  final String? farmerPhone;
  final String createdAt;
  final double? distanceKm;

  const CropListing({
    required this.id,
    required this.cropName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.pricePerKg,
    required this.quantityKg,
    this.harvestDate,
    this.description,
    required this.district,
    this.upazila,
    this.address,
    this.latitude,
    this.longitude,
    required this.photoUrls,
    required this.status,
    required this.farmerId,
    this.farmerName,
    this.farmerPhone,
    required this.createdAt,
    this.distanceKm,
  });

  factory CropListing.fromJson(Map<String, dynamic> json) {
    return CropListing(
      id: json['id'] as String,
      cropName: json['crop_name'] as String,
      category: json['category'] as String? ?? 'other',
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'kg',
      pricePerUnit: (json['price_per_unit'] as num).toDouble(),
      pricePerKg: (json['price_per_kg'] as num? ?? 0).toDouble(),
      quantityKg: (json['quantity_kg'] as num? ?? 0).toDouble(),
      harvestDate: json['harvest_date'] as String?,
      description: json['description'] as String?,
      district: json['district'] as String,
      upazila: json['upazila'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      photoUrls: (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: json['status'] as String? ?? 'active',
      farmerId: json['farmer_id'] as String,
      farmerName: json['farmer_name'] as String?,
      farmerPhone: json['farmer_phone'] as String?,
      createdAt: json['created_at'] as String,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  /// Localized unit label in Bengali
  String get unitLabel {
    switch (unit) {
      case 'mon':
        return 'মণ';
      case 'ton':
        return 'টন';
      case 'bag':
        return 'বস্তা';
      default:
        return 'কেজি';
    }
  }

  /// Localized category label in Bengali
  String get categoryLabel {
    switch (category) {
      case 'paddy':
        return 'ধান';
      case 'vegetable':
        return 'সবজি';
      case 'fruit':
        return 'ফল';
      case 'pulse':
        return 'ডাল';
      case 'spice':
        return 'মসলা';
      default:
        return 'অন্যান্য';
    }
  }

  String get locationLabel {
    if (upazila != null && upazila!.isNotEmpty) {
      return '$upazila, $district';
    }
    return district;
  }
}

/// Model for a Buyer Rate from the backend.
class BuyerRate {
  final String id;
  final String cropName;
  final String category;
  final double ratePerUnit;
  final double ratePerKg;
  final String unit;
  final double? demandQuantity;
  final String demandUnit;
  final String district;
  final String? upazila;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int validDays;
  final bool active;
  final String buyerId;
  final String? buyerName;
  final String? buyerPhone;
  final String createdAt;
  final String expiresAt;
  final double? distanceKm;

  const BuyerRate({
    required this.id,
    required this.cropName,
    required this.category,
    required this.ratePerUnit,
    required this.ratePerKg,
    required this.unit,
    this.demandQuantity,
    required this.demandUnit,
    required this.district,
    this.upazila,
    this.address,
    this.latitude,
    this.longitude,
    required this.validDays,
    required this.active,
    required this.buyerId,
    this.buyerName,
    this.buyerPhone,
    required this.createdAt,
    required this.expiresAt,
    this.distanceKm,
  });

  factory BuyerRate.fromJson(Map<String, dynamic> json) {
    return BuyerRate(
      id: json['id'] as String,
      cropName: json['crop_name'] as String,
      category: json['category'] as String? ?? 'other',
      ratePerUnit: (json['rate_per_unit'] as num).toDouble(),
      ratePerKg: (json['rate_per_kg'] as num? ?? 0).toDouble(),
      unit: json['unit'] as String? ?? 'kg',
      demandQuantity: (json['demand_quantity'] as num?)?.toDouble(),
      demandUnit: json['demand_unit'] as String? ?? 'kg',
      district: json['district'] as String,
      upazila: json['upazila'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      validDays: json['valid_days'] as int? ?? 7,
      active: json['active'] as bool? ?? true,
      buyerId: json['buyer_id'] as String,
      buyerName: json['buyer_name'] as String?,
      buyerPhone: json['buyer_phone'] as String?,
      createdAt: json['created_at'] as String,
      expiresAt: json['expires_at'] as String,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  String get unitLabel {
    switch (unit) {
      case 'mon':
        return 'মণ';
      case 'ton':
        return 'টন';
      case 'bag':
        return 'বস্তা';
      default:
        return 'কেজি';
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'paddy':
        return 'ধান';
      case 'vegetable':
        return 'সবজি';
      case 'fruit':
        return 'ফল';
      case 'pulse':
        return 'ডাল';
      case 'spice':
        return 'মসলা';
      default:
        return 'অন্যান্য';
    }
  }

  String get locationLabel {
    if (upazila != null && upazila!.isNotEmpty) {
      return '$upazila, $district';
    }
    return district;
  }
}

/// Model for a UserProfile from the backend.
class UserProfile {
  final String uid;
  final String? role;
  final String? name;
  final String? phone;
  final String? district;
  final String? upazila;
  final String? address;
  final double? latitude;
  final double? longitude;

  const UserProfile({
    required this.uid,
    this.role,
    this.name,
    this.phone,
    this.district,
    this.upazila,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      role: json['role'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      district: json['district'] as String?,
      upazila: json['upazila'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}


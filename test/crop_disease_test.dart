import 'package:flutter_test/flutter_test.dart';
import 'package:krishi_connect/models/crop_disease_models.dart';
import 'package:krishi_connect/networks/endpoints.dart';

void main() {
  group('Endpoints verification', () {
    test('Crop Calendar endpoints', () {
      expect(Endpoints.fullCalendar(), '/calendar');
      expect(Endpoints.seasonCalendar('rabi'), '/calendar/season/rabi');
      expect(Endpoints.monthCalendar(11), '/calendar/month/11');
      expect(Endpoints.intercropGuide(), '/intercrop');
      expect(Endpoints.intercropBySeason('rabi'), '/intercrop/season/rabi');
      expect(Endpoints.intercropByCrop('alu'), '/intercrop/crop/alu');
      expect(Endpoints.intercropCompanions('alu'), '/intercrop/companions/alu');
    });

    test('Disease & Farming Tips endpoints', () {
      expect(Endpoints.diseases(), '/diseases');
      expect(Endpoints.diseaseDetails('paddy_blast'), '/diseases/paddy_blast');
      expect(Endpoints.diseaseCrops(), '/diseases/crops');
      expect(Endpoints.diagnoseDisease(), '/diseases/diagnose');
      expect(Endpoints.tips(), '/tips');
      expect(Endpoints.tipDetails('tip_soil_test'), '/tips/tip_soil_test');
      expect(Endpoints.diseaseReports(), '/disease-reports');
      expect(Endpoints.diseaseReportStats(), '/disease-reports/stats/summary');
    });
  });

  group('Crop & Calendar Models serialization', () {
    test('SeasonInfo.fromJson', () {
      final json = {
        'id': 'rabi',
        'name_bn': 'রবি',
        'name_en': 'Rabi',
        'months_bn': 'কার্তিক - ফাল্গুন',
        'months_en': 'Nov - Mar',
      };
      final season = SeasonInfo.fromJson(json);
      expect(season.id, 'rabi');
      expect(season.nameBn, 'রবি');
    });

    test('CropDisease.fromJson and getters', () {
      final json = {
        'id': 'paddy_blast',
        'crop': 'paddy',
        'crop_bn': 'ধান',
        'name': 'Rice Blast',
        'name_bn': 'ধানের ব্লাস্ট রোগ',
        'category': 'fungal',
        'affected_parts': ['leaf', 'panicle'],
        'symptoms_bn': 'পাতায় ডায়মন্ড আকারের বাদামি দাগ',
        'causes_bn': 'ম্যাগনাপর্থে ওরাইজি ছত্রাক',
        'remedies_bn': ['ট্রাইসাইক্লাজোল ৭৫% WP স্প্রে করুন'],
        'prevention_bn': ['বীজ শোধন করুন'],
        'severity': 'high',
        'season': ['kharif', 'rabi'],
      };
      final disease = CropDisease.fromJson(json);
      expect(disease.id, 'paddy_blast');
      expect(disease.cropBn, 'ধান');
      expect(disease.severityBn, 'মারাত্মক');
      expect(disease.categoryBn, 'ছত্রাকজনিত');
      expect(disease.remediesBn.length, 1);
    });

    test('DiagnosisResponse.fromJson', () {
      final json = {
        'query_crop': 'paddy',
        'query_symptoms': 'পাতায় বাদামি দাগ',
        'matches': [
          {
            'disease_id': 'paddy_blast',
            'name': 'Rice Blast',
            'name_bn': 'ধানের ব্লাস্ট রোগ',
            'crop_bn': 'ধান',
            'match_score': 0.85,
            'severity': 'high',
            'top_remedies': ['ট্রাইসাইক্লাজোল ৭৫% WP'],
            'top_prevention': ['বীজ শোধন'],
          }
        ],
        'general_advice_bn': 'নিচের প্রতিকার অনুসরণ করুন',
      };
      final response = DiagnosisResponse.fromJson(json);
      expect(response.queryCrop, 'paddy');
      expect(response.matches.length, 1);
      expect(response.matches.first.matchPercent, 85);
      expect(response.matches.first.diseaseId, 'paddy_blast');
    });

    test('FarmingTip.fromJson', () {
      final json = {
        'id': 'tip_soil_test',
        'category': 'soil',
        'category_bn': 'মাটি ও জমি ব্যবস্থাপনা',
        'title_bn': 'নিয়মিত মাটি পরীক্ষা',
        'body_bn': 'মাটির পিএইচ পরীক্ষা করে উপযুক্ত সার প্রয়োগ করুন।',
        'crops': ['all'],
        'season': ['kharif', 'rabi'],
      };
      final tip = FarmingTip.fromJson(json);
      expect(tip.id, 'tip_soil_test');
      expect(tip.category, 'soil');
      expect(tip.crops, contains('all'));
    });
  });
}


import 'package:flutter/material.dart';

class HRRCalculator {
  // Constants
  static const int _defaultRestingHeartRate = 60;
  
  // HRR Band definitions
  static const Map<String, Map<String, dynamic>> _hrrBands = {
    'Zone 1': {'min': 50, 'max': 60, 'description': 'Very Light'},
    'Zone 2': {'min': 60, 'max': 70, 'description': 'Light'},
    'Zone 3': {'min': 70, 'max': 80, 'description': 'Moderate'},
    'Zone 4': {'min': 80, 'max': 90, 'description': 'Hard'},
    'Zone 5': {'min': 90, 'max': 100, 'description': 'Very Hard'},
  };

  // Core implementation - calculate max heart rate
  static int calculateMaxHeartRate(int age) {
    return (220 - age).round();
  }

  // Core implementation - calculate HRR percentage
  static double calculateHRRPercentage({
    required int currentHeartRate,
    required int age,
    int? restingHeartRate,
  }) {
    final rhr = restingHeartRate ?? _defaultRestingHeartRate;
    final maxHR = calculateMaxHeartRate(age);
    final hrr = maxHR - rhr;
    
    if (hrr <= 0) return 0.0;
    
    final percentage = ((currentHeartRate - rhr) / hrr) * 100;
    return percentage.clamp(0.0, 100.0);
  }

  // Core implementation - get HRR band from percentage
  static String getHRRBand(double hrrPercentage) {
    for (final entry in _hrrBands.entries) {
      final min = entry.value['min'] as int;
      final max = entry.value['max'] as int;
      if (hrrPercentage >= min && hrrPercentage < max) {
        return entry.key;
      }
    }
    return 'Zone 5'; // Default to highest zone
  }

  // Core implementation - get HRR band from heart rate
  static String getHRRBandFromHeartRate({
    required int currentHeartRate,
    required int age,
    int? restingHeartRate,
  }) {
    final hrrPercentage = calculateHRRPercentage(
      currentHeartRate: currentHeartRate,
      age: age,
      restingHeartRate: restingHeartRate,
    );
    return getHRRBand(hrrPercentage);
  }

  // Core implementation - target heart rate range
  static Map<String, num> targetRangeCore({
    required int age,
    required int hrRest,
    required double lowPct,
    required double highPct,
    int? hrAvg,
    int? hrPeak,
  }) {
    final maxHr = calculateMaxHeartRate(age);
    final reserve = maxHr - hrRest;
    final low = (hrRest + reserve * lowPct).round();
    final high = (hrRest + reserve * highPct).round();
    return {'low': low, 'high': high, 'avg': (hrAvg ?? 0).toDouble()};
  }

  // Core implementation - calculate compliance
  static double calculateCompliance({
    required int minutesInBand,
    required int totalMinutes,
  }) {
    if (totalMinutes == 0) return 0.0;
    return (minutesInBand / totalMinutes).clamp(0.0, 1.0);
  }

  // Core implementation - calculate HRR score
  static double calculateHRRScore({
    required int hrRest,
    required int age,
    required int hrAvg,
    required int hrPeak,
    required int minutesInBand,
    required int totalMinutes,
    required String targetZone,
  }) {
    final avgHRRPercentage = calculateHRRPercentage(
      currentHeartRate: hrAvg,
      age: age,
      restingHeartRate: hrRest,
    );
    
    final compliance = calculateCompliance(
      minutesInBand: minutesInBand,
      totalMinutes: totalMinutes,
    );
    
    double baseScore = avgHRRPercentage;
    double complianceMultiplier = 0.5 + (compliance * 0.5);
    
    double durationFactor = 1.0;
    if (totalMinutes >= 30 && totalMinutes <= 60) {
      durationFactor = 1.0;
    } else if (totalMinutes < 30) {
      durationFactor = totalMinutes / 30.0;
    } else {
      durationFactor = 1.0 + ((totalMinutes - 60) * 0.005);
    }
    
    double zoneFactor = 1.0;
    switch (targetZone) {
      case 'Zone 1': zoneFactor = 0.8; break;
      case 'Zone 2': zoneFactor = 1.0; break;
      case 'Zone 3': zoneFactor = 1.2; break;
      case 'Zone 4': zoneFactor = 1.4; break;
      case 'Zone 5': zoneFactor = 1.6; break;
    }
    
    final finalScore = baseScore * complianceMultiplier * durationFactor * zoneFactor;
    return finalScore.clamp(0.0, 200.0);
  }

  // Core implementation - calculate preview
  static Map<String, dynamic> calculatePreview({
    required int hrRest,
    required int age,
    required int hrAvg,
    required int totalMinutes,
    String? targetZone,
  }) {
    final zone = targetZone ?? getHRRBandFromHeartRate(
      currentHeartRate: hrAvg,
      age: age,
      restingHeartRate: hrRest,
    );
    
    final hrrPercentage = calculateHRRPercentage(
      currentHeartRate: hrAvg,
      age: age,
      restingHeartRate: hrRest,
    );
    
    final targetRange = getTargetHeartRateRange(
      zone: zone,
      age: age,
      restingHeartRate: hrRest,
    );
    
    final minutesInBand = calculateMinutesInBand(
      avgHeartRate: hrAvg,
      totalMinutes: totalMinutes,
      targetZone: zone,
      age: age,
      restingHeartRate: hrRest,
    );
    
    final compliance = calculateCompliance(
      minutesInBand: minutesInBand,
      totalMinutes: totalMinutes,
    );
    
    return {
      'hrrPercentage': hrrPercentage,
      'zone': zone,
      'targetRange': targetRange,
      'minutesInBand': minutesInBand,
      'compliance': compliance,
      'bandLow': targetRange['min'],
      'bandHigh': targetRange['max'],
    };
  }

  // Core implementation - validate heart rate
  static bool isValidHeartRate(int heartRate, int age) {
    if (heartRate < 40 || heartRate > 250) return false;
    final maxHR = calculateMaxHeartRate(age);
    return heartRate <= maxHR + 10;
  }

  // WRAPPER METHODS FOR BACKWARD COMPATIBILITY

  // Wrapper for calculateTargetHeartRateRange with multiple parameter names
  static Map<String, num> calculateTargetHeartRateRange({
    required int age,
    int? hrRest,
    int? restingHeartRate,
    double? targetLowPercent,
    double? targetHighPercent,
    int? hrAvg,
    int? avgHeartRate,
    int? hrPeak,
    double? lowPct,
    double? highPct,
    String? zone,
    int? totalMinutes,
    int? minutesInBand,
  }) {
    final rest = hrRest ?? restingHeartRate ?? _defaultRestingHeartRate;
    final low = lowPct ?? targetLowPercent ?? 0.6;
    final high = highPct ?? targetHighPercent ?? 0.8;
    final avg = hrAvg ?? avgHeartRate;
    
    if (zone != null) {
      return getTargetHeartRateRange(zone: zone, age: age, restingHeartRate: rest);
    }
    
    return targetRangeCore(
      age: age,
      hrRest: rest,
      lowPct: low,
      highPct: high,
      hrAvg: avg,
      hrPeak: hrPeak,
    );
  }

  // Get target heart rate range for a zone
  static Map<String, int> getTargetHeartRateRange({
    required String zone,
    required int age,
    int? restingHeartRate,
  }) {
    final rhr = restingHeartRate ?? _defaultRestingHeartRate;
    final maxHR = calculateMaxHeartRate(age);
    final bandInfo = _hrrBands[zone];
    
    if (bandInfo == null) {
      return {'min': rhr, 'max': maxHR};
    }
    
    final minPercentage = bandInfo['min'] as int;
    final maxPercentage = bandInfo['max'] as int;
    
    final minHR = ((minPercentage / 100) * (maxHR - rhr) + rhr).round();
    final maxHR_zone = ((maxPercentage / 100) * (maxHR - rhr) + rhr).round();
    
    return {'min': minHR, 'max': maxHR_zone};
  }

  // Calculate minutes in target HRR band
  static int calculateMinutesInBand({
    required int avgHeartRate,
    required int totalMinutes,
    required String targetZone,
    required int age,
    int? restingHeartRate,
  }) {
    final targetRange = getTargetHeartRateRange(
      zone: targetZone,
      age: age,
      restingHeartRate: restingHeartRate,
    );
    
    if (avgHeartRate >= targetRange['min']! && avgHeartRate <= targetRange['max']!) {
      return totalMinutes;
    }
    
    final midTarget = (targetRange['min']! + targetRange['max']!) / 2;
    final deviation = (avgHeartRate - midTarget).abs();
    final maxDeviation = targetRange['max']! - targetRange['min']!;
    
    if (deviation > maxDeviation) return 0;
    
    final proximity = 1.0 - (deviation / maxDeviation);
    return (totalMinutes * proximity).round();
  }

  // Legacy method for backward compatibility
  static double calculateTrainingScore({
    required double hrrPercentage,
    required int durationMinutes,
  }) {
    double baseScore = hrrPercentage;
    
    double durationMultiplier = 1.0;
    if (durationMinutes > 60) {
      durationMultiplier = 1.0 + ((durationMinutes - 60) * 0.01);
    } else if (durationMinutes < 30) {
      durationMultiplier = 0.5 + (durationMinutes * 0.0167);
    }
    
    double zoneBonus = 1.0;
    final band = getHRRBand(hrrPercentage);
    switch (band) {
      case 'Zone 1': zoneBonus = 0.8; break;
      case 'Zone 2': zoneBonus = 1.0; break;
      case 'Zone 3': zoneBonus = 1.2; break;
      case 'Zone 4': zoneBonus = 1.4; break;
      case 'Zone 5': zoneBonus = 1.6; break;
    }
    
    final finalScore = baseScore * durationMultiplier * zoneBonus;
    return finalScore.clamp(0.0, 200.0);
  }

  // Utility methods
  static Map<String, Map<String, dynamic>> getAllHRRBands() => Map.from(_hrrBands);
  
  static Map<String, dynamic>? getHRRBandInfo(String bandName) => _hrrBands[bandName];
  
  static List<String> getRecommendedZones(String trainingGoal) {
    switch (trainingGoal.toLowerCase()) {
      case 'recovery': return ['Zone 1'];
      case 'base_building':
      case 'aerobic': return ['Zone 1', 'Zone 2'];
      case 'tempo':
      case 'threshold': return ['Zone 3', 'Zone 4'];
      case 'interval':
      case 'vo2max': return ['Zone 4', 'Zone 5'];
      case 'mixed':
      default: return ['Zone 2', 'Zone 3', 'Zone 4'];
    }
  }

  // Color methods
  static Color getHRRBandColor(String hrrBand) {
    final RegExp numberRegex = RegExp(r'\d+');
    final match = numberRegex.firstMatch(hrrBand);
    final bandNumber = match != null ? int.parse(match.group(0)!) : 1;
    return getHRRBandColorByNumber(bandNumber);
  }

  static Color getHRRBandColorByNumber(int bandNumber) {
    switch (bandNumber) {
      case 1: return const Color(0xFF4CAF50);
      case 2: return const Color(0xFF8BC34A);
      case 3: return const Color(0xFFFFEB3B);
      case 4: return const Color(0xFFFF9800);
      case 5: return const Color(0xFFF44336);
      default: return const Color(0xFF9E9E9E);
    }
  }

  static String getHRRBandDescription(int hrrBand) {
    switch (hrrBand) {
      case 1: return 'Very Light (50-60%)';
      case 2: return 'Light (60-70%)';
      case 3: return 'Moderate (70-80%)';
      case 4: return 'Hard (80-90%)';
      case 5: return 'Very Hard (90-100%)';
      default: return 'Unknown';
    }
  }

  // Calculate HRR Zone with named parameters (legacy compatibility)
  static Map<String, num> calculateHRRZone({
    required int age,
    required int hrRest,
    required double targetLowPercent,
    required double targetHighPercent,
    int? hrAvg,
    int? hrPeak,
    int? minutesInBand,
    String? targetZone,
    double? compliance,
  }) {
    return targetRangeCore(
      age: age,
      hrRest: hrRest,
      lowPct: targetLowPercent,
      highPct: targetHighPercent,
      hrAvg: hrAvg,
      hrPeak: hrPeak,
    );
  }
}
import 'package:flutter_test/flutter_test.dart';
import 'package:trainix_app/utils/hrr_calculator.dart';

void main() {
  group('HRRCalculator Tests', () {
    test('should calculate max heart rate using Tanaka formula', () {
      // Test case: age 22
      final maxHR = HRRCalculator.calculateMaxHeartRate(22);
      final expected = (208 - (0.7 * 22)).round(); // 208 - 15.4 = 192.6 -> 193
      expect(maxHR, equals(expected));
    });

    test('should calculate HRR percentage using Karvonen method', () {
      // Test case: age 22, resting HR 60, current HR 150
      final hrrPercent = HRRCalculator.calculateHRRPercentage(
        currentHeartRate: 150,
        age: 22,
        restingHeartRate: 60,
      );
      
      // Expected calculation:
      // MaxHR = 208 - (0.7 * 22) = 193 (rounded)
      // HRR% = (150 - 60) / (193 - 60) * 100 = 90/133 * 100 ≈ 67.67%
      expect(hrrPercent, closeTo(67.67, 0.1));
    });

    test('should calculate target heart rate range correctly', () {
      // Test case: age 22, resting HR 60, target 60-70% HRR
      final targetRange = HRRCalculator.calculateTargetHeartRateRange(
        age: 22,
        restingHeartRate: 60,
        targetLowPercent: 60,
        targetHighPercent: 70,
      );
      
      // Expected calculation:
      // MaxHR = 193, RHR = 60, HRR = 133
      // 60% HRR = (133 * 0.6) + 60 = 79.8 + 60 = 139.8 -> 140
      // 70% HRR = (133 * 0.7) + 60 = 93.1 + 60 = 153.1 -> 153
      expect(targetRange['min'], equals(140));
      expect(targetRange['max'], equals(153));
    });

    test('should calculate compliance correctly - acceptance criteria', () {
      // Acceptance criteria: 30min total with 22min in-band -> compliance=0.73
      final compliance = HRRCalculator.calculateCompliance(
        minutesInBand: 22,
        totalMinutes: 30,
      );
      
      expect(compliance, closeTo(0.73, 0.01));
    });

    test('should calculate HRR score with compliance and intensity', () {
      // Test case: compliance 0.73, target 60-70% HRR, 30 minutes total
      final score = HRRCalculator.calculateHRRScore(
        compliance: 0.73,
        targetLowPercent: 60,
        targetHighPercent: 70,
        totalMinutes: 30,
      );
      
      // Expected calculation:
      // Base score = 0.73 * 100 = 73
      // Avg intensity = (60 + 70) / 2 = 65%
      // Intensity multiplier = 1.0 + (65/100) = 1.65
      // Duration factor = 0.5 + (30 * 0.0167) = 0.5 + 0.501 = 1.001
      // Final score = 73 * 1.65 * 1.001 ≈ 120.57
      expect(score, closeTo(120.57, 1.0));
    });

    test('should calculate preview with all parameters', () {
      // Test case matching acceptance criteria
      final preview = HRRCalculator.calculatePreview(
        age: 22,
        restingHeartRate: 60,
        targetLowPercent: 60,
        targetHighPercent: 70,
        totalMinutes: 30,
        minutesInBand: 22,
      );
      
      expect(preview['targetHeartRateMin'], equals(140));
      expect(preview['targetHeartRateMax'], equals(153));
      expect(preview['estimatedMinutesInBand'], equals(22));
      expect(preview['estimatedCompliance'], closeTo(0.73, 0.01));
      expect(preview['estimatedScore'], isA<double>());
    });

    test('should handle edge cases for compliance calculation', () {
      // Test zero total minutes
      final zeroCompliance = HRRCalculator.calculateCompliance(
        minutesInBand: 10,
        totalMinutes: 0,
      );
      expect(zeroCompliance, equals(0.0));

      // Test 100% compliance
      final fullCompliance = HRRCalculator.calculateCompliance(
        minutesInBand: 30,
        totalMinutes: 30,
      );
      expect(fullCompliance, equals(1.0));

      // Test over 100% (should be clamped)
      final overCompliance = HRRCalculator.calculateCompliance(
        minutesInBand: 40,
        totalMinutes: 30,
      );
      expect(overCompliance, equals(1.0));
    });

    test('should validate heart rate data correctly', () {
      // Valid heart rate for age 22
      expect(HRRCalculator.isValidHeartRate(150, 22), isTrue);
      
      // Invalid - too low
      expect(HRRCalculator.isValidHeartRate(30, 22), isFalse);
      
      // Invalid - too high
      expect(HRRCalculator.isValidHeartRate(250, 22), isFalse);
      
      // Edge case - at max HR + tolerance
      final maxHR = HRRCalculator.calculateMaxHeartRate(22);
      expect(HRRCalculator.isValidHeartRate(maxHR + 5, 22), isTrue);
      expect(HRRCalculator.isValidHeartRate(maxHR + 15, 22), isFalse);
    });

    test('should get correct HRR band from percentage', () {
      expect(HRRCalculator.getHRRBand(55), equals('Zone 1'));
      expect(HRRCalculator.getHRRBand(65), equals('Zone 2'));
      expect(HRRCalculator.getHRRBand(75), equals('Zone 3'));
      expect(HRRCalculator.getHRRBand(85), equals('Zone 4'));
      expect(HRRCalculator.getHRRBand(95), equals('Zone 5'));
    });

    test('should handle preview calculation with average heart rate', () {
      // Test with average HR in target zone
      final previewInZone = HRRCalculator.calculatePreview(
        age: 22,
        restingHeartRate: 60,
        targetLowPercent: 60,
        targetHighPercent: 70,
        totalMinutes: 30,
        avgHeartRate: 145, // Should be in 60-70% zone (140-153)
      );
      
      expect(previewInZone['estimatedMinutesInBand'], equals(24)); // 30 * 0.8
      
      // Test with average HR out of target zone
      final previewOutZone = HRRCalculator.calculatePreview(
        age: 22,
        restingHeartRate: 60,
        targetLowPercent: 60,
        targetHighPercent: 70,
        totalMinutes: 30,
        avgHeartRate: 120, // Below target zone
      );
      
      expect(previewOutZone['estimatedMinutesInBand'], equals(15)); // 30 * 0.5
    });
  });
}
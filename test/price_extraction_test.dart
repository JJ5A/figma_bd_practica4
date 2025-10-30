import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Price Extraction Tests', () {
    test('should extract price correctly from Rp format', () {
      String extractPrice(String priceString) {
        // Extract price from string (assuming format "Rp 300.000")
        String result = priceString.replaceAll(RegExp(r'[^\d\.]'), '').replaceAll('.', '');
        return result;
      }

      expect(extractPrice('Rp 300.000'), equals('300000'));
      expect(extractPrice('Rp 150.000'), equals('150000'));
      expect(extractPrice('Rp 1.200.000'), equals('1200000'));
      expect(extractPrice('Rp 50.000'), equals('50000'));
      
      // Test with different formats
      expect(extractPrice('300.000'), equals('300000'));
      expect(extractPrice('150000'), equals('150000'));
    });

    test('should handle edge cases', () {
      String extractPrice(String priceString) {
        String result = priceString.replaceAll(RegExp(r'[^\d\.]'), '').replaceAll('.', '');
        return result;
      }

      expect(extractPrice(''), equals(''));
      expect(extractPrice('Rp'), equals(''));
      expect(extractPrice('abc'), equals(''));
      expect(extractPrice('Rp abc'), equals(''));
    });
  });
}
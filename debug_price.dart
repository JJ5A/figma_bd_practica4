void main() {
  // Test price extraction
  testPriceExtraction();
}

void testPriceExtraction() {
  List<String> testPrices = [
    'Rp 300.000',
    'Rp 280.000', 
    'Rp 320.000',
    'Rp 150.000'
  ];
  
  print('=== TESTING PRICE EXTRACTION ===');
  
  for (String priceString in testPrices) {
    // Old method (problematic)
    String oldMethod = priceString.replaceAll(RegExp(r'[^\d\.]'), '').replaceAll('.', '');
    
    // New method (improved)
    String newMethod = priceString
        .replaceAll('Rp', '')
        .replaceAll(' ', '')
        .replaceAll('.', '');
    
    double oldValue = double.tryParse(oldMethod) ?? 0.0;
    double newValue = double.tryParse(newMethod) ?? 0.0;
    
    print('Original: $priceString');
    print('Old method: $oldMethod -> $oldValue');
    print('New method: $newMethod -> $newValue');
    print('---');
  }
  
  // Test calculation
  print('\n=== TESTING PRICE CALCULATION ===');
  double pricePerNight = 300000; // Rp 300.000
  int nights = 2;
  int guests = 3;
  
  double totalOld = pricePerNight * nights + (guests > 2 ? (guests - 2) * 50000 * nights : 0);
  double totalNew = pricePerNight * nights;
  
  print('Price per night: Rp ${pricePerNight.toStringAsFixed(0)}');
  print('Nights: $nights');
  print('Guests: $guests');
  print('Total (old with surcharge): Rp ${totalOld.toStringAsFixed(0)}');
  print('Total (new simplified): Rp ${totalNew.toStringAsFixed(0)}');
}
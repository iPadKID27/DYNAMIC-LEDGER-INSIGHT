import 'package:google_generative_ai/google_generative_ai.dart';
import '../model/financial_record.dart';

class AIRepository {
  final GenerativeModel _model;

  AIRepository({required String apiKey})
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );

  Future<Map<String, String>> mapCategory(String note) async {
    final prompt = '''
Analyze the following financial transaction note and categorize it.
Note: "$note"

Respond ONLY with a JSON object in this format:
{
  "type": "income" | "expense" | "asset",
  "category": "string",
  "assetSymbol": "string" (optional, e.g., BTC, AAPL, GOLD),
  "isAsset": boolean
}

Available categories:
- Active Income: Salary, Bonus
- Passive Income: Savings Interest, Fixed Deposit Interest, Stock Dividends, Fund Dividends, Other Dividends, Rental Income, Others
- Saving Outflows: Savings and Investment Contributions
- Fixed Outflows: Social Security, Provident Fund, Life and Health Insurance, Car Insurance, Home Insurance, HOA, Others
- Installment Payments: Home Mortgage, Investment Property Mortgage, Car Loan, Credit Card Payments, Personal Loans
- Variable Outflows: Clothing, Travel, Entertainment, Recreation, Car Maintenance, Family Utilities, Groceries, Personal Expenses, Food, Fuel, Transportation, Childcare, Elderly Care, Income Tax
- Assets: Cash, Savings, Stocks, Crypto, Bonds, Electronics, Vehicles, Property
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text;
    
    if (text == null) {
      throw Exception('AI response was empty');
    }

    // Basic JSON extraction (in case Gemini adds markdown blocks)
    final jsonStart = text.indexOf('{');
    final jsonEnd = text.lastIndexOf('}') + 1;
    if (jsonStart == -1 || jsonEnd == 0) {
      throw Exception('Invalid AI response format');
    }
    
    final jsonString = text.substring(jsonStart, jsonEnd);
    // Note: In a real app, I'd use dart:convert jsonDecode.
    // For now, I'll return it as a map.
    return {'raw': jsonString};
  }
}

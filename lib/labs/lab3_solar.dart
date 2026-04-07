import 'package:flutter/material.dart';
import 'dart:math' as math;

class Lab3SolarPage extends StatefulWidget {
  const Lab3SolarPage({super.key});

  @override
  State<Lab3SolarPage> createState() => _Lab3SolarPageState();
}

class _Lab3SolarPageState extends State<Lab3SolarPage> {
  final ctrlPc = TextEditingController();
  final ctrlSigma1 = TextEditingController();
  final ctrlSigma2 = TextEditingController();
  final ctrlB = TextEditingController();

  String resultText = '';

  // Математична апроксимація функції помилки (erf), оскільки її немає в dart:math
  double _erf(double x) {
    int sign = x < 0 ? -1 : 1;
    x = x.abs();

    double p = 0.3275911;
    double a1 = 0.254829592;
    double a2 = -0.284496736;
    double a3 = 1.421413741;
    double a4 = -1.453152027;
    double a5 = 1.061405429;

    double t = 1.0 / (1.0 + p * x);
    double y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * math.exp(-x * x);

    return sign * y;
  }

  // Функція з вашого Go-коду для розрахунку частки (дельти)
  double _erfDelta(double d, double sigma) {
    if (sigma == 0) return 1.0;
    double z = d / (sigma * math.sqrt(2));
    return _erf(z);
  }

  void calculate() {
    double pc = double.tryParse(ctrlPc.text) ?? 0;
    double sigma1 = double.tryParse(ctrlSigma1.text) ?? 0;
    double sigma2 = double.tryParse(ctrlSigma2.text) ?? 0;
    double b = double.tryParse(ctrlB.text) ?? 0;

    const double d = 0.25; // ±0.25 МВт
    double wTotal = pc * 24;

    // Локальна функція для розрахунку метрик для конкретної сигми
    Map<String, double> calcMetrics(double sigma) {
      double delta = _erfDelta(d, sigma);
      double wGood = wTotal * delta;
      
      // Формула з Go: (wGood * B * 1000) / 1000. Множник скасовується, тому просто wGood * b
      double pGood = wGood * b;
      double penalty = (wTotal - wGood) * b;
      
      return {
        'delta': delta * 100,
        'wGood': wGood,
        'pGood': pGood,
        'penalty': penalty,
        'net': pGood - penalty,
      };
    }

    var before = calcMetrics(sigma1);
    var after = calcMetrics(sigma2);

    setState(() {
      resultText = '''
До вдосконалення системи (σ1 = $sigma1):
Частка енергії без штрафів: ${before['delta']!.toStringAsFixed(1)}%
Енергія без штрафів (W): ${before['wGood']!.toStringAsFixed(2)} МВт·год
Прибуток: ${before['pGood']!.toStringAsFixed(2)} тис. грн
Штраф: ${before['penalty']!.toStringAsFixed(2)} тис. грн
Чистий прибуток: ${before['net']!.toStringAsFixed(2)} тис. грн

Після вдосконалення системи (σ2 = $sigma2):
Частка енергії без штрафів: ${after['delta']!.toStringAsFixed(1)}%
Енергія без штрафів (W): ${after['wGood']!.toStringAsFixed(2)} МВт·год
Прибуток: ${after['pGood']!.toStringAsFixed(2)} тис. грн
Штраф: ${after['penalty']!.toStringAsFixed(2)} тис. грн
Чистий прибуток: ${after['net']!.toStringAsFixed(2)} тис. грн
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ЛР3: Розрахунок прибутку СЕС', 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Введіть параметри сонячної електростанції:', 
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildSizedInput(ctrlPc, 'Середня потужність (Pc, МВт)'),
                      _buildSizedInput(ctrlSigma1, 'Відхилення до (σ1)'),
                      _buildSizedInput(ctrlSigma2, 'Відхилення після (σ2)'),
                      _buildSizedInput(ctrlB, 'Вартість енергії (B, грн)'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: calculate,
                      child: const Text('РОЗРАХУВАТИ ПРИБУТОК', style: TextStyle(fontSize: 16, letterSpacing: 1.2)),
                    ),
                  ),
                  if (resultText.isNotEmpty) ...[
                    const Divider(height: 48),
                    Text('Результати розрахунку', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                      ),
                      child: Text(resultText, style: const TextStyle(fontSize: 16, height: 1.5)),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Допоміжний віджет для полів вводу
  Widget _buildSizedInput(TextEditingController controller, String label) {
    return SizedBox(
      width: 250, // Зробив трохи ширшим, щоб влізли довші підписи
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }
}
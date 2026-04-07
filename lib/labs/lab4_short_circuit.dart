import 'package:flutter/material.dart';
import 'dart:math' as math;

class Lab4ShortCircuitPage extends StatefulWidget {
  const Lab4ShortCircuitPage({super.key});

  @override
  State<Lab4ShortCircuitPage> createState() => _Lab4ShortCircuitPageState();
}

class _Lab4ShortCircuitPageState extends State<Lab4ShortCircuitPage> {
  // Змінна для зберігання вибраного типу розрахунку
  String _mode = 'three'; 

  // Контролери для полів вводу
  final ctrlU = TextEditingController();
  final ctrlZ = TextEditingController();
  final ctrlI = TextEditingController();
  final ctrlT = TextEditingController();
  final ctrlBdop = TextEditingController();

  String resultText = '';

  void calculate() {
    double u = double.tryParse(ctrlU.text) ?? 0;
    double z = double.tryParse(ctrlZ.text) ?? 0;
    double i = double.tryParse(ctrlI.text) ?? 0;
    double t = double.tryParse(ctrlT.text) ?? 0;
    double bdop = double.tryParse(ctrlBdop.text) ?? 0;

    String res = '';

    // Логіка перенесена з вашого Go-сервера
    switch (_mode) {
      case 'three':
        if (z > 0) {
          double val = u / (z * math.sqrt(3));
          res = 'Струм трифазного КЗ: ${val.toStringAsFixed(4)} кА';
        } else {
          res = 'Помилка: Опір (Z) має бути більшим за 0';
        }
        break;
      case 'single':
        if (z > 0) {
          double val = u / z;
          res = 'Струм однофазного КЗ: ${val.toStringAsFixed(4)} кА';
        } else {
          res = 'Помилка: Опір (Z) має бути більшим за 0';
        }
        break;
      case 'thermal':
        if (i > 0 && t > 0) {
          double val = i * i * t;
          bool isStable = val <= bdop;
          // Розрахунок ударного струму (Ta ≈ 0.03 с)
          double impulse = math.sqrt(2) * i * (1 + math.exp(-0.01 / 0.03));
          
          res = '''
Інтеграл Джоуля (струм термічної стійкості): ${val.toStringAsFixed(4)} кА²·с
Ударний струм: ${impulse.toStringAsFixed(4)} кА
Допустимий імпульс: ${bdop.toStringAsFixed(4)} кА²·с

Статус системи: ${isStable ? '✅ СТІЙКА' : '❌ НЕСТІЙКА'}
''';
        } else {
          res = 'Помилка: Струм (I) та час (T) мають бути більшими за 0';
        }
        break;
    }

    setState(() {
      resultText = res;
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
                  Text('ЛР4: Розрахунок струмів короткого замикання', 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  // Випадаючий список для вибору режиму
                  SizedBox(
                    width: 350,
                    child: DropdownButtonFormField<String>(
                      value: _mode,
                      decoration: const InputDecoration(
                        labelText: 'Тип розрахунку',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'three', child: Text('Трифазне коротке замикання')),
                        DropdownMenuItem(value: 'single', child: Text('Однофазне коротке замикання')),
                        DropdownMenuItem(value: 'thermal', child: Text('Термічна стійкість')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _mode = val!;
                          resultText = ''; // Очищаємо результат при зміні режиму
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Динамічний вивід полів залежно від вибраного режиму
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      if (_mode == 'three' || _mode == 'single') ...[
                        _buildSizedInput(ctrlU, 'Напруга (U, кВ)'),
                        _buildSizedInput(ctrlZ, 'Опір (Z, Ом)'),
                      ],
                      if (_mode == 'thermal') ...[
                        _buildSizedInput(ctrlI, 'Струм (I, кА)'),
                        _buildSizedInput(ctrlT, 'Час (T, с)'),
                        _buildSizedInput(ctrlBdop, 'Допустимий імпульс (Bdop)'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: calculate,
                      child: const Text('РОЗРАХУВАТИ', style: TextStyle(fontSize: 16, letterSpacing: 1.2)),
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

  Widget _buildSizedInput(TextEditingController controller, String label) {
    return SizedBox(
      width: 250,
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
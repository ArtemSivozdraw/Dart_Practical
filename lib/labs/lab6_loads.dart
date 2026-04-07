import 'package:flutter/material.dart';
import 'dart:math' as math;

// Клас, що описує один рядок обладнання
class Equipment {
  final int quantity;
  final double power;
  final double kv;
  final double cosPhi;

  Equipment(this.quantity, this.power, this.kv, this.cosPhi);
}

class Lab6LoadsPage extends StatefulWidget {
  const Lab6LoadsPage({super.key});

  @override
  State<Lab6LoadsPage> createState() => _Lab6LoadsPageState();
}

class _Lab6LoadsPageState extends State<Lab6LoadsPage> {
  final ctrlInput = TextEditingController();

  String resultText = '';

  void calculate() {
    String input = ctrlInput.text;
    if (input.trim().isEmpty) {
      setState(() {
        resultText = 'Будь ласка, введіть дані про обладнання.';
      });
      return;
    }

    List<Equipment> eps = [];
    double totalPn = 0;
    double totalKvPower = 0;
    double totalPowerSquare = 0;

    // Аналог логіки strings.Split та strings.Fields з Go
    List<String> lines = input.split('\n');
    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Розбиваємо рядок по пробілах та відкидаємо порожні елементи
      List<String> parts = line.split(RegExp(r'\s+'));
      if (parts.length < 4) continue;

      // Функція для заміни коми на крапку перед парсингом (як у Go-сервері)
      double parseFloat(String s) {
        return double.tryParse(s.replaceAll(',', '.')) ?? 0;
      }

      int n = int.tryParse(parts[0]) ?? 0;
      double pn = parseFloat(parts[1]);
      double kv = parseFloat(parts[2]);
      double cosPhi = parseFloat(parts[3]);

      if (n > 0 && pn > 0) {
        eps.add(Equipment(n, pn, kv, cosPhi));
      }
    }

    if (eps.isEmpty) {
      setState(() {
        resultText = 'Помилка: Не знайдено коректних рядків з даними.';
      });
      return;
    }

    // Розрахунок показників
    for (var ep in eps) {
      double pnGroup = ep.quantity * ep.power;
      totalPn += pnGroup;
      totalKvPower += pnGroup * ep.kv;
      totalPowerSquare += ep.quantity * math.pow(ep.power, 2);
    }

    double kv = 0;
    if (totalPn > 0) {
      kv = totalKvPower / totalPn;
    }

    double ne = 0;
    if (totalPowerSquare > 0) {
      ne = (math.pow(totalPn, 2) / totalPowerSquare).roundToDouble();
    }

    // Константи з вашого Go-сервера
    double kr = 1.25;
    double pp = kr * totalKvPower;
    double qp = totalKvPower * 1.57; // tgφ ≈ 1.57
    double sp = math.sqrt(pp * pp + qp * qp);
    double ip = pp / 0.38; // напруга 0.38 кВ

    setState(() {
      resultText = '''
Всього знайдено груп обладнання: ${eps.length}
Загальна номінальна потужність (ΣPn): ${totalPn.toStringAsFixed(2)} кВт

Середньозважений коефіцієнт використання (Кв): ${kv.toStringAsFixed(4)}
Ефективна кількість ЕП (n_e): ${ne.toInt()}
Коефіцієнт розрахунковий (Кр): ${kr.toStringAsFixed(2)}

Розрахункове активне навантаження (Рр): ${pp.toStringAsFixed(2)} кВт
Розрахункове реактивне навантаження (Qр): ${qp.toStringAsFixed(2)} кВар
Повна розрахункова потужність (Sр): ${sp.toStringAsFixed(2)} кВА
Розрахунковий струм (Iр): ${ip.toStringAsFixed(2)} А
''';
    });
  }

  @override
  void dispose() {
    // Доброю практикою є звільнення контролерів пам'яті
    ctrlInput.dispose();
    super.dispose();
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
                  Text('ЛР6: Розрахунок електричних навантажень', 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      'Введіть дані про обладнання. Кожен рядок — це окрема група приймачів.\n'
                      'Формат рядка: Кількість (шт) Потужність (кВт) Кв cosφ (розділені пробілами)\n\n'
                      'Приклад вводу:\n'
                      '4 10.5 0.6 0.85\n'
                      '2 5.0 0.5 0.8\n'
                      '1 15.0 0.8 0.9', 
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 24),
                  
                  TextField(
                    controller: ctrlInput,
                    maxLines: 8, // Велике поле для тексту
                    decoration: const InputDecoration(
                      labelText: 'Список обладнання',
                      alignLabelWithHint: true, // Вирівнює label по верхньому краю багаторядкового поля
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: calculate,
                      child: const Text('РОЗРАХУВАТИ НАВАНТАЖЕННЯ', style: TextStyle(fontSize: 16, letterSpacing: 1.2)),
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
}
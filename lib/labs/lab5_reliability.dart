import 'package:flutter/material.dart';

// ==========================================
// ГОЛОВНА СТОРІНКА ЛР5 (ВКЛАДКИ)
// ==========================================
class Lab5ReliabilityPage extends StatelessWidget {
  const Lab5ReliabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: const TabBar(
              tabs: [
                Tab(text: 'Надійність системи'),
                Tab(text: 'Розрахунок збитків'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                ReliabilityCalculator(),
                LossesCalculator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// КАЛЬКУЛЯТОР НАДІЙНОСТІ
// ==========================================
class ReliabilityCalculator extends StatefulWidget {
  const ReliabilityCalculator({super.key});

  @override
  State<ReliabilityCalculator> createState() => _ReliabilityCalculatorState();
}

class _ReliabilityCalculatorState extends State<ReliabilityCalculator> {
  final ctrlElements = TextEditingController();
  final ctrlN = TextEditingController();

  String resultText = '';

  // Словники даних з вашого Go-сервера
  final omegaMap = {
    "ПЛ-110 кВ": 0.07,
    "Т-110 кВ": 0.015,
    "ПЛ-35 кВ": 0.02,
    "Т-35 кВ": 0.02,
    "ПЛ-10 кВ": 0.02,
    "КЛ-10 кВ (траншея)": 0.03
  };
  final tvMap = {
    "ПЛ-110 кВ": 10.0,
    "Т-110 кВ": 100.0,
    "ПЛ-35 кВ": 8.0,
    "Т-35 кВ": 80.0,
    "ПЛ-10 кВ": 10.0,
    "КЛ-10 кВ (траншея)": 44.0
  };
  final tpMap = {
    "ПЛ-110 кВ": 35.0,
    "Т-110 кВ": 43.0,
    "ПЛ-35 кВ": 35.0,
    "Т-35 кВ": 28.0,
    "ПЛ-10 кВ": 35.0,
    "КЛ-10 кВ (траншея)": 9.0
  };

  void calculate() {
    String elementsText = ctrlElements.text;
    double n = double.tryParse(ctrlN.text) ?? 0;

    double oSum = 0;
    double tRecO = 0;
    double maxTp = 0;

    // Аналог логіки strings.Contains з Go
    omegaMap.forEach((key, o) {
      if (elementsText.contains(key)) {
        oSum += o;
        tRecO += o * tvMap[key]!;
        if (tpMap[key]! > maxTp) {
          maxTp = tpMap[key]!;
        }
      }
    });

    oSum += 0.03 * n;
    
    // Щоб уникнути ділення на нуль, якщо нічого не введено
    if (oSum == 0) {
      setState(() {
        resultText = 'Будь ласка, введіть коректні елементи системи зі списку.';
      });
      return;
    }

    double tRec = (tRecO + 0.06 * n) / oSum;
    double kap = (oSum * tRec) / 8760;
    double kpp = (1.2 * maxTp) / 8760;
    double odk = 2 * oSum * (kap + kpp);
    double odks = odk + 0.02;

    setState(() {
      resultText = '''
Частота відмов (ω): ${oSum.toStringAsFixed(4)} рік⁻¹
Середній час відновлення (tв): ${tRec.toStringAsFixed(4)} год
Коефіцієнт аварійного простою (kап): ${kap.toStringAsFixed(6)}
Коефіцієнт планового простою (kпп): ${kpp.toStringAsFixed(6)}
Частота системної аварії (ωдк): ${odk.toStringAsFixed(6)} рік⁻¹
Частота системної аварії з урахуванням секційного вимикача (ωдкс): ${odks.toStringAsFixed(6)} рік⁻¹
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
                  Text('Розрахунок надійності', 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Доступні ключі для вводу: ПЛ-110 кВ, Т-110 кВ, ПЛ-35 кВ, Т-35 кВ, ПЛ-10 кВ, КЛ-10 кВ (траншея)', 
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 24),
                  
                  TextField(
                    controller: ctrlElements,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Елементи системи (через кому або пробіл)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSizedInput(ctrlN, 'Кількість елементів (N)'),
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: calculate,
                      child: const Text('РОЗРАХУВАТИ НАДІЙНІСТЬ', style: TextStyle(fontSize: 16, letterSpacing: 1.2)),
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

// ==========================================
// КАЛЬКУЛЯТОР ЗБИТКІВ
// ==========================================
class LossesCalculator extends StatefulWidget {
  const LossesCalculator({super.key});

  @override
  State<LossesCalculator> createState() => _LossesCalculatorState();
}

class _LossesCalculatorState extends State<LossesCalculator> {
  final ctrlOmega = TextEditingController();
  final ctrlTb = TextEditingController();
  final ctrlPm = TextEditingController();
  final ctrlTm = TextEditingController();
  final ctrlKp = TextEditingController();
  final ctrlZa = TextEditingController();
  final ctrlZp = TextEditingController();

  String resultText = '';

  void calculate() {
    double omega = double.tryParse(ctrlOmega.text) ?? 0;
    double tb = double.tryParse(ctrlTb.text) ?? 0;
    double pm = double.tryParse(ctrlPm.text) ?? 0;
    double tm = double.tryParse(ctrlTm.text) ?? 0;
    double kp = double.tryParse(ctrlKp.text) ?? 0;
    double za = double.tryParse(ctrlZa.text) ?? 0;
    double zp = double.tryParse(ctrlZp.text) ?? 0;

    double mwa = omega * tb * pm * tm;
    double mwp = kp * pm * tm;
    double m = za * mwa + zp * mwp;

    setState(() {
      resultText = '''
Математичне сподівання недовідпущеної електроенергії (аварійне): ${mwa.toStringAsFixed(4)} кВт·год
Математичне сподівання недовідпущеної електроенергії (планове): ${mwp.toStringAsFixed(4)} кВт·год
Математичне сподівання збитків від переривання електропостачання: ${m.toStringAsFixed(2)} грн
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
                  Text('Розрахунок збитків', 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildSizedInput(ctrlOmega, 'Частота відмов (ω)'),
                      _buildSizedInput(ctrlTb, 'Час відновлення (tв)'),
                      _buildSizedInput(ctrlPm, 'Потужність (Pm)'),
                      _buildSizedInput(ctrlTm, 'Час максимуму (Tm)'),
                      _buildSizedInput(ctrlKp, 'Коефіцієнт (kp)'),
                      _buildSizedInput(ctrlZa, 'Питомі збитки аварійні (З_а)'),
                      _buildSizedInput(ctrlZp, 'Питомі збитки планові (З_п)'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: calculate,
                      child: const Text('РОЗРАХУВАТИ ЗБИТКИ', style: TextStyle(fontSize: 16, letterSpacing: 1.2)),
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

// ==========================================
// ДОПОМІЖНИЙ ВІДЖЕТ ДЛЯ ПОЛІВ ВВОДУ
// ==========================================
Widget _buildSizedInput(TextEditingController controller, String label) {
  return SizedBox(
    width: 230,
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
      ),
    ),
  );
}
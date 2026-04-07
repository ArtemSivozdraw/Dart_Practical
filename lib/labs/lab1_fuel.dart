import 'package:flutter/material.dart';

// ==========================================
// ГОЛОВНА СТОРІНКА ЛР1 (ВКЛАДКИ)
// ==========================================
class Lab1FuelPage extends StatelessWidget {
  const Lab1FuelPage({super.key});

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
                Tab(text: 'Тверде паливо'),
                Tab(text: 'Мазут'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                SolidFuelCalculator(),
                MazutCalculator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// КАЛЬКУЛЯТОР ТВЕРДОГО ПАЛИВА
// ==========================================
class SolidFuelCalculator extends StatefulWidget {
  const SolidFuelCalculator({super.key});

  @override
  State<SolidFuelCalculator> createState() => _SolidFuelCalculatorState();
}

class _SolidFuelCalculatorState extends State<SolidFuelCalculator> {
  final ctrlH = TextEditingController();
  final ctrlC = TextEditingController();
  final ctrlS = TextEditingController();
  final ctrlN = TextEditingController();
  final ctrlO = TextEditingController();
  final ctrlW = TextEditingController();
  final ctrlA = TextEditingController();

  String resultText = '';

  void calculate() {
    double h = double.tryParse(ctrlH.text) ?? 0;
    double c = double.tryParse(ctrlC.text) ?? 0;
    double s = double.tryParse(ctrlS.text) ?? 0;
    double n = double.tryParse(ctrlN.text) ?? 0;
    double o = double.tryParse(ctrlO.text) ?? 0;
    double w = double.tryParse(ctrlW.text) ?? 0;
    double a = double.tryParse(ctrlA.text) ?? 0;

    double kd = 100 / (100 - w);
    double kc = 100 / (100 - w - a);

    double dryH = h * kd;
    double dryC = c * kd;
    double dryS = s * kd;
    double dryN = n * kd;
    double dryO = o * kd;
    double dryA = a * kd;

    double combH = h * kc;
    double combC = c * kc;
    double combS = s * kc;
    double combN = n * kc;
    double combO = o * kc;

    double qp = (339 * c + 1030 * h - 108.8 * (o - s) - 25 * w) / 1000;
    double qpDry = qp * kd;
    double qpComb = qp * kc;

    setState(() {
      resultText = '''
Коефіцієнт переходу до сухої маси: ${kd.toStringAsFixed(2)}
Коефіцієнт переходу до горючої маси: ${kc.toStringAsFixed(2)}

Склад сухої маси:
H: ${dryH.toStringAsFixed(2)}%, C: ${dryC.toStringAsFixed(2)}%, S: ${dryS.toStringAsFixed(2)}%, N: ${dryN.toStringAsFixed(2)}%, O: ${dryO.toStringAsFixed(2)}%, A: ${dryA.toStringAsFixed(2)}%

Склад горючої маси:
H: ${combH.toStringAsFixed(2)}%, C: ${combC.toStringAsFixed(2)}%, S: ${combS.toStringAsFixed(2)}%, N: ${combN.toStringAsFixed(2)}%, O: ${combO.toStringAsFixed(2)}%

Нижча теплота згоряння (робоча): ${qp.toStringAsFixed(4)} МДж/кг
Нижча теплота згоряння (суха): ${qpDry.toStringAsFixed(4)} МДж/кг
Нижча теплота згоряння (горюча): ${qpComb.toStringAsFixed(4)} МДж/кг
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
                  Text('Введіть компоненти твердого палива (%)', 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildSizedInput(ctrlH, 'Водень (H)'),
                      _buildSizedInput(ctrlC, 'Вуглець (C)'),
                      _buildSizedInput(ctrlS, 'Сірка (S)'),
                      _buildSizedInput(ctrlN, 'Азот (N)'),
                      _buildSizedInput(ctrlO, 'Кисень (O)'),
                      _buildSizedInput(ctrlW, 'Вологість (W)'),
                      _buildSizedInput(ctrlA, 'Зольність (A)'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: calculate,
                      child: const Text('РОЗРАХУВАТИ ТВЕРДЕ ПАЛИВО', style: TextStyle(fontSize: 16, letterSpacing: 1.2)),
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
// КАЛЬКУЛЯТОР МАЗУТУ
// ==========================================
class MazutCalculator extends StatefulWidget {
  const MazutCalculator({super.key});

  @override
  State<MazutCalculator> createState() => _MazutCalculatorState();
}

class _MazutCalculatorState extends State<MazutCalculator> {
  final ctrlC = TextEditingController();
  final ctrlH = TextEditingController();
  final ctrlO = TextEditingController();
  final ctrlS = TextEditingController();
  final ctrlV = TextEditingController();
  final ctrlW = TextEditingController();
  final ctrlA = TextEditingController();
  final ctrlQdaf = TextEditingController();

  String resultText = '';

  void calculate() {
    double c = double.tryParse(ctrlC.text) ?? 0;
    double h = double.tryParse(ctrlH.text) ?? 0;
    double o = double.tryParse(ctrlO.text) ?? 0;
    double s = double.tryParse(ctrlS.text) ?? 0;
    double v = double.tryParse(ctrlV.text) ?? 0;
    double w = double.tryParse(ctrlW.text) ?? 0;
    double a = double.tryParse(ctrlA.text) ?? 0;
    double qdaf = double.tryParse(ctrlQdaf.text) ?? 0;

    double factor = (100 - w - a) / 100;
    
    double outC = c * factor;
    double outH = h * factor;
    double outO = o * factor;
    double outS = s * factor;
    double outV = v * factor;

    double heatWork = qdaf * factor - 0.025 * w;

    setState(() {
      resultText = '''
Склад робочої маси мазуту:
Вуглець (C): ${outC.toStringAsFixed(2)}%
Водень (H): ${outH.toStringAsFixed(2)}%
Кисень (O): ${outO.toStringAsFixed(2)}%
Сірка (S): ${outS.toStringAsFixed(2)}%
Ванадій (V): ${outV.toStringAsFixed(2)} мг/кг
Вологість (W): ${w.toStringAsFixed(2)}%
Зольність (A): ${a.toStringAsFixed(2)}%

Нижча теплота згоряння мазуту на робочу масу: ${heatWork.toStringAsFixed(4)} МДж/кг
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
                  Text('Введіть компоненти горючої маси мазуту (%)', 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildSizedInput(ctrlC, 'Вуглець (C)'),
                      _buildSizedInput(ctrlH, 'Водень (H)'),
                      _buildSizedInput(ctrlO, 'Кисень (O)'),
                      _buildSizedInput(ctrlS, 'Сірка (S)'),
                      _buildSizedInput(ctrlV, 'Ванадій (V) [мг/кг]'),
                      _buildSizedInput(ctrlW, 'Вологість (W) робочої'),
                      _buildSizedInput(ctrlA, 'Зольність (A) робочої'),
                      _buildSizedInput(ctrlQdaf, 'Нижча теплота (Qdaf)'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: calculate,
                      child: const Text('РОЗРАХУВАТИ МАЗУТ', style: TextStyle(fontSize: 16, letterSpacing: 1.2)),
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
    width: 220, // Збільшив ширину, щоб влізли довгі назви для мазуту
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
      ),
    ),
  );
}
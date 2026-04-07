import 'package:flutter/material.dart';

class Lab2EmissionsPage extends StatefulWidget {
  const Lab2EmissionsPage({super.key});

  @override
  State<Lab2EmissionsPage> createState() => _Lab2EmissionsPageState();
}

class _Lab2EmissionsPageState extends State<Lab2EmissionsPage> {
  // Контролери для зчитування кількості спаленого палива
  final ctrlCoal = TextEditingController();
  final ctrlMazut = TextEditingController();
  final ctrlGas = TextEditingController();

  String resultText = '';

  void calculate() {
    // Зчитуємо дані з полів (якщо пусто - беремо 0)
    double coalAmount = double.tryParse(ctrlCoal.text) ?? 0;
    double mazutAmount = double.tryParse(ctrlMazut.text) ?? 0;
    double gasAmount = double.tryParse(ctrlGas.text) ?? 0;

    // --- Математика з вашого server.go ---
    
    // Вугілля
    double kCoal = 150.0;
    double qrCoal = 20.47;
    double coalE = 1e-6 * kCoal * coalAmount * qrCoal;

    // Мазут
    double kMazut = 0.57;
    double qrMazut = 40.40;
    double mazutE = 1e-6 * kMazut * mazutAmount * qrMazut;

    // Газ
    double kGas = 0.0;
    double qrGas = 33.08;
    double gasE = 1e-6 * kGas * gasAmount * qrGas;

    // Сумарний валовий викид
    double total = coalE + mazutE + gasE;

    // Оновлюємо інтерфейс
    setState(() {
      resultText = '''
Валовий викид твердих частинок при спалюванні палива:

Від вугілля: ${coalE.toStringAsFixed(4)} т
Від мазуту: ${mazutE.toStringAsFixed(4)} т
Від природного газу: ${gasE.toStringAsFixed(4)} т

Сумарний валовий викид: ${total.toStringAsFixed(4)} т
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
                  Text('ЛР2: Розрахунок валових викидів', 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Введіть кількість спаленого палива (в тоннах або тис. м³):', 
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildSizedInput(ctrlCoal, 'Вугілля'),
                      _buildSizedInput(ctrlMazut, 'Мазут'),
                      _buildSizedInput(ctrlGas, 'Природний газ'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: calculate,
                      child: const Text('РОЗРАХУВАТИ ВИКИДИ', style: TextStyle(fontSize: 16, letterSpacing: 1.2)),
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

  // Допоміжний віджет для полів
  Widget _buildSizedInput(TextEditingController controller, String label) {
    return SizedBox(
      width: 220,
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
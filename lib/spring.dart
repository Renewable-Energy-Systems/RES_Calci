import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Screen that computes the spring rate *k* (N/m) and optional force F at
/// a given extra deflection. Mirrors the formula used in spring_gui.py.
class SpringCalculatorScreen extends StatefulWidget {
  const SpringCalculatorScreen({super.key});

  @override
  State<SpringCalculatorScreen> createState() => _SpringCalculatorScreenState();
}

class _SpringCalculatorScreenState extends State<SpringCalculatorScreen> {
  final _dController = TextEditingController(); // wire Ø mm
  final _IDController = TextEditingController(); // inner Ø mm
  final _nController = TextEditingController(); // active coils
  final _GController = TextEditingController(text: '77'); // G GPa
  final _deflController = TextEditingController(); // deflection mm

  String _kResult = '– –';
  String _fResult = '– –';

  void _calculate() {
    try {
      final dMm = double.parse(_dController.text.trim());
      final idMm = double.parse(_IDController.text.trim());
      final n = double.parse(_nController.text.trim());
      final gGPa = double.parse(_GController.text.trim());
      final deflMm =
          _deflController.text.trim().isEmpty
              ? 0.0
              : double.parse(_deflController.text.trim());

      if (dMm <= 0 || idMm < 0 || n <= 0 || gGPa <= 0) {
        return _snack('Inputs must be positive (ID ≥ 0).');
      }

      final d = dMm / 1e3; // m
      final id = idMm / 1e3; // m
      final g = gGPa * 1e9; // Pa
      final dMean = id + d; // m

      final k = g * math.pow(d, 4) / (8 * math.pow(dMean, 3) * n);
      setState(() => _kResult = k.toStringAsFixed(2) + ' N/m');

      if (deflMm > 0) {
        final f = k * (deflMm / 1e3);
        setState(() => _fResult = f.toStringAsFixed(2) + ' N');
      } else {
        setState(() => _fResult = '– –');
      }
    } catch (e) {
      _snack('Please enter valid numeric values.');
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF00BCD4);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spring Rate / Force Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field(label: 'Wire Ø d [mm]', controller: _dController),
            _field(label: 'Inner Ø ID [mm]', controller: _IDController),
            _field(label: 'Active coils n', controller: _nController),
            _field(label: 'Shear modulus G [GPa]', controller: _GController),
            _field(
              label: 'Extra deflection Δ [mm] (optional)',
              controller: _deflController,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 32),
            _resultRow('Spring rate k', _kResult, accent),
            _resultRow('Force F', _fResult, accent),
            const SizedBox(height: 36),
            Text(
              'Design & Developed by Pranay Kiran with ❤',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    ),
  );

  Widget _resultRow(String label, String value, Color accent) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: TextStyle(fontSize: 18, color: accent)),
      ],
    ),
  );
}

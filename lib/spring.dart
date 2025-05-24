import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Spring rate *k* (N/m) and force *F* calculator – dark Material look.
class SpringCalculatorScreen extends StatefulWidget {
  const SpringCalculatorScreen({super.key});

  @override
  State<SpringCalculatorScreen> createState() => _SpringCalculatorScreenState();
}

class _SpringCalculatorScreenState extends State<SpringCalculatorScreen> {
  final _dCtrl = TextEditingController(); // wire Ø mm
  final _idCtrl = TextEditingController(); // inner Ø mm
  final _nCtrl = TextEditingController(); // active coils
  final _gCtrl = TextEditingController(text: '77'); // G GPa
  final _deflCtrl = TextEditingController(); // deflection mm

  String _kRes = '– –';
  String _fRes = '– –';

  void _calculate() {
    try {
      final dMm = double.parse(_dCtrl.text.trim());
      final idMm = double.parse(_idCtrl.text.trim());
      final n = double.parse(_nCtrl.text.trim());
      final gGPa = double.parse(_gCtrl.text.trim());
      final deflMm =
          _deflCtrl.text.trim().isEmpty
              ? 0.0
              : double.parse(_deflCtrl.text.trim());

      if (dMm <= 0 || idMm < 0 || n <= 0 || gGPa <= 0) {
        return _snack('Inputs must be positive (ID ≥ 0)');
      }

      final d = dMm / 1e3;
      final id = idMm / 1e3;
      final g = gGPa * 1e9;
      final dMean = id + d;
      final k = g * math.pow(d, 4) / (8 * math.pow(dMean, 3) * n);

      setState(() {
        _kRes = '${k.toStringAsFixed(2)} N/m';
        if (deflMm > 0) {
          final f = k * (deflMm / 1e3);
          _fRes = '${f.toStringAsFixed(2)} N';
        } else {
          _fRes = '– –';
        }
      });
    } catch (_) {
      _snack('Please enter valid numeric values');
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;

    InputDecoration deco(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFF303030),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

    Widget field(String label, TextEditingController c) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: deco(label),
      ),
    );

    Widget result(String lbl, String val) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(lbl, style: const TextStyle(fontSize: 16)),
          Text(val, style: TextStyle(fontSize: 18, color: accent)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spring Rate / Force Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            field('Wire Ø d [mm]', _dCtrl),
            field('Inner Ø ID [mm]', _idCtrl),
            field('Active coils n', _nCtrl),
            field('Shear modulus G [GPa]', _gCtrl),
            field('Extra deflection Δ [mm] (optional)', _deflCtrl),
            const SizedBox(height: 26),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _calculate,
              child: Ink(
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                  child: Text(
                    'Calculate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            result('Spring rate k', _kRes),
            result('Force F', _fRes),
            const SizedBox(height: 40),
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
}

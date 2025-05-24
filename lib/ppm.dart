import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Dew-Point ⇄ ppm H₂O converter (pressure in bar) with refreshed UI.
class PpmConverterScreen extends StatefulWidget {
  const PpmConverterScreen({super.key});

  @override
  State<PpmConverterScreen> createState() => _PpmConverterScreenState();
}

enum Mode { dewToPpm, ppmToDew }

class _PpmConverterScreenState extends State<PpmConverterScreen> {
  final _dewController = TextEditingController();
  final _ppmController = TextEditingController();
  final _pController = TextEditingController(text: '1.0');
  Mode _mode = Mode.dewToPpm;

  // Magnus–Tetens saturation pressure (tC °C) → Pa
  double _pSat(double tC) {
    const a = 6.1078, b = 7.5, c = 237.3;
    return a * math.pow(10.0, b * tC / (c + tC)) * 100.0;
  }

  // Inverse Magnus: p (Pa) → dew-point °C
  double _dewFromPH2O(double p) {
    const a = 6.1078 * 100, b = 7.5, c = 237.3;
    final y = math.log(p / a) / math.ln10; // log10
    return (c * y) / (b - y);
  }

  void _convert() {
    final pBar = double.tryParse(_pController.text.trim());
    if (pBar == null || pBar <= 0) {
      return _snack('Pressure must be > 0');
    }
    if (_mode == Mode.dewToPpm) {
      final tC = double.tryParse(_dewController.text.trim());
      if (tC == null) return _snack('Enter dew-point');
      final ppm = 1e6 * _pSat(tC) / (pBar * 1e5);
      _ppmController.text = ppm.toStringAsFixed(0);
    } else {
      final ppmVal = double.tryParse(_ppmController.text.trim());
      if (ppmVal == null) return _snack('Enter ppm value');
      final tC = _dewFromPH2O(ppmVal * pBar * 1e5 / 1e6);
      _dewController.text = tC.toStringAsFixed(1);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dew-Point ⇄ ppm H₂O'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [_mode == Mode.dewToPpm, _mode == Mode.ppmToDew],
              onPressed:
                  (i) => setState(
                    () => _mode = i == 0 ? Mode.dewToPpm : Mode.ppmToDew,
                  ),
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.black,
              fillColor: accent,
              color: Colors.white,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text('Dew-point → ppm'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text('ppm → Dew-point'),
                ),
              ],
            ),
            const SizedBox(height: 26),
            TextField(
              controller: _dewController,
              enabled: _mode == Mode.dewToPpm,
              keyboardType: TextInputType.number,
              decoration: deco('Dew-point [°C]'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _ppmController,
              enabled: _mode == Mode.ppmToDew,
              keyboardType: TextInputType.number,
              decoration: deco('Water-vapour [ppm(v)]'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _pController,
              keyboardType: TextInputType.number,
              decoration: deco('Total pressure [bar]'),
            ),
            const SizedBox(height: 28),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _convert,
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
                    'Convert',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
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

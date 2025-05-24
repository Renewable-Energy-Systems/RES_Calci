import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Screen that converts Dew‑Point ⇄ ppm H₂O at a given pressure (bar).
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

  // Magnus–Tetens saturation pressure (tC in °C) -> Pa
  double _pSat(double tC) {
    const a = 6.1078; // hPa
    const b = 7.5;
    const c = 237.3; // °C
    final pHpa = a * math.pow(10.0, b * tC / (c + tC));
    return pHpa * 100.0;
  }

  // Inverse Magnus: p (Pa) -> dew‑point °C
  double _dewFromPH2O(double p) {
    const a = 6.1078 * 100; // Pa
    const b = 7.5;
    const c = 237.3;
    final y = math.log(p / a) / math.ln10; // log10
    return (c * y) / (b - y);
  }

  void _convert() {
    final pBar = double.tryParse(_pController.text.trim());
    if (pBar == null || pBar <= 0) {
      _snack('Pressure must be > 0');
      return;
    }
    if (_mode == Mode.dewToPpm) {
      final tC = double.tryParse(_dewController.text.trim());
      if (tC == null) return _snack('Enter dew‑point');
      final pH2O = _pSat(tC);
      final ppm = 1e6 * pH2O / (pBar * 1e5);
      _ppmController.text = ppm.toStringAsFixed(0);
    } else {
      final ppmVal = double.tryParse(_ppmController.text.trim());
      if (ppmVal == null) return _snack('Enter ppm value');
      final pH2O = ppmVal * pBar * 1e5 / 1e6;
      final tC = _dewFromPH2O(pH2O);
      _dewController.text = tC.toStringAsFixed(1);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF00BCD4);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dew‑Point ⇄ ppm H₂O'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ToggleButtons(
              isSelected: [_mode == Mode.dewToPpm, _mode == Mode.ppmToDew],
              onPressed:
                  (i) => setState(
                    () => _mode = i == 0 ? Mode.dewToPpm : Mode.ppmToDew,
                  ),
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.black,
              fillColor: accent,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Dew‑point → ppm'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('ppm → Dew‑point'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _dewController,
              enabled: _mode == Mode.dewToPpm,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Dew‑point [°C]'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ppmController,
              enabled: _mode == Mode.ppmToDew,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Water‑vapour [ppm(v)]',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total pressure [bar]',
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _convert,
                child: const Text('Convert'),
              ),
            ),
            const SizedBox(height: 36),
            Center(
              child: Text(
                'Design & Developed by Pranay Kiran with ❤',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

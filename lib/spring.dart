import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Spring calculator – shows k, working force, max solid force (N & kgf).
class SpringCalculatorScreen extends StatefulWidget {
  const SpringCalculatorScreen({super.key});

  @override
  State<SpringCalculatorScreen> createState() => _SpringCalculatorScreenState();
}

class _SpringCalculatorScreenState extends State<SpringCalculatorScreen> {
  final _dCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _nCtrl = TextEditingController();
  final _gCtrl = TextEditingController(text: '77');
  final _freeCtrl = TextEditingController();
  final _deflCtrl = TextEditingController();

  String _kRes = '– –';
  String _fRes = '– –';
  String _fMax = '– –';
  Map<String, String>? _fab;
  String? _error;

  String _fmtForce(double n) {
    final kg = n / 9.80665;
    return '${n.toStringAsFixed(2)} N  (${kg.toStringAsFixed(2)} kgf)';
  }

  void _calculate() {
    setState(() {
      _fab = null;
      _error = null;
      _kRes = _fRes = _fMax = '– –';
    });
    try {
      final d = double.parse(_dCtrl.text.trim());
      final id = double.parse(_idCtrl.text.trim());
      final n = double.parse(_nCtrl.text.trim());
      final gG = double.parse(_gCtrl.text.trim());
      final freeIn =
          _freeCtrl.text.trim().isEmpty
              ? null
              : double.parse(_freeCtrl.text.trim());
      final deflIn =
          _deflCtrl.text.trim().isEmpty
              ? null
              : double.parse(_deflCtrl.text.trim());
      if (d <= 0 || id < 0 || n <= 1 || gG <= 0) {
        _snack('Numbers must be positive (n>1, ID≥0)');
        return;
      }
      final solid = n * d;
      final free = freeIn ?? solid;
      if (free < solid) {
        setState(() => _error = 'Free length < solid length → impossible');
        return;
      }
      final maxDefl = free - solid;
      final defl = deflIn ?? maxDefl;
      if (defl > maxDefl) {
        setState(
          () => _error = 'Deflection exceeds ${maxDefl.toStringAsFixed(2)} mm',
        );
        return;
      }
      final od = id + 2 * d;
      final Dm = id + d;
      final pitch = (free - d) / (n - 1);
      if (pitch <= 0) {
        setState(() => _error = 'Pitch ≤0');
        return;
      }
      final k =
          gG * 1e9 * math.pow(d / 1e3, 4) / (8 * math.pow(Dm / 1e3, 3) * n);
      final fWork = k * defl / 1e3;
      final fSolid = k * maxDefl / 1e3;
      setState(() {
        _kRes = '${k.toStringAsFixed(2)} N/m';
        _fRes = _fmtForce(fWork);
        _fMax = _fmtForce(fSolid);
        _fab = {
          'Wire diameter': '${d.toStringAsFixed(2)} mm',
          'Inner diameter': '${id.toStringAsFixed(2)} mm',
          'Outer diameter': '${od.toStringAsFixed(2)} mm',
          'Mean coil diameter': '${Dm.toStringAsFixed(2)} mm',
          'Active coils': n.toStringAsFixed(0),
          'Pitch': '${pitch.toStringAsFixed(2)} mm',
          'Free length': '${free.toStringAsFixed(2)} mm',
          'Solid length': '${solid.toStringAsFixed(2)} mm',
          'Max deflection': '${maxDefl.toStringAsFixed(2)} mm',
          'Working deflection': '${defl.toStringAsFixed(2)} mm',
          'Max force (solid)': _fMax,
        };
      });
    } catch (_) {
      _snack('Please enter valid numeric values');
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  InputDecoration _deco(String l) => InputDecoration(
    labelText: l,
    filled: true,
    fillColor: const Color(0xFF303030),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
  Widget _field(String l, TextEditingController c) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: _deco(l),
    ),
  );
  Widget _row(String l, String v, Color a) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(l), Text(v, style: TextStyle(color: a))],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spring Rate / Force Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field('Wire Ø d [mm]', _dCtrl),
            _field('Inner Ø ID [mm]', _idCtrl),
            _field('Active coils n', _nCtrl),
            _field('Shear modulus G [GPa]', _gCtrl),
            _field('Free length [mm] (optional)', _freeCtrl),
            _field('Working deflection [mm] (optional)', _deflCtrl),
            const SizedBox(height: 22),
            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _calculate,
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 40,
                  ),
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
                  child: const Text(
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
            const SizedBox(height: 30),
            _row('Spring rate k', _kRes, accent),
            _row('Force F (working)', _fRes, accent),
            _row('Max force (solid)', _fMax, accent),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ] else if (_fab != null) ...[
              const Divider(height: 32),
              const Text(
                'Fabrication parameters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._fab!.entries.map((e) => _row(e.key, e.value, accent)),
            ],
            const SizedBox(height: 40),
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

import 'package:flutter/material.dart';
import 'ppm.dart';
import 'spring.dart';

void main() => runApp(const RESApp());

class RESApp extends StatelessWidget {
  const RESApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF00BCD4);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RES Tools',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF212121),
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: seed,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renewable Energy Systems – Tools'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.water_drop_outlined, size: 32),
                label: const Text('Dew-Point ⇄ ppm H₂O'),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PpmConverterScreen(),
                      ),
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.compress, size: 32),
                label: const Text('Spring Rate / Force'),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SpringCalculatorScreen(),
                      ),
                    ),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                icon: const Icon(Icons.more_horiz, size: 32),
                label: const Text('More tools coming soon'),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white70,
                ),
              ),
              const SizedBox(height: 72),
              Text(
                'Design & Developed by Pranay Kiran with ❤',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

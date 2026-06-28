import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const AnchorCalculatorApp());
}

class AnchorCalculatorApp extends StatelessWidget {
  const AnchorCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anchor Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1B2A4A), // Deep Navy Blue (Maritime Tone)
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Dark Slate Background
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.teal,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.tealAccent, width: 2.0),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIconColor: Colors.tealAccent,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _depthController = TextEditingController();
  final _loaController = TextEditingController();
  final _shacklesController = TextEditingController(text: "7");

  double _totalChain = 0.0;
  double _turningCircle = 0.0;
  String _statusMessage = "";
  Color _statusColor = Colors.white;

  void _calculate() {
    double depth = double.tryParse(_depthController.text) ?? 0.0;
    double loa = double.tryParse(_loaController.text) ?? 0.0;
    double shackles = double.tryParse(_shacklesController.text) ?? 0.0;

    if (depth <= 0 || loa <= 0 || shackles <= 0) {
      setState(() {
        _statusMessage = "⚠️ Paki-kumpleto ang mga detalye.";
        _statusColor = Colors.orangeAccent;
        _totalChain = 0.0;
      });
      return;
    }

    // 1 shackle = 27.5 meters
    double chainInMeters = shackles * 27.5;
    // Turning Circle Radius = Chain Length + LOA
    double radius = chainInMeters + loa;
    // Scope Ratio = Chain Length / Depth
    double scope = chainInMeters / depth;

    setState(() {
      _totalChain = chainInMeters;
      _turningCircle = radius;

      if (scope < 3) {
        _statusMessage = "⚠️ Masyadong maikli ang kadena!\nScope Ratio: ${scope.toStringAsFixed(1)}";
        _statusColor = Colors.redAccent;
      } else if (scope >= 3 && scope <= 5) {
        _statusMessage = "✅ Ligtas para sa Good Weather.\nScope Ratio: ${scope.toStringAsFixed(1)}";
        _statusColor = Colors.greenAccent;
      } else {
        _statusMessage = "🌊 Heavy Scope! Ligtas sa Rough Weather.\nScope Ratio: ${scope.toStringAsFixed(1)}";
        _statusColor = Colors.blueAccent;
      }
    });
  }

  @override
  void dispose() {
    _depthController.dispose();
    _loaController.dispose();
    _shacklesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '⚓ ANCHOR CALCULATOR',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: _depthController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Water Depth (Meters)',
                        prefixIcon: Icon(Icons.waves),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _loaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Ship's LOA (Meters)",
                        prefixIcon: Icon(Icons.directions_boat),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _shacklesController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Shackles to Let Go',
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate, color: Colors.white),
                      label: const Text(
                        'CALCULATE',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488), // Teal color
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // Box ng Resulta
                    if (_statusMessage.isNotEmpty) ...[
                      Card(
                        color: const Color(0xFF1E293B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_totalChain > 0) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.linear_scale, color: Colors.white70),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Total Chain: ${_totalChain.toStringAsFixed(1)} m',
                                      style: const TextStyle(fontSize: 16, color: Colors.white90),
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.white24, height: 20),
                                Row(
                                  children: [
                                    const Icon(Icons.radar, color: Colors.tealAccent),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Turning Circle: ${_turningCircle.toStringAsFixed(1)} m',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.white24, height: 20),
                              ],
                              Text(
                                _statusMessage,
                                style: TextStyle(fontSize: 15, color: _statusColor, fontWeight: FontWeight.bold, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Modern Developer Credits sa Pinaka-ilalim ng Screen
            Card(
              color: const Color(0xFF1E293B),
              margin: const EdgeInsets.only(top: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white10, width: 1),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.terminal, color: Colors.tealAccent, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Developed by: ',
                      style: TextStyle(fontSize: 13, color: Colors.white60),
                    ),
                    Text(
                      'Renante Fullo',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

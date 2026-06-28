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
      title: 'Anchor Calculator Pro',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1B2A4A),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.teal,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
  
  String _selectedSeabed = 'Sand';
  final List<String> _seabedTypes = ['Sand', 'Mud', 'Clay', 'Rock'];

  double _totalChain = 0.0;
  double _turningCircleMeters = 0.0;
  double _turningCircleCables = 0.0;
  String _statusMessage = "";
  Color _statusColor = Colors.white;

  void _calculatePro() {
    double depth = double.tryParse(_depthController.text) ?? 0.0;
    double loa = double.tryParse(_loaController.text) ?? 0.0;
    double shackles = double.tryParse(_shacklesController.text) ?? 0.0;

    if (depth <= 0 || loa <= 0 || shackles <= 0) {
      setState(() {
        _statusMessage = "⚠️ Paki-kumpleto ang mga detalye.";
        _statusColor = Colors.orangeAccent;
        _totalChain = 0.0;
        _turningCircleMeters = 0.0;
        _turningCircleCables = 0.0;
      });
      return;
    }

    double chainInMeters = shackles * 27.5;
    _totalChain = chainInMeters;

    if (chainInMeters <= depth) {
      setState(() {
        _statusMessage = "❌ Error: Mas mahaba ang lalim kaysa sa kadena!";
        _statusColor = Colors.redAccent;
        _turningCircleMeters = 0.0;
        _turningCircleCables = 0.0;
      });
      return;
    }

    // Advanced: Trigonometric Horizontal Distance (Pythagorean Theorem)
    double horizontalDistance = sqrt(pow(chainInMeters, 2) - pow(depth, 2));
    double radiusMeters = horizontalDistance + loa;
    
    _turningCircleMeters = radiusMeters;
    _turningCircleCables = radiusMeters / 185.2; // 1 Cable = 185.2 Meters

    double scope = chainInMeters / depth;
    double safeMinScope = 4.0; 
    if (_selectedSeabed == 'Mud') safeMinScope = 5.0;
    if (_selectedSeabed == 'Clay') safeMinScope = 3.5;
    if (_selectedSeabed == 'Rock') safeMinScope = 6.0;

    setState(() {
      if (scope < safeMinScope) {
        _statusMessage = "⚠️ WARNING: Short Scope for $_selectedSeabed bottom!\nScope Ratio: ${scope.toStringAsFixed(1)} (Min Safe: $safeMinScope)";
        _statusColor = Colors.redAccent;
      } else if (scope >= safeMinScope && scope <= (safeMinScope + 2)) {
        _statusMessage = "✅ SAFE: Good holding power for $_selectedSeabed.\nScope Ratio: ${scope.toStringAsFixed(1)}";
        _statusColor = Colors.greenAccent;
      } else {
        _statusMessage = "🌊 HEAVY SCOPE: Excellent safety margins.\nScope Ratio: ${scope.toStringAsFixed(1)}";
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
          '⚓ ANCHOR CALCULATOR PRO',
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
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedSeabed,
                      decoration: const InputDecoration(
                        labelText: 'Seabed Type (Bottom Condition)',
                        prefixIcon: Icon(Icons.layers),
                      ),
                      items: _seabedTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSeabed = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed: _calculatePro,
                      icon: const Icon(Icons.analytics, color: Colors.black),
                      label: const Text(
                        'CALCULATE PRO',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (_turningCircleMeters > 0)
                      Card(
                        color: const Color(0xFF1E293B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.linear_scale, color: Colors.tealAccent),
                                title: const Text("Total Chain Length"),
                                trailing: Text(
                                  "${_totalChain.toStringAsFixed(1)} m",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Divider(color: Colors.white10),
                              ListTile(
                                leading: const Icon(Icons.radar, color: Colors.tealAccent),
                                title: const Text("Turning Circle (Meters)"),
                                trailing: Text(
                                  "${_turningCircleMeters.toStringAsFixed(1)} m",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                                ),
                              ),
                              const Divider(color: Colors.white10),
                              ListTile(
                                leading: const Icon(Icons.explore, color: Colors.tealAccent),
                                title: const Text("Turning Circle (Cables)"),
                                trailing: Text(
                                  "${_turningCircleCables.toStringAsFixed(2)} cbl",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                                ),
                              ),
                              const Divider(color: Colors.white10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _statusMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Text(
              '🛠️ Developed by: Renante Fullo',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

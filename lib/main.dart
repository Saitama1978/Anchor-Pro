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
      home: const MainTabScreen(),
    );
  }
}

class CalculationLog {
  final String id;
  final String timestamp;
  final double depth;
  final double loa;
  final double shackles;
  final String seabed;
  final double turningCircle;
  final double cables;
  final String lat;
  final String lng;
  final String status;

  CalculationLog({
    required this.id,
    required this.timestamp,
    required this.depth,
    required this.loa,
    required this.shackles,
    required this.seabed,
    required this.turningCircle,
    required this.cables,
    required this.lat,
    required this.lng,
    required this.status,
  });
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  final List<CalculationLog> _historyLogs = [];

  void _addLog(CalculationLog newLog) {
    setState(() {
      _historyLogs.insert(0, newLog);
    });
  }

  void _deleteLog(String id) {
    setState(() {
      _historyLogs.removeWhere((log) => log.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '⚓ ANCHOR CALCULATOR PRO',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          backgroundColor: const Color(0xFF1E293B),
          centerTitle: true,
          elevation: 4,
          bottom: const TabBar(
            indicatorColor: Colors.tealAccent,
            labelColor: Colors.tealAccent,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.calculate), text: "Calculator"),
              Tab(icon: Icon(Icons.history), text: "History Log"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CalculatorTab(onSaveLog: _addLog),
            HistoryTab(logs: _historyLogs, onDeleteLog: _deleteLog),
          ],
        ),
      ),
    );
  }
}

class CalculatorTab extends StatefulWidget {
  final Function(CalculationLog) onSaveLog;
  const CalculatorTab({super.key, required this.onSaveLog});

  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  final _depthController = TextEditingController();
  final _loaController = TextEditingController();
  final _shacklesController = TextEditingController(text: "7");
  
  final _latDegController = TextEditingController();
  final _latMinController = TextEditingController();
  final _lngDegController = TextEditingController();
  final _lngMinController = TextEditingController();
  
  String _latDirection = 'N';
  String _lngDirection = 'E';
  
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

    String latPsn = "N/A";
    if (_latDegController.text.isNotEmpty && _latMinController.text.isNotEmpty) {
      latPsn = "${_latDegController.text}° ${_latMinController.text}' $_latDirection";
    }

    String lngPsn = "N/A";
    if (_lngDegController.text.isNotEmpty && _lngMinController.text.isNotEmpty) {
      lngPsn = "${_lngDegController.text}° ${_lngMinController.text}' $_lngDirection";
    }

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

    double horizontalDistance = sqrt(pow(chainInMeters, 2) - pow(depth, 2));
    double radiusMeters = horizontalDistance + loa;
    
    _turningCircleMeters = radiusMeters;
    _turningCircleCables = radiusMeters / 185.2;

    double scope = chainInMeters / depth;
    double safeMinScope = 4.0; 
    if (_selectedSeabed == 'Mud') safeMinScope = 5.0;
    if (_selectedSeabed == 'Clay') safeMinScope = 3.5;
    if (_selectedSeabed == 'Rock') safeMinScope = 6.0;

    String calculatedStatus = "";
    if (scope < safeMinScope) {
      calculatedStatus = "⚠️ WARNING: Short Scope for $_selectedSeabed bottom!\nScope Ratio: ${scope.toStringAsFixed(1)} (Min Safe: $safeMinScope)";
      _statusColor = Colors.redAccent;
    } else if (scope >= safeMinScope && scope <= (safeMinScope + 2)) {
      calculatedStatus = "✅ SAFE: Good holding power for $_selectedSeabed.\nScope Ratio: ${scope.toStringAsFixed(1)}";
      _statusColor = Colors.greenAccent;
    } else {
      calculatedStatus = "🌊 HEAVY SCOPE: Excellent safety margins.\nScope Ratio: ${scope.toStringAsFixed(1)}";
      _statusColor = Colors.blueAccent;
    }

    setState(() {
      _statusMessage = calculatedStatus;
    });

    final now = DateTime.now();
    final timeString = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} (${now.day}/${now.month}/${now.year})";
    
    final newLog = CalculationLog(
      id: now.millisecondsSinceEpoch.toString(),
      timestamp: timeString,
      depth: depth,
      loa: loa,
      shackles: shackles,
      seabed: _selectedSeabed,
      turningCircle: _turningCircleMeters,
      cables: _turningCircleCables,
      lat: latPsn,
      lng: lngPsn,
      status: calculatedStatus.replaceAll('\n', ' '),
    );

    widget.onSaveLog(newLog);
  }

  @override
  void dispose() {
    _depthController.dispose();
    _loaController.dispose();
    _shacklesController.dispose();
    _latDegController.dispose();
    _latMinController.dispose();
    _lngDegController.dispose();
    _lngMinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
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
                const SizedBox(height: 15),
                TextField(
                  controller: _loaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Ship's LOA (Meters)",
                    prefixIcon: Icon(Icons.directions_boat),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _shacklesController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Shackles to Let Go',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedSeabed,
                  decoration: const InputDecoration(
                    labelText: 'Seabed Type (Bottom Condition)',
                    prefixIcon: Icon(Icons.layers),
                  ),
                  items: _seabedTypes.map((String type) {
                    return DropdownMenuItem<String>(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() { _selectedSeabed = newValue!; });
                  },
                ),
                const SizedBox(height: 20),
                
                const Text(
                  "📍 GPS Anchor Position (Optional)",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent, fontSize: 14),
                ),
                const SizedBox(height: 12),
                
                // LATITUDE BLOCK
                Row(
                  children: [
                    const SizedBox(width: 45, child: Text("LAT:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _latDegController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Deg (°)', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _latMinController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Min (\')', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: _latDirection,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                        items: ['N', 'S'].map((dir) => DropdownMenuItem(value: dir, child: Text(dir))).toList(),
                        onChanged: (val) => setState(() => _latDirection = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // LONGITUDE BLOCK
                Row(
                  children: [
                    const SizedBox(width: 45, child: Text("LONG:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _lngDegController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Deg (°)', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _lngMinController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Min (\')', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: _lngDirection,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                        items: ['E', 'W'].map((dir) => DropdownMenuItem(value: dir, child: Text(dir))).toList(),
                        onChanged: (val) => setState(() => _lngDirection = val!),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: _calculatePro,
                  icon: const Icon(Icons.analytics, color: Colors.black),
                  label: const Text(
                    'CALCULATE PRO & SAVE LOG',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 25),
                if (_turningCircleMeters > 0)
                  Card(
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.linear_scale, color: Colors.tealAccent),
                            title: const Text("Total Chain Length"),
                            trailing: Text("${_totalChain.toStringAsFixed(1)} m", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          ),
                          const Divider(color: Colors.white10),
                          ListTile(
                            leading: const Icon(Icons.radar, color: Colors.tealAccent),
                            title: const Text("Turning Circle (Meters)"),
                            trailing: Text("${_turningCircleMeters.toStringAsFixed(1)} m", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
                          ),
                          const Divider(color: Colors.white10),
                          ListTile(
                            leading: const Icon(Icons.explore, color: Colors.tealAccent),
                            title: const Text("Turning Circle (Cables)"),
                            trailing: Text("${_turningCircleCables.toStringAsFixed(2)} cbl", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
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
                              style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold, fontSize: 14),
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
        // FIXED BOTTOM FOOTER PARA HINDI MAWALA ANG SIGNATURE
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: const Color(0xFF0F172A),
          child: const Text(
            '🛠️ Developed by: Renante Fullo',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class HistoryTab extends StatelessWidget {
  final List<CalculationLog> logs;
  final Function(String) onDeleteLog;

  const HistoryTab({super.key, required this.logs, required this.onDeleteLog});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 64, color: Colors.white24),
            SizedBox(height: 10),
            Text("No history logs found.", style: TextStyle(color: Colors.white38, fontSize: 16)),
            Text("Mag-calculate muna sa kabilang tab.", style: TextStyle(color: Colors.white24, fontSize: 14)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: const Icon(Icons.anchor, color: Colors.tealAccent),
                  title: Text(
                    "TC: ${log.turningCircle.toStringAsFixed(1)}m (${log.cables.toStringAsFixed(2)} cbl)",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent),
                  ),
                  subtitle: Text(
                    "Time: ${log.timestamp}\nPsn: Lat: ${log.lat} | Lng: ${log.lng}",
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                    onPressed: () {
                      onDeleteLog(log.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Log entry deleted successfully!'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(color: Colors.white10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Depth: ${log.depth}m"),
                              Text("LOA: ${log.loa}m"),
                              Text("Shackles: ${log.shackles}"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("Seabed Type: ${log.seabed}", style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              log.status,
                              style: const TextStyle(fontSize: 13, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        // FIXED FOOTER PATI SA HISTORY LOG TAB
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: const Color(0xFF0F172A),
          child: const Text(
            '🛠️ Developed by: Renante Fullo',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

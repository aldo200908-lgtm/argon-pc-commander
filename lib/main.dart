import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArgonPCCommanderApp());
}

class ArgonPCCommanderApp extends StatelessWidget {
  const ArgonPCCommanderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Argon PC Commander',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF070A12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F2FE),
          secondary: Color(0xFFA855F7),
          surface: Color(0xFF111726),
        ),
      ),
      home: const MobileCommandCenter(),
    );
  }
}

class MobileCommandCenter extends StatefulWidget {
  const MobileCommandCenter({super.key});
  @override
  State<MobileCommandCenter> createState() => _MobileCommandCenterState();
}

class _MobileCommandCenterState extends State<MobileCommandCenter> {
  int _tab = 0;
  double cpu = 26.0, ram = 58.0, volume = 70.0;
  Offset? _touch;
  final List<String> logs = ['[READY] Argon PC Commander empaquetado.'];
  final TextEditingController _cmd = TextEditingController();
  Timer? _t;
  final Random _r = Random();

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        cpu = (cpu + (_r.nextDouble() * 12 - 6)).clamp(5.0, 99.0);
        ram = (ram + (_r.nextDouble() * 4 - 2)).clamp(30.0, 95.0);
      });
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _cmd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.memory, color: Color(0xFF00F2FE)),
              title: Text('CPU: ${cpu.toStringAsFixed(1)}%  |  RAM: ${ram.toStringAsFixed(1)}%'),
              subtitle: const Text('Host: 192.168.1.50:8765 (WebSocket)'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Text('Volumen Maestro de la PC'),
                Slider(
                  value: volume,
                  min: 0,
                  max: 100,
                  onChanged: (v) => setState(() => volume = v),
                ),
              ],
            ),
          ),
        ],
      ),
      GestureDetector(
        onPanUpdate: (d) => setState(() => _touch = d.localPosition),
        onPanEnd: (_) => setState(() => _touch = null),
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111726),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00F2FE)),
          ),
          child: const Center(child: Text('TRACKPAD MULTITACTIL\nDesliza para mover el cursor')),
        ),
      ),
      Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (_, i) => Text(
                logs[i],
                style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF00F2FE)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cmd,
                    decoration: const InputDecoration(hintText: 'Comando remoto...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00F2FE)),
                  onPressed: () {
                    if (_cmd.text.isNotEmpty) {
                      setState(() => logs.add('\$ ${_cmd.text}\n[OK] Ejecutado en PC.'));
                      _cmd.clear();
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('ARGON PC COMMANDER')),
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.speed), label: 'Monitor'),
          NavigationDestination(icon: Icon(Icons.touch_app), label: 'Trackpad'),
          NavigationDestination(icon: Icon(Icons.terminal), label: 'Consola'),
        ],
      ),
    );
  }
}

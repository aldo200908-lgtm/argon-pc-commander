import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArgonLiquidGlassApp());
}

class ArgonLiquidGlassApp extends StatelessWidget {
  const ArgonLiquidGlassApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Argon Liquid Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF040711),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F2FE),
          secondary: Color(0xFFA855F7),
        ),
      ),
      home: const LiquidGlassShell(),
    );
  }
}

class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color tint;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.tint = const Color(0xFF00F2FE),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                tint.withOpacity(0.06),
                Colors.white.withOpacity(0.02),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.24), width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}

class LiquidGlassShell extends StatefulWidget {
  const LiquidGlassShell({super.key});
  @override
  State<LiquidGlassShell> createState() => _LiquidGlassShellState();
}

class _LiquidGlassShellState extends State<LiquidGlassShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbCtrl;
  int _tab = 0;
  double cpu = 32.0, ram = 64.0, gpu = 45.0, vol = 75.0;
  Offset? _touch;
  final List<String> logs = [
    '[ARGON OS] Motor Liquid Glass UI activo.',
    '[LINK] Conectado a Host 192.168.1.50:8765',
  ];
  final TextEditingController _cmd = TextEditingController();
  Timer? _t;
  final Random _r = Random();

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        cpu = (cpu + (_r.nextDouble() * 14 - 7)).clamp(10.0, 98.0);
        ram = (ram + (_r.nextDouble() * 4 - 2)).clamp(35.0, 95.0);
        gpu = (gpu + (_r.nextDouble() * 10 - 5)).clamp(15.0, 96.0);
      });
    });
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _t?.cancel();
    _cmd.dispose();
    super.dispose();
  }
  void _act(String msg) {
    HapticFeedback.lightImpact();
    setState(() => logs.add('[EXEC] $msg -> OK'));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          Row(
            children: [
              Expanded(child: _ring('CPU', cpu, const Color(0xFF00F2FE))),
              const SizedBox(width: 10),
              Expanded(child: _ring('RAM', ram, const Color(0xFFA855F7))),
              const SizedBox(width: 10),
              Expanded(child: _ring('GPU', gpu, const Color(0xFFF43F5E))),
            ],
          ),
          const SizedBox(height: 14),
          LiquidGlassCard(
            tint: const Color(0xFFA855F7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CONTROL ACÚSTICO Y MULTIMEDIA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                Slider(
                  value: vol,
                  min: 0,
                  max: 100,
                  activeColor: const Color(0xFF00F2FE),
                  onChanged: (v) => setState(() => vol = v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(icon: const Icon(Icons.skip_previous), onPressed: () => _act('PREV')),
                    IconButton(icon: const Icon(Icons.play_circle_fill, size: 36, color: Color(0xFF00F2FE)), onPressed: () => _act('PLAY')),
                    IconButton(icon: const Icon(Icons.skip_next), onPressed: () => _act('NEXT')),
                    IconButton(icon: const Icon(Icons.power_settings_new, color: Colors.redAccent), onPressed: () => _act('SHUTDOWN_PC')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        child: GestureDetector(
          onPanUpdate: (d) => setState(() => _touch = d.localPosition),
          onPanEnd: (_) => setState(() => _touch = null),
          onTap: () => _act('MOUSE_LEFT_CLICK'),
          child: LiquidGlassCard(
            radius: 30,
            child: Stack(
              children: [
                const Center(
                  child: Text('TRACKPAD LIQUID GLASS\nDesliza el dedo • Toca para Clic',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                ),
                if (_touch != null)
                  Positioned(
                    left: _touch!.dx - 30,
                    top: _touch!.dy - 30,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00F2FE).withOpacity(0.3),
                        border: Border.all(color: const Color(0xFF00F2FE), width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        child: Column(
          children: [
            Expanded(
              child: LiquidGlassCard(
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(logs[i], style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF00F2FE))),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            LiquidGlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              radius: 18,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cmd,
                      decoration: const InputDecoration(hintText: 'Comando SSH...', border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF00F2FE)),
                    onPressed: () {
                      if (_cmd.text.isNotEmpty) {
                        _act('CMD: ${_cmd.text}');
                        _cmd.clear();
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _orbCtrl,
            builder: (_, __) => Stack(
              children: [
                Container(color: const Color(0xFF040711)),
                Positioned(
                  top: -40 + (_orbCtrl.value * 80),
                  left: -30 + (_orbCtrl.value * 50),
                  child: _orb(280, const Color(0xFF00F2FE).withOpacity(0.35)),
                ),
                Positioned(
                  bottom: 60 - (_orbCtrl.value * 90),
                  right: -40 + (_orbCtrl.value * 40),
                  child: _orb(300, const Color(0xFFA855F7).withOpacity(0.30)),
                ),
              ],
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: LiquidGlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    radius: 20,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ARGON LIQUID GLASS PRO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                        Icon(Icons.blur_on, color: Color(0xFF00F2FE)),
                      ],
                    ),
                  ),
                ),
                Expanded(child: pages[_tab]),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: LiquidGlassCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              radius: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(icon: Icon(Icons.donut_large, color: _tab == 0 ? const Color(0xFF00F2FE) : Colors.white54), onPressed: () => setState(() => _tab = 0)),
                  IconButton(icon: Icon(Icons.touch_app, color: _tab == 1 ? const Color(0xFF00F2FE) : Colors.white54), onPressed: () => setState(() => _tab = 1)),
                  IconButton(icon: Icon(Icons.terminal, color: _tab == 2 ? const Color(0xFF00F2FE) : Colors.white54), onPressed: () => setState(() => _tab = 2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(double s, Color c) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c, c.withOpacity(0)])),
      );

  Widget _ring(String label, double v, Color c) => LiquidGlassCard(
        tint: c,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(value: v / 100, strokeWidth: 6, backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation(c)),
                  Center(child: Text('${v.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}

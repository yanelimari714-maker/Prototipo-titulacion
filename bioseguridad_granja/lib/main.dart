import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'screens/vigilancia_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/temperatura_screen.dart';
import 'screens/alimentacion_screen.dart';

void main() {
  runApp(const GranjaApp());
}

class GranjaApp extends StatelessWidget {
  const GranjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AvícolaLab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        primaryColor: const Color(0xFF14402D),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: const NavegacionPrincipal(),
    );
  }
}

class NavegacionPrincipal extends StatefulWidget {
  const NavegacionPrincipal({super.key});

  @override
  State<NavegacionPrincipal> createState() => _NavegacionPrincipalState();
}

class _NavegacionPrincipalState extends State<NavegacionPrincipal> {
  int _indiceActual = 4; // Inicia en Alimentación para que pruebes rápido
  
  // --- ESTADOS GLOBALES COMPARTIDOS ---
  bool _alertaTemperaturaActiva = false;
  int _diasAvance = 0; // Controla la edad de los pollos en toda la app

  Future<void> _toggleAlertaTemperatura() async {
    setState(() {
      _alertaTemperaturaActiva = !_alertaTemperaturaActiva;
    });
    if (_alertaTemperaturaActiva) {
      try {
        final url = Uri.parse("http://127.0.0.1:8000/alerta/temperatura");
        await http.post(url);
      } catch (e) {
        print("Error al conectar con FastAPI para Telegram: $e");
      }
    }
  }

  void _avanzarDia() {
    setState(() {
      _diasAvance++;
    });
  }

  final List<String> _titulos = [
    "Resumen general", "Temperatura ambiental", "Vigilancia inteligente",
    "Consumo de agua", "Plan de alimentación", "Reportes automatizados"
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pantallas = [
      DashboardScreen(
        alertaTemperaturaActiva: _alertaTemperaturaActiva,
        diasAvance: _diasAvance, // Pasamos los días al resumen
      ),
      TemperaturaScreen(
        alertaActiva: _alertaTemperaturaActiva, 
        onToggleAlerta: _toggleAlertaTemperatura
      ),
      const VigilanciaScreen(),
      const Center(child: Text("Pantalla de Agua en construcción")),
      AlimentacionScreen(
        diasAvance: _diasAvance, 
        onAvanzarDia: _avanzarDia // Pasamos el control a alimentación
      ),
      const Center(child: Text("Pantalla de Reportes en construcción")),
    ];

    return Scaffold(
      body: Row(
        children: [
          // BARRA LATERAL IZQUIERDA
          Container(
            width: 260,
            color: const Color(0xFF14402D),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.eco, color: Colors.white, size: 28),
                          const SizedBox(width: 10),
                          Text("AvícolaLab", style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("ULEAM · Extensión El Carmen", style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("UNIDAD EXPERIMENTAL", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Granja avícola", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("El Carmen, Manabí", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 24, bottom: 8),
                  child: Text("OPERACIÓN Y ANÁLISIS", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _crearItemMenu(Icons.grid_view_rounded, _titulos[0], 0),
                      _crearItemMenu(Icons.thermostat, _titulos[1], 1),
                      _crearItemMenu(Icons.videocam_outlined, _titulos[2], 2),
                      _crearItemMenu(Icons.water_drop_outlined, _titulos[3], 3),
                      _crearItemMenu(Icons.eco_outlined, _titulos[4], 4),
                      _crearItemMenu(Icons.insert_chart_outlined_rounded, _titulos[5], 5),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundColor: Colors.white24, radius: 18, child: Text("MR", style: TextStyle(color: Colors.white, fontSize: 12))),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("María Rivas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text("Coordinación de granja", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

          // ÁREA PRINCIPAL DERECHA
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("Centro de operaciones", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                          Text(_titulos[_indiceActual], style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                            child: Text("Datos de demostración", style: TextStyle(color: Colors.grey[800], fontSize: 12, fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(width: 15),
                          Text("21 oct 2026 · 10:30", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          const SizedBox(width: 15),
                          Icon(Icons.notifications_none, color: Colors.grey[700]),
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(child: pantallas[_indiceActual]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearItemMenu(IconData icono, String titulo, int indice) {
    bool seleccionado = _indiceActual == indice;
    return InkWell(
      onTap: () => setState(() => _indiceActual = indice),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: seleccionado ? Colors.white.withOpacity(0.1) : Colors.transparent,
          border: Border(left: BorderSide(color: seleccionado ? Colors.white : Colors.transparent, width: 4)),
        ),
        child: Row(
          children: [
            Icon(icono, color: seleccionado ? Colors.white : Colors.white70, size: 22),
            const SizedBox(width: 16),
            Text(titulo, style: TextStyle(color: seleccionado ? Colors.white : Colors.white70, fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
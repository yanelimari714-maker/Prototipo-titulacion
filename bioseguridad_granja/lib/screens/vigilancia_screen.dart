import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VigilanciaScreen extends StatefulWidget {
  const VigilanciaScreen({super.key});

  @override
  State<VigilanciaScreen> createState() => _VigilanciaScreenState();
}

class _VigilanciaScreenState extends State<VigilanciaScreen> {
  final String ipCelular = "http://192.168.1.4:8080/video";
  late final String urlVideo = "http://127.0.0.1:8000/camara/video?url=${Uri.encodeComponent(ipCelular)}";
  final String urlAlertas = "http://127.0.0.1:8000/camara/alertas";

  List<dynamic> alertas = [];
  Timer? _timerAlerta; // <--- Temporizador para actualización automática

  @override
  void initState() {
    super.initState();
    _obtenerAlertas();

    // Consulta automática al servidor cada 2 segundos
    _timerAlerta = Timer.periodic(const Duration(seconds: 2), (timer) {
      _obtenerAlertas();
    });

    // Registro seguro del flujo de video MJPEG para Flutter Web
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      'mjpeg-stream-view',
      (int viewId) => html.ImageElement()
        ..src = urlVideo
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover',
    );
  }

  @override
  void dispose() {
    _timerAlerta?.cancel(); // <--- Cancelamos el temporizador al salir de la pantalla
    super.dispose();
  }

  Future<void> _obtenerAlertas() async {
    try {
      // Añadimos un parámetro de tiempo para evitar que el navegador guarde caché en la web
      final respuesta = await http.get(Uri.parse("$urlAlertas?t=${DateTime.now().millisecondsSinceEpoch}"));
      if (respuesta.statusCode == 200) {
        if (!mounted) return;
        final List<dynamic> nuevasAlertas = jsonDecode(respuesta.body);
        
        // Forzamos la actualización solo si hay cambios en las alertas
        setState(() {
          alertas = nuevasAlertas;
        });
      }
    } catch (e) {
      print("Error al conectar con FastAPI: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna Izquierda: Streaming de Video con YOLOv8 procesado por FastAPI
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Transmisión en Vivo (YOLOv8)",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: const HtmlElementView(viewType: 'mjpeg-stream-view'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Columna Derecha: Historial de Alertas en Tiempo Real
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Historial de Alertas",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF27AE60)),
                      onPressed: _obtenerAlertas,
                      tooltip: "Actualizar alertas",
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2D3E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: alertas.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay alertas registradas aún",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: alertas.length,
                            itemBuilder: (context, index) {
                              final alerta = alertas[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.redAccent,
                                ),
                                title: Text(
                                  "Detectado: ${alerta['tipo']}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Hora: ${alerta['hora']}",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: Chip(
                                  label: Text("${alerta['confianza']}%"),
                                  backgroundColor: Colors.red.withOpacity(0.2),
                                  labelStyle: const TextStyle(color: Colors.redAccent),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
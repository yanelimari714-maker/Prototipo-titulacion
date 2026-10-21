import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TemperaturaScreen extends StatelessWidget {
  final bool alertaActiva;
  final VoidCallback onToggleAlerta;

  const TemperaturaScreen({
    super.key,
    required this.alertaActiva,
    required this.onToggleAlerta,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABECERA CON BOTONES DE SIMULACIÓN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Temperatura ambiental", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                  SizedBox(height: 5),
                  Text("Seguimiento por galpón, variación térmica y revisión de eventos.", style: TextStyle(color: Colors.black54)),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: onToggleAlerta,
                    icon: Icon(alertaActiva ? Icons.check_circle : Icons.local_fire_department, size: 18, color: Colors.white),
                    label: Text(alertaActiva ? "Normalizar sensores" : "Simular Alerta", style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: alertaActiva ? Colors.blue.shade700 : Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 18, color: Colors.white),
                    label: const Text("Exportar lecturas", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14402D),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 25),

          // FILA DE 4 TARJETAS DE INDICADORES (KPIs)
          Row(
            children: [
              _crearTarjetaKPI("Promedio de la granja", alertaActiva ? "29,1 °C" : "28,6 °C", "Último corte", Icons.thermostat, Colors.teal),
              const SizedBox(width: 15),
              _crearTarjetaKPI("Máxima del día", alertaActiva ? "32,5 °C" : "31,6 °C", alertaActiva ? "Galpón 2 · AHORA" : "Galpón 2 · 09:45", Icons.arrow_outward, alertaActiva ? Colors.red : Colors.orange),
              const SizedBox(width: 15),
              _crearTarjetaKPI("Mínima del día", "24,2 °C", "Galpón 1 · 05:15", Icons.south_east, Colors.blue),
              const SizedBox(width: 15),
              _crearTarjetaKPI("Eventos abiertos", alertaActiva ? "1 alta" : "0", alertaActiva ? "Galpón 2 · Pendiente" : "Todo normal", Icons.warning_amber_rounded, alertaActiva ? Colors.red : Colors.green),
            ],
          ),
          const SizedBox(height: 20),

          // SECCIÓN CENTRAL: GRÁFICO Y REGLAS DE ALERTA
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Evolución de la temperatura", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Cada 15 min", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const Text("Hoy · 00:00–10:30 · Zona sombreada: banda ilustrativa de 26–30 °C", style: TextStyle(color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _crearPuntoLeyenda(Colors.green, "Galpón 1"),
                          const SizedBox(width: 15),
                          _crearPuntoLeyenda(Colors.brown, "Galpón 2"),
                          const SizedBox(width: 15),
                          _crearPuntoLeyenda(Colors.blueGrey, "Galpón 3"),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 250,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  getTitlesWidget: (value, meta) {
                                    const style = TextStyle(color: Colors.black54, fontSize: 11);
                                    Widget text;
                                    switch (value.toInt()) {
                                      case 0: text = const Text('00:00', style: style); break;
                                      case 2: text = const Text('02:00', style: style); break;
                                      case 4: text = const Text('04:00', style: style); break;
                                      case 6: text = const Text('06:00', style: style); break;
                                      case 8: text = const Text('08:00', style: style); break;
                                      case 10: text = const Text('10:30', style: style); break;
                                      default: text = const Text('', style: style); break;
                                    }
                                    return SideTitleWidget(axisSide: meta.axisSide, child: text);
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: 0, maxX: 10, minY: 22, maxY: 34,
                            // Banda sombreada ilustrativa de 26 a 30 grados
                            extraLinesData: ExtraLinesData(
                              horizontalLines: [
                                HorizontalLine(y: 30, color: Colors.red.withOpacity(0.2), strokeWidth: 2, dashArray: [5, 5]),
                                HorizontalLine(y: 26, color: Colors.blue.withOpacity(0.2), strokeWidth: 2, dashArray: [5, 5]),
                              ],
                            ),
                            lineBarsData: [
                              LineChartBarData(spots: const [FlSpot(0, 26), FlSpot(2, 25.5), FlSpot(4, 25), FlSpot(6, 26.5), FlSpot(8, 27.5), FlSpot(10, 27)], isCurved: true, color: Colors.green, barWidth: 2, dotData: const FlDotData(show: false)),
                              LineChartBarData(spots: [const FlSpot(0, 26.5), const FlSpot(2, 25.8), const FlSpot(4, 25.2), const FlSpot(6, 27), const FlSpot(8, 29.5), FlSpot(10, alertaActiva ? 32.5 : 30.8)], isCurved: true, color: Colors.brown, barWidth: 2, dotData: const FlDotData(show: false)),
                              LineChartBarData(spots: const [FlSpot(0, 25.8), FlSpot(2, 25.2), FlSpot(4, 24.8), FlSpot(6, 26), FlSpot(8, 28), FlSpot(10, 27.2)], isCurved: true, color: Colors.blueGrey, barWidth: 2, dotData: const FlDotData(show: false)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Regla de alerta de muestra", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text("Perfil ilustrativo · Todos los galpones", style: TextStyle(color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 30),
                      _crearFilaRegla("Límite inferior", "26,0 °C"),
                      const Divider(height: 30),
                      _crearFilaRegla("Límite superior", "30,0 °C"),
                      const Divider(height: 30),
                      _crearFilaRegla("Persistencia de evento", "10 minutos"),
                      const SizedBox(height: 30),
                      const Text("Parámetros ficticios. Requieren validación del equipo técnico.", style: TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // TABLA DE LECTURAS
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Lecturas y equipos por galpón", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  color: Colors.grey.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: Text("GALPÓN / LOTE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                      Expanded(child: Text("SENSOR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                      Expanded(child: Text("ACTUAL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                      Expanded(flex: 2, child: Text("ESTADO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                    ],
                  ),
                ),
                _crearFilaTabla("G1 · EC-2601", "TMP-01", "27,4 °C", "Sin alerta de muestra", Colors.black54),
                const Divider(height: 1, color: Colors.black12),
                _crearFilaTabla("G2 · EC-2602", "TMP-02", alertaActiva ? "32,5 °C" : "29,8 °C", alertaActiva ? "Alta · Por revisar" : "Sin alerta", alertaActiva ? Colors.red.shade700 : Colors.black54),
                const Divider(height: 1, color: Colors.black12),
                _crearFilaTabla("G3 · EC-2603", "TMP-03", "27,6 °C", "Sin alerta de muestra", Colors.black54),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // BANNER INFERIOR DE ALERTA
          if (alertaActiva)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), border: Border.all(color: const Color(0xFFFCA5A5)), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("AHORA: Galpón 2 · Evento TMP-024 · Prioridad alta", style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold, fontSize: 13)),
                        Text("32,5 °C por encima de la regla de muestra. Sin revisión registrada.", style: TextStyle(color: Color(0xFF991B1B), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _crearTarjetaKPI(String titulo, String valor, String subtitulo, IconData icono, Color color) {
    return Expanded(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(titulo, style: const TextStyle(color: Colors.black54, fontSize: 13)), Icon(icono, color: color, size: 20)]), const SizedBox(height: 15), Text(valor, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color == Colors.red ? Colors.red : Colors.black87)), const SizedBox(height: 8), Text(subtitulo, style: const TextStyle(color: Colors.black45, fontSize: 12))])));
  }
  Widget _crearPuntoLeyenda(Color color, String texto) => Row(children: [Container(width: 12, height: 4, color: color), const SizedBox(width: 6), Text(texto, style: const TextStyle(fontSize: 12))]);
  Widget _crearFilaRegla(String label, String valor) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)), Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]);
  Widget _crearFilaTabla(String galpon, String sensor, String actual, String estado, Color colorEstado) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), child: Row(children: [Expanded(flex: 2, child: Text(galpon, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))), Expanded(child: Text(sensor, style: const TextStyle(color: Colors.black54, fontSize: 13))), Expanded(child: Text(actual, style: TextStyle(color: colorEstado == Colors.red.shade700 ? colorEstado : Colors.black87, fontSize: 13, fontWeight: colorEstado == Colors.red.shade700 ? FontWeight.bold : FontWeight.normal))), Expanded(flex: 2, child: Text(estado, style: TextStyle(color: colorEstado, fontSize: 13, fontWeight: FontWeight.w500)))]));
  }
}
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  final bool alertaTemperaturaActiva;
  final int diasAvance; // Recibe los días simulados

  const DashboardScreen({
    super.key, 
    required this.alertaTemperaturaActiva,
    required this.diasAvance,
  });

  // Fórmula matemática de consumo diario basada en la edad
  double _calcularConsumo(int edad) {
    if (edad <= 0) return 12.0;
    return 12.0 + (edad * 3.73);
  }

  @override
  Widget build(BuildContext context) {
    // Calcular el total de alimento del día para los 3 galpones
    double totalPlanKg = 0;
    final lotesBase = [
      {"aves": 800, "edad": 21},
      {"aves": 800, "edad": 18},
      {"aves": 800, "edad": 14},
    ];
    for (var lote in lotesBase) {
      int edadActual = (lote["edad"] as int) + diasAvance;
      totalPlanKg += ((lote["aves"] as int) * _calcularConsumo(edadActual)) / 1000;
    }
    double suministradoTotal = totalPlanKg * 0.75;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Resumen de la granja", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                  SizedBox(height: 5),
                  Text("Visión integrada de los 3 galpones · Ciclo de engorde", style: TextStyle(color: Colors.black54)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 18, color: Colors.white),
                label: const Text("Exportar resumen", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14402D), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              )
            ],
          ),
          const SizedBox(height: 25),

          Row(
            children: [
              _crearTarjetaKPI("Población registrada", "2.400 aves", "3 lotes activos", Icons.pets, Colors.teal),
              const SizedBox(width: 15),
              _crearTarjetaKPI("Temperatura promedio", alertaTemperaturaActiva ? "32,5 °C" : "28,6 °C", alertaTemperaturaActiva ? "¡Alerta en Galpón 2!" : "Valores normales", Icons.thermostat, alertaTemperaturaActiva ? Colors.red : Colors.orange),
              const SizedBox(width: 15),
              _crearTarjetaKPI("Agua consumida hoy", "1.248 L", "–8,4 % vs. ayer", Icons.water_drop_outlined, Colors.blue),
              const SizedBox(width: 15),
              // KPI DINÁMICO DE ALIMENTACIÓN CONECTADO A LA SIMULACIÓN
              _crearTarjetaKPI("Alimento suministrado", "${suministradoTotal.toStringAsFixed(0)} / ${totalPlanKg.toStringAsFixed(0)} kg", "75 % del plan diario", Icons.eco_outlined, Colors.green),
            ],
          ),
          const SizedBox(height: 20),

          if (alertaTemperaturaActiva) ...[
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
                        Text("Atención prioritaria · Temperatura en Galpón 2", style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold, fontSize: 13)),
                        Text("32,5 °C · Supera la regla de 30 °C. Pendiente de revisión.", style: TextStyle(color: Color(0xFF991B1B), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

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
                      const Text("Comportamiento térmico", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 250,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true, reservedSize: 22,
                                  getTitlesWidget: (value, meta) {
                                    const style = TextStyle(color: Colors.black54, fontSize: 11);
                                    if(value == 0) return SideTitleWidget(axisSide: meta.axisSide, child: const Text('00:00', style: style));
                                    if(value == 5) return SideTitleWidget(axisSide: meta.axisSide, child: const Text('05:00', style: style));
                                    if(value == 10) return SideTitleWidget(axisSide: meta.axisSide, child: const Text('10:30', style: style));
                                    return SideTitleWidget(axisSide: meta.axisSide, child: const Text(''));
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false), minX: 0, maxX: 10, minY: 22, maxY: 34,
                            lineBarsData: [
                              LineChartBarData(spots: const [FlSpot(0, 26), FlSpot(5, 25), FlSpot(10, 27)], isCurved: true, color: Colors.green, barWidth: 2, dotData: const FlDotData(show: false)),
                              LineChartBarData(spots: [const FlSpot(0, 26.5), const FlSpot(5, 25.2), FlSpot(10, alertaTemperaturaActiva ? 32.5 : 29.8)], isCurved: true, color: Colors.brown, barWidth: 2, dotData: const FlDotData(show: false)),
                              LineChartBarData(spots: const [FlSpot(0, 25.8), FlSpot(5, 24.8), FlSpot(10, 27.2)], isCurved: true, color: Colors.blueGrey, barWidth: 2, dotData: const FlDotData(show: false)),
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
                      Text("Alertas por atender", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      if (alertaTemperaturaActiva) ...[
                        _crearItemAlerta("Alta", Colors.red.shade100, Colors.red.shade800, "Temperatura elevada", "Galpón 2 · 32,5 °C"),
                        const Divider(height: 30),
                      ],
                      _crearItemAlerta("Media", Colors.orange.shade100, Colors.orange.shade800, "Menor consumo de agua", "Galpón 3 · -18 % vs. ayer"),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Estado de galpones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  color: Colors.grey.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: Text("GALPÓN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                      Expanded(child: Text("EDAD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                      Expanded(child: Text("TEMP.", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                      Expanded(flex: 2, child: Text("ESTADO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                    ],
                  ),
                ),
                // EDADES DINÁMICAS
                _crearFilaGalpon("G1 · EC-2601", "${21 + diasAvance} días", "27,4 °C", "Sin alertas", Colors.black54),
                const Divider(height: 1, color: Colors.black12),
                _crearFilaGalpon("G2 · EC-2602", "${18 + diasAvance} días", alertaTemperaturaActiva ? "32,5 °C" : "29,8 °C", alertaTemperaturaActiva ? "Alta · Temperatura" : "Sin alertas", alertaTemperaturaActiva ? Colors.red.shade700 : Colors.black54),
                const Divider(height: 1, color: Colors.black12),
                _crearFilaGalpon("G3 · EC-2603", "${14 + diasAvance} días", "27,6 °C", "Revisar agua", Colors.orange.shade700),
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
  Widget _crearItemAlerta(String nivel, Color bg, Color txt, String tit, String det) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)), child: Text(nivel, style: TextStyle(color: txt, fontSize: 11, fontWeight: FontWeight.bold))), const SizedBox(width: 10), Text(tit, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]), const SizedBox(height: 6), Text(det, style: const TextStyle(color: Colors.black54, fontSize: 13))]);
  Widget _crearFilaGalpon(String galpon, String edad, String temp, String estado, Color col) => Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), child: Row(children: [Expanded(flex: 2, child: Text(galpon, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))), Expanded(child: Text(edad, style: const TextStyle(color: Colors.black54, fontSize: 13))), Expanded(child: Text(temp, style: const TextStyle(color: Colors.black54, fontSize: 13))), Expanded(flex: 2, child: Text(estado, style: TextStyle(color: col, fontSize: 13, fontWeight: FontWeight.w500)))]));
}
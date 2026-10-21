import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AlimentacionScreen extends StatelessWidget {
  final int diasAvance;
  final VoidCallback onAvanzarDia;

  const AlimentacionScreen({
    super.key, 
    required this.diasAvance, 
    required this.onAvanzarDia
  });

  // Inventario de lotes base
  final List<Map<String, dynamic>> _lotes = const [
    {"galpon": "G1 · EC-2601", "aves": 800, "edadBase": 21},
    {"galpon": "G2 · EC-2602", "aves": 800, "edadBase": 18},
    {"galpon": "G3 · EC-2603", "aves": 800, "edadBase": 14},
  ];

  String _determinarTipoAlimento(int edad) {
    if (edad <= 10) return "Pre-iniciador";
    if (edad <= 21) return "Iniciador";
    if (edad <= 35) return "Crecimiento";
    return "Engorde";
  }

  double _calcularConsumoGramos(int edad) {
    if (edad <= 0) return 12.0;
    return 12.0 + (edad * 3.73);
  }

  @override
  Widget build(BuildContext context) {
    double totalPlanKg = 0;
    List<Map<String, dynamic>> datosCalculados = [];
    
    for (var lote in _lotes) {
      int edadActual = lote["edadBase"] + diasAvance;
      double consumoGramos = _calcularConsumoGramos(edadActual);
      double planLoteKg = (lote["aves"] * consumoGramos) / 1000;
      
      totalPlanKg += planLoteKg;
      
      datosCalculados.add({
        "galpon": lote["galpon"],
        "edad": "$edadActual días / ${lote["aves"]}",
        "alimento": _determinarTipoAlimento(edadActual),
        "plan": planLoteKg,
        "real": planLoteKg * 0.75,
        "pendiente": planLoteKg * 0.25,
      });
    }

    double suministradoTotal = totalPlanKg * 0.75;
    double pendienteTotal = totalPlanKg * 0.25;

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
                  Text("Planificación de alimentación", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                  SizedBox(height: 5),
                  Text("Asignación por lote, registro de raciones y disponibilidad de alimento.", style: TextStyle(color: Colors.black54)),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: onAvanzarDia, // Llama a la función global
                    icon: const Icon(Icons.update, size: 18, color: Colors.white),
                    label: Text("Simular: Día +$diasAvance", style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_note, size: 18, color: Colors.white),
                    label: const Text("Editar plan", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14402D), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 25),

          Row(
            children: [
              _crearTarjetaKPI("Plan diario calculado", "${totalPlanKg.toStringAsFixed(1)} kg", "Suma de los 3 lotes", Icons.assignment_outlined, Colors.teal),
              const SizedBox(width: 15),
              _crearTarjetaKPI("Suministrado hoy", "${suministradoTotal.toStringAsFixed(1)} kg", "75 % del plan", Icons.eco_outlined, Colors.green),
              const SizedBox(width: 15),
              _crearTarjetaKPI("Pendiente del día", "${pendienteTotal.toStringAsFixed(1)} kg", "Segunda ración a las 14:00", Icons.schedule, Colors.orange),
              const SizedBox(width: 15),
              _crearTarjetaKPI("Existencia registrada", "960 kg", "Inventario en bodega", Icons.inventory_2_outlined, Colors.blueGrey),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Plan del día por lote", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  color: Colors.grey.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: Text("GALPÓN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                      Expanded(flex: 2, child: Text("EDAD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                      Expanded(flex: 2, child: Text("ALIMENTO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                      Expanded(child: Text("PLAN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                      Expanded(child: Text("SUMINISTRADO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                    ],
                  ),
                ),
                ...datosCalculados.map((lote) => Column(
                  children: [
                    _crearFilaTabla(lote["galpon"], lote["edad"], lote["alimento"], "${lote["plan"].toStringAsFixed(1)} kg", "${lote["real"].toStringAsFixed(1)} kg"),
                    const Divider(height: 1, color: Colors.black12),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                      const Text("Planificado vs. suministrado", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: totalPlanKg > 300 ? totalPlanKg + 50 : 300,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (double value, _) {
                                const style = TextStyle(color: Colors.black54, fontSize: 11);
                                List<String> dias = ['15 oct', '16 oct', '17 oct', '18 oct', '19 oct', '20 oct', 'Hoy'];
                                return SideTitleWidget(axisSide: AxisSide.bottom, child: Text(dias[value.toInt()], style: style));
                              })),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
                            barGroups: [
                              _crearGrupoBarras(0, 262, 262), _crearGrupoBarras(1, 268, 268),
                              _crearGrupoBarras(2, 272, 272), _crearGrupoBarras(3, 276, 276),
                              _crearGrupoBarras(4, 280, 280), _crearGrupoBarras(5, 284, 284),
                              _crearGrupoBarras(6, totalPlanKg, suministradoTotal), // Barra dinámica
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(flex: 3, child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: const Text("Agenda de suministro", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _crearTarjetaKPI(String titulo, String valor, String subtitulo, IconData icono, Color colorIcono) {
    return Expanded(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(titulo, style: const TextStyle(color: Colors.black54, fontSize: 13)), Icon(icono, color: colorIcono, size: 20)]), const SizedBox(height: 15), Text(valor, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(height: 8), Text(subtitulo, style: const TextStyle(color: Colors.black45, fontSize: 12))])));
  }
  Widget _crearFilaTabla(String col1, String col2, String col3, String col4, String col5) => Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), child: Row(children: [Expanded(flex: 2, child: Text(col1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))), Expanded(flex: 2, child: Text(col2, style: const TextStyle(color: Colors.black54, fontSize: 13))), Expanded(flex: 2, child: Text(col3, style: const TextStyle(color: Colors.black54, fontSize: 13))), Expanded(child: Text(col4, style: const TextStyle(color: Colors.black87, fontSize: 13))), Expanded(child: Text(col5, style: const TextStyle(color: Colors.black54, fontSize: 13)))]));
  BarChartGroupData _crearGrupoBarras(int x, double plan, double real) => BarChartGroupData(x: x, barRods: [BarChartRodData(toY: plan, color: Colors.grey.shade300, width: 20, borderRadius: BorderRadius.circular(2)), BarChartRodData(toY: real, color: const Color(0xFF2E7D32), width: 20, borderRadius: BorderRadius.circular(2))]);
}
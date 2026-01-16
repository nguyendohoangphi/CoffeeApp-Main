import 'package:coffeeapp/models/chartdata.dart';

class NamedChartData {
  final String label;
  final List<ChartData> data;

  NamedChartData(this.label, this.data);
}

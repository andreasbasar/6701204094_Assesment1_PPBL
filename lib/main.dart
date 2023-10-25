import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StockPriceApp(),
    );
  }
}

class StockPriceApp extends StatefulWidget {
  @override
  _StockPriceAppState createState() => _StockPriceAppState();
}

class _StockPriceAppState extends State<StockPriceApp> {
  String stockSymbol = "ASMMF";
  List<dynamic> stockData = [];

  Future<void> fetchStockData() async {
    final response = await http.get(Uri.parse(
        "https://api.polygon.io/v2/aggs/ticker/ASMMF/range/1/day/2023-09-25/2023-10-25?adjusted=true&sort=asc&limit=120&apiKey=4GBnCzwbauopqbZvVEnInuPnSHfk9C42"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      setState(() {
        stockData = jsonData['results'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStockData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Price App'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('Kode Saham: $stockSymbol'),
            ElevatedButton(
              onPressed: fetchStockData,
              child: Text('Refresh Data'),
            ),
            StockChart(stockData: stockData),
          ],
        ),
      ),
    );
  }
}

class StockChart extends StatelessWidget {
  final List<dynamic> stockData;

  StockChart({required this.stockData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 200,
      child: stockData.isNotEmpty
          ? StockLineChart(stockData: stockData)
          : CircularProgressIndicator(),
    );
  }
}

class StockLineChart extends StatelessWidget {
  final List<dynamic> stockData;

  StockLineChart({required this.stockData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: stockData.length.toDouble() - 1,
          minY: stockData.first['o'].toDouble(),
          maxY: stockData.first['o'].toDouble(),
          lineBarsData: [
            LineChartBarData(
              spots: stockData
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final data = entry.value;
                return FlSpot(index.toDouble(), data['o'].toDouble());
              })
                  .toList(),
              isCurved: true,
              colors: [Colors.yellow],
              dotData: FlDotData(
                show: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
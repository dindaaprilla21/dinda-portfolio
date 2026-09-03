import 'package:flutter/material.dart';
import '../data/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  final String nama;
  final String transportasi;
  final String asal;
  final String tujuan;
  final String tanggal;

  const HistoryScreen({
    super.key,
    required this.nama,
    required this.transportasi,
    required this.asal,
    required this.tujuan,
    required this.tanggal,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _saveOrderToDatabase();
  }

  // Simpan order ke database saat layar dibuka
  Future<void> _saveOrderToDatabase() async {
    await dbHelper.addOrder({
      'nama': widget.nama,
      'transportasi': widget.transportasi,
      'asal': widget.asal,
      'tujuan': widget.tujuan,
      'tanggal': widget.tanggal,
      'harga': 500000, // Harga default, bisa diubah sesuai kebutuhan
    });

    _loadOrders(); // Setelah simpan, langsung refresh data di ListView
  }

  // Ambil semua data order dari SQLite
  Future<void> _loadOrders() async {
    final data = await dbHelper.getAllOrders();
    setState(() {
      orders = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Perjalanan')),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.person, size: 40),
              title: Text(order['nama']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${order['asal']} - ${order['tujuan']}'),
                  Text('${order['transportasi']} - ${order['tanggal']}'),
                  Text('Rp ${order['harga']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

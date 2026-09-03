import 'package:flutter/material.dart';
import 'history_screen.dart';

class OrderScreen extends StatelessWidget {
  final String transportasi;

  OrderScreen({super.key, required this.transportasi});

  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final asalController = TextEditingController();
  final tujuanController = TextEditingController();
  final tanggalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pesan Tiket - $transportasi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: namaController, decoration: InputDecoration(labelText: 'Nama Penumpang')),
              TextFormField(controller: asalController, decoration: InputDecoration(labelText: 'Asal')),
              TextFormField(controller: tujuanController, decoration: InputDecoration(labelText: 'Tujuan')),
              TextFormField(controller: tanggalController, decoration: InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)')),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryScreen(
                          nama: namaController.text,
                          transportasi: transportasi,
                          asal: asalController.text,
                          tujuan: tujuanController.text,
                          tanggal: tanggalController.text,
                        ),
                      ),
                    );
                  }
                },
                child: Text('Pesan Sekarang'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

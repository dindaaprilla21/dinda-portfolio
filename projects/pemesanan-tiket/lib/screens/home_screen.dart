import 'package:flutter/material.dart';
import 'order_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 166, 214, 241), // Biar soft background-nya
      appBar: AppBar(
        title: Text('Selamat Datang'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Kamu mau pergi kemana?',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),

              SizedBox(height: 16),

              // Gambar Keluarga Mudik
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(31, 255, 255, 255),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/gambar1.jpg', // Ganti sesuai nama file gambar kamu
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Tulisan Pilih Transportasi
              Text(
                'Pilih Transportasi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              SizedBox(height: 8),

              // Pilihan Transportasi
              transportOption('Pesawat', Icons.flight, context, 'Transportasi Udara'),
              transportOption('Kapal Laut', Icons.directions_boat, context, 'Transportasi Laut'),
              transportOption('Kereta', Icons.train, context, 'Transportasi Darat'),
            ],
          ),
        ),
      ),
    );
  }

  Widget transportOption(String title, IconData icon, BuildContext context, String subtitle) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blue),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => OrderScreen(transportasi: title)));
        },
      ),
    );
  }
}

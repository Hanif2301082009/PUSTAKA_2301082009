import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PeminjamanPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  
  const PeminjamanPage({
    Key? key,
    this.userData,
  }) : super(key: key);

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  List<dynamic> _peminjamanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
  }

  Future<void> _loadPeminjaman() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/pustaka_2301082009/api/get_all_peminjaman.php'),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          setState(() {
            _peminjamanList = result['data'];
            _isLoading = false;
          });
        } else {
          throw Exception(result['message']);
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Peminjaman'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      drawer: MainDrawer(
        currentRoute: '/peminjaman',
        isAdmin: true,
        userData: widget.userData,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _peminjamanList.length,
              itemBuilder: (context, index) {
                final peminjaman = _peminjamanList[index];
                final tanggalPinjam = peminjaman['tanggal_pinjam'];
                final tanggalKembali = peminjaman['tanggal_kembali'];
                
                // Hitung denda jika ada tanggal kembali
                double denda = 0;
                String statusPeminjaman = 'Sedang Dipinjam';
                if (tanggalKembali != null) {
                  final DateTime tglPinjam = DateTime.parse(tanggalPinjam);
                  final DateTime tglKembali = DateTime.parse(tanggalKembali);
                  final int selisihHari = tglKembali.difference(tglPinjam).inDays;
                  if (selisihHari > 7) {
                    denda = (selisihHari - 7) * 1000.0;
                    statusPeminjaman = 'Terlambat';
                  } else {
                    statusPeminjaman = 'Dikembalikan';
                  }
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    peminjaman['nama_anggota'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    peminjaman['judul_buku'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusPeminjaman == 'Terlambat' 
                                  ? Colors.red 
                                  : statusPeminjaman == 'Dikembalikan'
                                    ? Colors.green
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusPeminjaman,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, 
                              size: 16, 
                              color: Colors.grey
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tanggal Pinjam: $tanggalPinjam',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        if (tanggalKembali != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.assignment_return, 
                                size: 16, 
                                color: Colors.grey
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tanggal Kembali: $tanggalKembali',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status: $statusPeminjaman',
                              style: TextStyle(
                                color: statusPeminjaman == 'Terlambat' 
                                  ? Colors.red 
                                  : statusPeminjaman == 'Dikembalikan'
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (denda > 0)
                              Text(
                                'Denda: Rp ${denda.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
} 
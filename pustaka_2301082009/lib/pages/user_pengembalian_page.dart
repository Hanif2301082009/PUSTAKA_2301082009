import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserPengembalianPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  
  const UserPengembalianPage({
    Key? key,
    this.userData,
  }) : super(key: key);

  @override
  State<UserPengembalianPage> createState() => _UserPengembalianPageState();
}

class _UserPengembalianPageState extends State<UserPengembalianPage> {
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
        Uri.parse('http://localhost/pustaka_2301082009/api/get_peminjaman_by_user.php?user_id=${widget.userData?['id']}'),
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

  Future<void> _returnBook(Map<String, dynamic> peminjaman) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.parse(peminjaman['tanggal_pinjam']),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    // Hitung denda
    double denda = 0;
    final DateTime tanggalPinjam = DateTime.parse(peminjaman['tanggal_pinjam']);
    final int selisihHari = pickedDate.difference(tanggalPinjam).inDays;
    if (selisihHari > 7) {
      denda = (selisihHari - 7) * 1000.0;
    }

    if (!mounted) return;

    // Tampilkan dialog konfirmasi dengan preview denda
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pengembalian'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Judul Buku: ${peminjaman['judul_buku']}'),
              const SizedBox(height: 8),
              Text('Tanggal Pinjam: ${peminjaman['tanggal_pinjam']}'),
              Text('Tanggal Kembali: ${pickedDate.toString().split(' ')[0]}'),
              const SizedBox(height: 8),
              Text(
                'Lama Peminjaman: $selisihHari hari',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              Text(
                'Denda: Rp ${denda.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: denda > 0 ? Colors.red : Colors.green,
                ),
              ),
              if (denda > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Keterlambatan: ${selisihHari - 7} hari',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final response = await http.post(
        Uri.parse('http://localhost/pustaka_2301082009/api/return_book.php'),
        body: {
          'id': peminjaman['id'].toString(),
          'tanggal_kembali': pickedDate.toString().split(' ')[0],
          'denda': denda.toString(),
        },
      );

      final result = jsonDecode(response.body);
      
      if (!mounted) return;

      if (result['success']) {
        _loadPeminjaman(); // Refresh data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              denda > 0 
                ? 'Buku berhasil dikembalikan. Denda: Rp ${denda.toStringAsFixed(0)}'
                : 'Buku berhasil dikembalikan'
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengembalian Saya'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      drawer: MainDrawer(
        currentRoute: '/user/pengembalian',
        isAdmin: false,
        userData: widget.userData,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _peminjamanList.length,
              itemBuilder: (context, index) {
                final peminjaman = _peminjamanList[index];
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
                          children: [
                            const Icon(Icons.book, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                peminjaman['judul_buku'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Tanggal Pinjam: ${peminjaman['tanggal_pinjam']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _returnBook(peminjaman),
                            child: const Text('Kembalikan Buku'),
                          ),
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
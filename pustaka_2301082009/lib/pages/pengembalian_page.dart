import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PengembalianPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  
  const PengembalianPage({
    Key? key,
    this.userData,
  }) : super(key: key);

  @override
  _PengembalianPageState createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  List<Map<String, dynamic>> peminjamanList = [];

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
  }

  Future<void> _loadPeminjaman() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/pustaka_2301082009/api/get_peminjaman.php'),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          setState(() {
            peminjamanList = List<Map<String, dynamic>>.from(result['data']);
          });
        } else {
          throw Exception(result['message']);
        }
      } else {
        throw Exception('Failed to load peminjaman');
      }
    } catch (e) {
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
        title: const Text('Pengembalian Buku'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      drawer: MainDrawer(
        currentRoute: '/pengembalian',
        isAdmin: widget.userData?['role'] == 'admin',
        userData: widget.userData,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: peminjamanList.length,
        itemBuilder: (context, index) {
          final peminjaman = peminjamanList[index];
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
                          peminjaman['judul'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.assignment_return),
                        onPressed: () async {
                          await _returnBook(peminjaman);
                        },
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _returnBook(Map<String, dynamic> peminjaman) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/pustaka_2301082009/api/return_book.php'),
        body: {
          'id': peminjaman['id'].toString(),
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          _loadPeminjaman(); // Refresh data
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Buku berhasil dikembalikan'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(result['message']);
        }
      } else {
        throw Exception('Failed to return book');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 
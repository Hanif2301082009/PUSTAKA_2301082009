import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserPeminjamanPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  
  const UserPeminjamanPage({
    Key? key,
    this.userData,
  }) : super(key: key);

  @override
  State<UserPeminjamanPage> createState() => _UserPeminjamanPageState();
}

class _UserPeminjamanPageState extends State<UserPeminjamanPage> {
  List<dynamic> _peminjamanList = [];
  List<dynamic> _availableBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadPeminjaman(),
      _loadAvailableBooks(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadPeminjaman() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/api/get_peminjaman_by_user.php?user_id=${widget.userData?['id']}'),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          setState(() => _peminjamanList = result['data']);
        } else {
          throw Exception(result['message']);
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _loadAvailableBooks() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/api/get_available_books.php'),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          setState(() {
            _availableBooks = result['data'];
          });
        } else {
          throw Exception(result['message']);
        }
      } else {
        throw Exception('Failed to load available books');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _addPeminjaman(Map<String, dynamic> book) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/api/add_peminjaman.php'),
        body: {
          'id_buku': book['id'].toString(),
          'id_anggota': widget.userData?['id'].toString(),
          'tanggal_pinjam': DateTime.now().toString().split(' ')[0],
        },
      );

      if (!mounted) return;

      final result = jsonDecode(response.body);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil dipinjam')),
        );
        _loadData();
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peminjaman Saya'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      drawer: MainDrawer(
        currentRoute: '/user/peminjaman',
        isAdmin: false,
        userData: widget.userData,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Pilih Buku'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableBooks.length,
                  itemBuilder: (context, index) {
                    final book = _availableBooks[index];
                    return ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(book['judul'] ?? ''),
                      subtitle: Text(book['pengarang'] ?? ''),
                      onTap: () {
                        Navigator.pop(context);
                        _addPeminjaman(book);
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ],
            ),
          );
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add),
      ),
    );
  }
} 
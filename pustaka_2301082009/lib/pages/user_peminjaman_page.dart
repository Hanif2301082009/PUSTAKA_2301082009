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
    print('UserData received: ${widget.userData}');
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
        Uri.parse('http://localhost/pustaka_2301082009/api/get_peminjaman_by_user.php?user_id=${widget.userData?['id']}'),
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
        Uri.parse('http://localhost/pustaka_2301082009/api/get_book.php'),
      );

      if (!mounted) return;

      final result = jsonDecode(response.body);
      if (result['success']) {
        setState(() {
          _availableBooks = result['data'].where((book) {
            return !_peminjamanList.any((peminjaman) => 
              peminjaman['id_buku'].toString() == book['id'].toString() && 
              peminjaman['tanggal_kembali'] == null
            );
          }).toList();
        });
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _addPeminjaman(Map<String, dynamic> book) async {
    try {
      print('Attempting to add peminjaman with user: ${widget.userData}');
      
      if (widget.userData == null || widget.userData!['id'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan login ulang'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      final response = await http.post(
        Uri.parse('http://localhost/pustaka_2301082009/api/add_peminjaman.php'),
        body: {
          'id_anggota': widget.userData!['id'].toString(),
          'id_buku': book['id'].toString(),
          'tanggal_pinjam': DateTime.now().toString().split(' ')[0],
        },
      );

      final result = jsonDecode(response.body);
      print('API Response: $result');

      if (!mounted) return;

      if (result['success']) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buku berhasil dipinjam'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      if (!mounted) return;
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
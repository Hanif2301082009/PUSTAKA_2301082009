import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_anggota_page.dart';

class UsersPage extends StatefulWidget {
  final bool isAdmin;
  
  const UsersPage({
    Key? key,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<dynamic> _anggotaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnggota();
  }

  Future<void> _loadAnggota() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/pustaka_2301082009/api/get_anggota.php'),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          setState(() {
            _anggotaList = result['data'];
            _isLoading = false;
          });
        } else {
          throw Exception(result['message']);
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
        title: const Text('Data Anggota'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      drawer: MainDrawer(
        currentRoute: '/anggota',
        isAdmin: widget.isAdmin,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _anggotaList.isEmpty
              ? const Center(child: Text('Tidak ada data'))
              : ListView.builder(
                  itemCount: _anggotaList.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final anggota = _anggotaList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Header hijau dengan avatar
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    (anggota['nama'] ?? '')[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  anggota['nama'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Informasi anggota
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // NIM
                                Row(
                                  children: [
                                    const Icon(Icons.tag, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'NIM',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          anggota['nim'] ?? '',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Alamat
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Alamat',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          anggota['alamat'] ?? '',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Jenis Kelamin
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Jenis Kelamin',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          anggota['jenis_kelamin'] ?? '',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Tombol aksi
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey, width: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddAnggotaPage(
                                            anggota: anggota,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadAnggota();
                                      }
                                    },
                                    icon: const Icon(Icons.edit, color: Color(0xFF2E7D32)),
                                    label: const Text(
                                      'Edit',
                                      style: TextStyle(color: Color(0xFF2E7D32)),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 48,
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      // TODO: Implement delete
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    label: const Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAnggotaPage(),
            ),
          );
          if (result == true) {
            _loadAnggota();
          }
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add),
      ),
    );
  }
}
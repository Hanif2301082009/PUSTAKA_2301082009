import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPeminjamanPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const AddPeminjamanPage({super.key, this.userData});

  @override
  State<AddPeminjamanPage> createState() => _AddPeminjamanPageState();
}

class _AddPeminjamanPageState extends State<AddPeminjamanPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<Map<String, dynamic>> _bukuList = [];
  String? _selectedBukuId;

  @override
  void initState() {
    super.initState();
    _loadBuku();
  }

  Future<void> _loadBuku() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/api/get_buku.php'),
      );

      if (!mounted) return;

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        setState(() {
          _bukuList = List<Map<String, dynamic>>.from(result['data']);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitPeminjaman() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost/api/add_peminjaman.php'),
        body: {
          'id_anggota': widget.userData?['id']?.toString(),
          'id_buku': _selectedBukuId,
        },
      );

      if (!mounted) return;

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        Navigator.pop(context, true);
      } else {
        throw result['message'] ?? 'Gagal menambah peminjaman';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Peminjaman'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedBukuId,
                decoration: const InputDecoration(
                  labelText: 'Pilih Buku',
                  border: OutlineInputBorder(),
                ),
                items: _bukuList.map((buku) {
                  return DropdownMenuItem(
                    value: buku['id'].toString(),
                    child: Text(buku['judul'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedBukuId = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Silakan pilih buku';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPeminjaman,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
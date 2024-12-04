import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_book_page.dart';

class BookListPage extends StatefulWidget {
  final bool isAdmin;
  
  const BookListPage({
    Key? key,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  List<dynamic> _bookList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      print('Fetching books...');
      final response = await http.get(
        Uri.parse('http://localhost/api/get_book.php'),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          setState(() {
            _bookList = result['data'];
            _isLoading = false;
          });
        } else {
          throw Exception(result['message']);
        }
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading books: $e');
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Buku'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      drawer: MainDrawer(
        currentRoute: '/buku',
        isAdmin: widget.isAdmin,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookList.isEmpty
              ? const Center(child: Text('Tidak ada data buku'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookList.length,
                  itemBuilder: (context, index) {
                    final book = _bookList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Header with book image and title
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
                                // Book Image
                                Container(
                                  width: 80,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: book['image'] != null && book['image'].toString().isNotEmpty
                                        ? Image.asset(
                                            book['image'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              print('Error loading image: $error');
                                              return Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.book,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.book,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Book Title
                                Expanded(
                                  child: Text(
                                    book['judul'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Book details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildDetailRow(
                                  Icons.person,
                                  'Pengarang',
                                  book['pengarang'] ?? '',
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  Icons.business,
                                  'Penerbit',
                                  book['penerbit'] ?? '',
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  Icons.calendar_today,
                                  'Tahun Terbit',
                                  book['tahun_terbit'] ?? '',
                                ),
                              ],
                            ),
                          ),
                          // Action buttons
                          if (widget.isAdmin)
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
                                            builder: (context) => AddBookPage(
                                              book: book,
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          _loadBooks();
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
                                        // TODO: Implement delete functionality
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
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddBookPage(),
                  ),
                );
                if (result == true) {
                  _loadBooks();
                }
              },
              backgroundColor: const Color(0xFF2E7D32),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
} 
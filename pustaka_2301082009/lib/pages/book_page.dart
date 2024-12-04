import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';

class Book {
  final String title;
  final String author;
  final String imagePath;
  final String description;

  Book({
    required this.title,
    required this.author,
    required this.imagePath,
    required this.description,
  });
}

class BookPage extends StatefulWidget {
  final bool isAdmin;
  final Map<String, dynamic>? userData;
  
  const BookPage({
    Key? key, 
    required this.isAdmin,
    this.userData,
  }) : super(key: key);

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final List<Book> books = [
    Book(
      title: 'Mindset',
      author: 'Carol S. Dweck',
      imagePath: 'assets/images/mindset.jpg',
      description: 'Buku ini membahas tentang kekuatan pola pikir dan bagaimana cara berpikir kita dapat mempengaruhi kesuksesan, pertumbuhan, dan resiliensi dalam hidup. Carol Dweck menjelaskan perbedaan antara mindset tetap (fixed mindset) dan mindset berkembang (growth mindset).',
    ),
    Book(
      title: 'Bumi Manusia',
      author: 'Pramoedya Ananta Toer',
      imagePath: 'assets/images/bumi.jpg',
      description: 'Novel pertama dari Tetralogi Buru yang menceritakan tentang perjuangan Minke, seorang pribumi yang mendapatkan pendidikan Belanda, dalam menghadapi diskriminasi di era kolonial.',
    ),
    Book(
      title: 'Dilan 1990',
      author: 'Pidi Baiq',
      imagePath: 'assets/images/dilan.jpg',
      description: 'Kisah cinta antara Milea, siswi pindahan dari Jakarta, dengan Dilan, siswa yang terkenal nakal namun jenius. Berlatar di Bandung tahun 1990.',
    ),
    Book(
      title: 'Pulang',
      author: 'Tere Liye',
      imagePath: 'assets/images/pulang.jpg',
      description: 'Novel yang mengisahkan tentang Bujang, seorang anak dari keluarga miskin yang terpaksa merantau dan kemudian menjadi bagian dari organisasi shadow economy.',
    ),
    Book(
      title: '5 cm',
      author: 'Donny Dhirgantoro',
      imagePath: 'assets/images/lima_cm.jpg',
      description: 'Kisah persahabatan lima anak muda yang memutuskan untuk tidak bertemu selama tiga bulan dan berjanji untuk mendaki Gunung Semeru bersama-sama.',
    ),
    Book(
      title: 'Negeri 5 Menara',
      author: 'Ahmad Fuadi',
      imagePath: 'assets/images/negeri5menara.jpg',
      description: 'Novel inspiratif yang menceritakan kisah Alif dan lima temannya selama menuntut ilmu di Pondok Madani. Mereka memiliki mimpi besar yang disimbolkan dengan lima menara.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buku'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      drawer: MainDrawer(
        isAdmin: widget.isAdmin,
        userData: widget.userData,
        currentRoute: '/buku',
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: Image.asset(
                      books[index].imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.book,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        books[index].title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        books[index].author,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(books[index].title),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        books[index].imagePath,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 200,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.book,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Penulis: ${books[index].author}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        books[index].description,
                                        textAlign: TextAlign.justify,
                                        style: const TextStyle(
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Tutup'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Meminjam buku ${books[index].title}',
                                          ),
                                          backgroundColor: const Color(0xFF2E7D32),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                    ),
                                    child: const Text('Pinjam'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Detail'),
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
    );
  }
} 
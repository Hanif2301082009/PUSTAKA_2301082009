import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  final String currentRoute;
  final bool isAdmin;
  final Map<String, dynamic>? userData;

  const MainDrawer({
    Key? key,
    required this.currentRoute,
    required this.isAdmin,
    this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 35,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAdmin ? Icons.admin_panel_settings : Icons.person_outline,
                        size: 14,
                        color: const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAdmin ? 'Admin' : 'User',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'H BOOK STORE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.home_rounded,
                  title: 'Home',
                  isSelected: currentRoute == '/home',
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/home',
                      arguments: {'isAdmin': isAdmin, 'userData': userData},
                    );
                  },
                ),
                if (isAdmin) ...[
                  _buildMenuItem(
                    icon: Icons.people_rounded,
                    title: 'Data Anggota',
                    isSelected: currentRoute == '/anggota',
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/anggota',
                        arguments: {'isAdmin': isAdmin},
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.book_rounded,
                    title: 'Data Buku',
                    isSelected: currentRoute == '/buku',
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/buku',
                        arguments: {'isAdmin': isAdmin},
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.library_books_rounded,
                    title: 'Data Peminjaman',
                    isSelected: currentRoute == '/peminjaman',
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/peminjaman',
                        arguments: {'isAdmin': isAdmin, 'userData': userData},
                      );
                    },
                  ),
                ] else ...[
                  _buildMenuItem(
                    icon: Icons.library_books_rounded,
                    title: 'Peminjaman Saya',
                    isSelected: currentRoute == '/user/peminjaman',
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/user/peminjaman',
                        arguments: {'userData': userData},
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.assignment_return_rounded,
                    title: 'Pengembalian Saya',
                    isSelected: currentRoute == '/user/pengembalian',
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/user/pengembalian',
                        arguments: {'userData': userData},
                      );
                    },
                  ),
                ],
                const Divider(height: 1),
                _buildMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  isSelected: false,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  textColor: Colors.red,
                  iconColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? (isSelected ? const Color(0xFF2E7D32) : Colors.grey[700]),
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? (isSelected ? const Color(0xFF2E7D32) : Colors.grey[800]),
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF2E7D32).withOpacity(0.1),
      dense: true,
      onTap: onTap,
    );
  }
} 
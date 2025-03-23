import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:schedule_project_with_gemini/screen/detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box historyBox = Hive.box('searchHistory');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Pencarian',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: ValueListenableBuilder(
        valueListenable: historyBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat.',
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
              ),
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final dynamic history = box.getAt(index);

              // Pastikan data berupa Map
              if (history is Map<String, dynamic>) {
                return Card(
                  color: Colors.deepPurple,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genre: ${history['genre']}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Bahasa: ${history['language']}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailScreen(recommendation: history['recommendation']),
                      ),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () => box.deleteAt(index),
                      ),
                    ),
                  ),
                );
              } else {
                // Jika data tidak valid, tampilkan item kosong
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:schedule_project_with_gemini/network/gemini_service.dart';
import 'package:schedule_project_with_gemini/screen/histhory_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedGenre = 'Fantasi';
  String selectedLanguage = 'Indonesia';
  String recommendationResult = "";
  bool isLoading = false;
  final Box historyBox = Hive.box('searchHistory');

  final List<String> genres = ['Fantasi', 'Aksi', 'Misteri', 'Romantis', 'Horor', 'Petualangan','Fiksi Ilmiah','Sejarah','Komedi','Distopia','Spiritual/Religius','Thriller'];
  final List<String> languages = ['Indonesia', 'Inggris', 'Jepang', 'Korea', 'Prancis','Amerika Serikat','Rusia ','Korea Selatan ','Turki'];

  void getRecommendations() async {
    setState(() {
      isLoading = true;
      recommendationResult = "";
    });

    try {
      final result = await GeminiService.generateRecommendation(selectedGenre, selectedLanguage);
      setState(() {
        recommendationResult = result;
      });
      historyBox.add({'genre': selectedGenre, 'language': selectedLanguage, 'recommendation': result});
    } catch (e) {
      setState(() {
        recommendationResult = "Gagal mendapatkan rekomendasi. Silakan coba lagi.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rekomendasi Novel',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        shadowColor: Colors.deepPurple.withOpacity(0.5),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.history,
              color: Colors.white,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: Container(
         height: double.infinity, // Mengisi tinggi layar
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSelectionCard(),
              const SizedBox(height: 20),
              if (isLoading) _buildShimmerLoading(),
              if (!isLoading && recommendationResult.isNotEmpty) _buildRecommendationList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.deepPurple.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown('Pilih Genre:', selectedGenre, genres, (newValue) {
              setState(() {
                selectedGenre = newValue!;
              });
            }),
            const SizedBox(height: 20),
            _buildDropdown('Pilih Bahasa:', selectedLanguage, languages, (newValue) {
              setState(() {
                selectedLanguage = newValue!;
              });
            }),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  elevation: 5,
                  shadowColor: Colors.deepPurple.withOpacity(0.5),
                ),
                onPressed: getRecommendations,
                child: const Text(
                  '✨ Dapatkan Rekomendasi',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.deepPurple, width: 1.5),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                onChanged: onChanged,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationList() {
  final recommendations = recommendationResult.split('\n\n');

  return Card(
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    shadowColor: Colors.deepPurple.withOpacity(0.3),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final parts = recommendations[index].split('\n');
          final title = parts.isNotEmpty ? parts[0] : '';
          final author = parts.length > 1 ? parts[1] : '';
          final description = parts.length > 2 ? parts.sublist(2).join('\n') : '';

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5, // Line height untuk keterbacaan yang lebih baik
                    ),
                    textAlign: TextAlign.justify, // Teks di-align justify agar lebih rapi
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
}
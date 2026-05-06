import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'add_edit_movie_screen.dart';

class ManageMoviesScreen extends StatefulWidget {
  const ManageMoviesScreen({super.key});

  @override
  State<ManageMoviesScreen> createState() => _ManageMoviesScreenState();
}

class _ManageMoviesScreenState extends State<ManageMoviesScreen> {
  List<dynamic> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);
    try {
      final movies = await ApiService.fetchMovies();
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _isLoading = false);
    }
  }

  void _deleteMovie(String id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await ApiService.deleteMovie(auth.token!, id);
      _loadMovies();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movie deleted (soft delete)')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Movies')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _movies.length,
            itemBuilder: (context, index) {
              final movie = _movies[index];
              return ListTile(
                leading: movie['poster_url'] != null 
                  ? Image.network(movie['poster_url'], width: 50, fit: BoxFit.cover)
                  : const Icon(Icons.movie),
                title: Text(movie['title']),
                subtitle: Text('${movie['genre']} • ${movie['duration_minutes']} min'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () async {
                        await Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => AddEditMovieScreen(movie: movie))
                        );
                        _loadMovies();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMovie(movie['id']),
                    ),
                  ],
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () async {
          await Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const AddEditMovieScreen())
          );
          _loadMovies();
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

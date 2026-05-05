class Movie {
  final String id;
  final String title;
  final String description;
  final String language;
  final int durationMinutes;
  final String genre;
  final String? posterUrl;
  final String? trailerUrl;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.durationMinutes,
    required this.genre,
    this.posterUrl,
    this.trailerUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      language: json['language'],
      durationMinutes: json['duration_minutes'],
      genre: json['genre'],
      posterUrl: json['poster_url'],
      trailerUrl: json['trailer_url'],
    );
  }
}

class Show {
  final String id;
  final String movieId;
  final DateTime showDate;
  final DateTime startTime;
  final DateTime endTime;
  final double basePrice;

  Show({
    required this.id,
    required this.movieId,
    required this.showDate,
    required this.startTime,
    required this.endTime,
    required this.basePrice,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json['id'],
      movieId: json['movie_id'],
      showDate: DateTime.parse(json['show_date']),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      basePrice: json['base_price'].toDouble(),
    );
  }
}

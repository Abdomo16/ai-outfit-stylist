class RateOutfitResultModel {
  final double rating;
  final String feedback;
  final List<String> suggestions;

  const RateOutfitResultModel({
    required this.rating,
    required this.feedback,
    required this.suggestions,
  });

  factory RateOutfitResultModel.fromJson(Map<String, dynamic> json) {
    return RateOutfitResultModel(
      rating: (json['rating'] as num).toDouble(),
      feedback: json['feedback'] as String,
      suggestions: List<String>.from(json['suggestions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'feedback': feedback,
      'suggestions': suggestions,
    };
  }
}

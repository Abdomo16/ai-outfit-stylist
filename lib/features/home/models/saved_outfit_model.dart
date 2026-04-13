class SavedOutfitModel {
  final String id;
  final String imageUrl;
  final String title;
  final String savedTime;

  const SavedOutfitModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.savedTime,
  });

  factory SavedOutfitModel.fromJson(Map<String, dynamic> json) {
    // Generate a simple relative time based on created_at
    String timeStr = 'Recently';
    if (json['created_at'] != null) {
      try {
        final date = DateTime.parse(json['created_at']);
        final diff = DateTime.now().difference(date);
        if (diff.inDays > 1) {
          timeStr = 'Saved ${diff.inDays} days ago';
        } else if (diff.inDays == 1) {
          timeStr = 'Saved 1 day ago';
        } else if (diff.inHours > 0) {
          timeStr = 'Saved ${diff.inHours} hours ago';
        } else if (diff.inMinutes > 0) {
          timeStr = 'Saved ${diff.inMinutes} mins ago';
        } else {
          timeStr = 'Saved just now';
        }
      } catch (_) {}
    }

    return SavedOutfitModel(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String? ?? 'https://images.unsplash.com/photo-1590890258197-3d142ecf1bb1?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
      title: json['name'] as String? ?? 'Outfit',
      savedTime: timeStr,
    );
  }
}

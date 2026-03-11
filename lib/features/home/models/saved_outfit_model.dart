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
}

// Static mock data until AI generation is implemented.
final List<SavedOutfitModel> mockSavedOutfits = [
  const SavedOutfitModel(
    id: '1',
    imageUrl:
        'https://images.unsplash.com/photo-1590890258197-3d142ecf1bb1?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
    title: 'Date Night',
    savedTime: 'Saved 2 days ago',
  ),
  const SavedOutfitModel(
    id: '2',
    imageUrl:
        'https://images.unsplash.com/photo-1550614000-4b95dd5262c0?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
    title: 'Weekend Chill',
    savedTime: 'Saved 5 days ago',
  ),
  const SavedOutfitModel(
    id: '3',
    imageUrl:
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
    title: 'Office Casual',
    savedTime: 'Saved 1 week ago',
  ),
];

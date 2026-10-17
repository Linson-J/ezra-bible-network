/// A YouTube video or Instagram post shown on the More tab.
class SocialPost {
  const SocialPost({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.url,
    this.published,
    this.isVideo = false,
  });

  final String id;
  final String title;
  final String imageUrl;

  /// Opens in the YouTube or Instagram app.
  final String url;
  final DateTime? published;
  final bool isVideo;
}

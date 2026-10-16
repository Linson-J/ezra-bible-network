/// Static ministry content: about text, contact details and social links.
class AppContent {
  const AppContent({
    this.about = '',
    this.address = '',
    this.email = '',
    this.phone = '',
    this.whatsapp = '',
    this.youtubeUrl = '',
    this.facebookUrl = '',
    this.instagramUrl = '',
    this.websiteUrl = '',
  });

  final String about;
  final String address;
  final String email;
  final String phone;
  final String whatsapp;
  final String youtubeUrl;
  final String facebookUrl;
  final String instagramUrl;
  final String websiteUrl;

  factory AppContent.fromJson(Map<String, dynamic> json) => AppContent(
        about: json['about'] as String? ?? '',
        address: json['address'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        whatsapp: json['whatsapp'] as String? ?? '',
        youtubeUrl: json['youtubeUrl'] as String? ?? '',
        facebookUrl: json['facebookUrl'] as String? ?? '',
        instagramUrl: json['instagramUrl'] as String? ?? '',
        websiteUrl: json['websiteUrl'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'about': about,
        'address': address,
        'email': email,
        'phone': phone,
        'whatsapp': whatsapp,
        'youtubeUrl': youtubeUrl,
        'facebookUrl': facebookUrl,
        'instagramUrl': instagramUrl,
        'websiteUrl': websiteUrl,
      };
}

class FutsalField {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final double pricePerHour;
  final double rating;
  final List<String> features;

  FutsalField({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.pricePerHour,
    required this.rating,
    this.features = const [],
  });
}

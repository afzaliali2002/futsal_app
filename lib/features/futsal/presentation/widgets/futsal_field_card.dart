
import 'package:flutter/material.dart';
import '../../domain/entities/futsal_field.dart';

class FutsalFieldCard extends StatelessWidget {
  final FutsalField field;

  const FutsalFieldCard({super.key, required this.field});

  String _cleanAddress(String address, String city) {
    // Split by comma
    var parts = address.split(',').map((e) => e.trim()).toList();
    
    // Filter out Plus Codes (containing + and short length)
    parts = parts.where((part) {
       // Heuristic: Plus code usually contains '+' and is short.
       if (part.contains('+') && part.length < 15) {
         return false;
       }
       return true;
    }).toList();
    
    // If the address becomes empty or just duplicates the city, handle it
    if (parts.isEmpty) {
      return city;
    }
    
    // Remove parts that are exactly the city name to avoid "Kabul, Kabul"
    parts = parts.where((part) => part.toLowerCase() != city.toLowerCase()).toList();
    
    if (parts.isEmpty) {
      return city;
    }

    return '${parts.join(', ')}, $city';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Use the cleaning logic
    final displayAddress = _cleanAddress(field.address, field.city);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image with Rating overlay
          Stack(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: field.coverImageUrl.isNotEmpty
                    ? Image.network(
                        field.coverImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(context),
                      )
                    : _buildPlaceholderImage(context),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(153),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        field.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Details Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        displayAddress,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(179),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      'شروع از',
                      style: theme.textTheme.bodyMedium
                    ),
                    Text(
                      '${field.pricePerHour.toStringAsFixed(0)} ${field.currency}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.dividerColor.withAlpha(26),
      child: Center(
        child: Icon(
          Icons.sports_soccer,
          size: 60,
          color: theme.primaryColor.withAlpha(102),
        ),
      ),
    );
  }
}

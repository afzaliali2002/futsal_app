
import 'package:flutter/material.dart';
import '../../domain/entities/futsal_field.dart';

class FutsalFieldCard extends StatelessWidget {
  final FutsalField field;
  final bool isCompact;

  const FutsalFieldCard({
    super.key, 
    required this.field,
    this.isCompact = false,
  });

  String _cleanAddress(String address, String city) {
    var parts = address.split(',').map((e) => e.trim()).toList();
    parts = parts.where((part) {
       if (part.contains('+') && part.length < 15) return false;
       return true;
    }).toList();
    if (parts.isEmpty) return city;
    parts = parts.where((part) => part.toLowerCase() != city.toLowerCase()).toList();
    if (parts.isEmpty) return city;
    return '${parts.join(', ')}, $city';
  }
  
  bool _isAvailableToday() {
    if (field.schedule == null || field.schedule!.isEmpty) return false;
    final now = DateTime.now();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final todayName = dayNames[now.weekday - 1]; 
    final slots = field.schedule![todayName];
    if (slots != null && slots.isNotEmpty) {
      return true;
    }
    return false;
  }

  String _translateFeature(String feature) {
    final lower = feature.toLowerCase();
    if (lower.contains('light') || lower.contains('lights')) return 'روشنایی';
    if (lower.contains('parking')) return 'پارکینگ';
    if (lower.contains('changing room')) return 'رختکن';
    if (lower.contains('washroom')) return 'سرویس بهداشتی';
    if (lower.contains('size')) return feature.replaceAll('Size:', 'اندازه:');
    if (lower.contains('grass')) return feature.replaceAll('Grass:', 'چمن:').replaceAll('Artificial', 'مصنوعی').replaceAll('Natural', 'طبیعی');
    return feature; 
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayAddress = _cleanAddress(field.address, field.city);
    final isDark = theme.brightness == Brightness.dark;
    final availableToday = _isAvailableToday();
    
    final features = field.features; 
    final showFeatures = field.rating >= 3.5 && features.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.3), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Area
          Stack(
            children: [
              SizedBox(
                height: isCompact ? 130 : 150, 
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
              // Rating Badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        field.rating.toStringAsFixed(1),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Top Badge (> 3.5)
              if (field.rating >= 3.5)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'برتر',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Info Area
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        field.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, 
                          fontSize: 15, 
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, 
                      size: 12, 
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        displayAddress,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                // Features Grid (Only for Top Grounds)
                if (showFeatures) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: features.take(3).map((feature) {
                       return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue.withOpacity(0.2), width: 0.5),
                          ),
                          child: Text(
                            _translateFeature(feature), 
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 9, 
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (availableToday)
                       Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'امروز موجود است', 
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            fontFamily: theme.textTheme.bodySmall?.fontFamily,
                          ),
                        ),
                       )
                    else 
                       // Visual Time Management Hint
                       Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             Icon(Icons.access_time, size: 10, color: Colors.orange[800]),
                             const SizedBox(width: 2),
                             Text(
                              'برنامه زمانی', 
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                fontFamily: theme.textTheme.bodySmall?.fontFamily,
                              ),
                            ),
                          ],
                        ),
                       ),
                       
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${field.pricePerHour.toStringAsFixed(0)} ${field.currency}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
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
          size: 40,
          color: theme.primaryColor.withAlpha(102),
        ),
      ),
    );
  }
}

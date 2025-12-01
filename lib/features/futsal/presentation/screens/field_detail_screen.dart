// lib/features/futsal/presentation/screens/field_detail_screen.dart

import 'package:flutter/material.dart';

class FieldDetailScreen extends StatelessWidget {
  FieldDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final field = _mockFieldData;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Hero Image (16:9)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
              child: Center(
                child: Icon(
                  Icons.sports_soccer,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            field['name']!,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              const Icon(Icons.location_on, size: 18),
              const SizedBox(width: 6),
              Text(
                field['location']!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rating
          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 18),
              const SizedBox(width: 4),
              Text(
                '${field['rating']} (${field['reviews']} نظر)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price
          Text(
            '${field['price']} / ساعت',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Amenities
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildAmenity(context, Icons.wc, 'سرویس بهداشتی'),
              _buildAmenity(context, Icons.wb_sunny, 'نور کافی'),
              _buildAmenity(context, Icons.local_parking, 'پارکینگ'),
              _buildAmenity(context, Icons.bathtub, 'душ'),
              _buildAmenity(context, Icons.coffee, 'کافی‌شاپ'),
              _buildAmenity(context, Icons.ac_unit, 'سراسیم'),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            field['description']!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 24),

          // Time Slots
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'زمان‌های آزاد',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    final time = '1${8 + index}:00';
                    return Container(
                      margin: EdgeInsets.only(right: index == 7 ? 0 : 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$time',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 100), // Padding for sticky button
        ],
      ),

      // Sticky Book Now Button
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/booking');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'رزرو الآن – ${field['price']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmenity(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  final Map<String, String> _mockFieldData = {
    'name': 'فوتسال المپیک',
    'location': 'تهران، خیابان ولیعصر، نرسیده به میرداماد',
    'rating': '4.8',
    'reviews': '124',
    'price': '۲۵۰,۰۰۰ تومان',
    'description':
    'زمین فوتسال المپیک با چمن مصنوعی باکیفیت، نورپردازی حرفه‌ای، سالن مجزا، رختکن و دوش گرم. مناسب برای مسابقات رسمی و تمرین تیم‌های حرفه‌ای.',
  };
}
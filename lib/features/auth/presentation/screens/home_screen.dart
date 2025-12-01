// lib/features/futsal/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زمین‌های فوتسال'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) => _buildFieldCard(context, index),
      ),
      // Optional: FAB for quick booking
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFieldCard(BuildContext context, int index) {
    final data = _fieldData[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            // Navigate to detail
            Navigator.pushNamed(context, '/field-detail');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (16:9 ratio)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  child: Center(
                    child: Icon(
                      Icons.sports_soccer,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      data['name']!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          data['location']!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Rating + Reviews
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${data['rating']} (${data['reviews']} نظر)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Price + CTA
                    Row(
                      children: [
                        Text(
                          '${data['price']} / ساعت',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Text(
                            'رزرو الآن',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  final List<Map<String, String>> _fieldData = [
    {
      'name': 'فوتسال المپیک',
      'location': 'تهران، خیابان ولیعصر',
      'rating': '4.8',
      'reviews': '124',
      'price': '۲۵۰,۰۰۰ تومان'
    },
    {
      'name': 'زمین فوتسال آریا',
      'location': 'تهران، ستارخان',
      'rating': '4.6',
      'reviews': '98',
      'price': '۲۳۰,۰۰۰ تومان'
    },
    {
      'name': 'فوتسال شهرک غرب',
      'location': 'تهران، شهرک غرب',
      'rating': '4.9',
      'reviews': '210',
      'price': '۲۷۰,۰۰۰ تومان'
    },
    {
      'name': 'زمین فوتسال پارس',
      'location': 'تهران، شریعتی',
      'rating': '4.5',
      'reviews': '76',
      'price': '۲۲۰,۰۰۰ تومان'
    },
    {
      'name': 'فوتسال ولیعصر',
      'location': 'تهران، میرداماد',
      'rating': '4.7',
      'reviews': '142',
      'price': '۲۶۰,۰۰۰ تومان'
    },
    {
      'name': 'زمین فوتسال نیلوفر',
      'location': 'تهران، نیلوفر',
      'rating': '4.4',
      'reviews': '63',
      'price': '۲۴۰,۰۰۰ تومان'
    },
  ];
}
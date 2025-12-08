import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';

class GroundDetailScreen extends StatelessWidget {
  final FutsalField ground;

  const GroundDetailScreen({super.key, required this.ground});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ground.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${ground.address}'),
            Text('Price per hour: ${ground.pricePerHour}'),
            Text('Rating: ${ground.rating}'),
            Text('Features: ${ground.features.join(', ')}'),
          ],
        ),
      ),
    );
  }
}

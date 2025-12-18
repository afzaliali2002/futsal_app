
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _pickedLocation;

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick your Location'),
        actions: [
          if (_pickedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => Navigator.of(context).pop(_pickedLocation),
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(35.6892, 51.3890), // Default to Tehran
          zoom: 12,
        ),
        onTap: _selectLocation,
        markers: _pickedLocation == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('m1'),
                  position: _pickedLocation!,
                ),
              },
      ),
    );
  }
}

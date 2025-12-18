
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPickerScreen({super.key, this.initialLocation});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _pickedLocation;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      final currentLatLng = LatLng(locationData.latitude!, locationData.longitude!);
      setState(() {
        _pickedLocation = currentLatLng;
      });
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLatLng,
            zoom: 15.0,
          ),
        ),
      );
    }
  }

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
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _pickedLocation == null
                ? null
                : () => Navigator.of(context).pop(_pickedLocation),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation ??
              const LatLng(34.5553, 69.2075), // Default to Kabul
          zoom: 12,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
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
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

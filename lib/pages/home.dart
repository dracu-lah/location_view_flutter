import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double lat = 0;
  double lng = 0;

  void getLocation() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lat = position.latitude;
      lng = position.longitude;
    });
  }

  Future<void> openMap(BuildContext context, double lat, double lng) async {
    String url = '';
    String urlAppleMaps = '';
    if (lat == 0 && lng == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("First Get Your Location!"),
      ));
    } else {
      if (Platform.isAndroid) {
        url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          throw 'Could not launch $url';
        }
      } else {
        urlAppleMaps = 'https://maps.apple.com/?q=$lat,$lng';
        url = 'comgooglemaps://?saddr=&daddr=$lat,$lng&directionsmode=driving';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else if (await canLaunchUrl(Uri.parse(urlAppleMaps))) {
          await launchUrl(Uri.parse(urlAppleMaps));
        } else {
          throw 'Could not launch $url';
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Location Viewer",
        ),
        backgroundColor: Colors.black,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      body: content(),
    );
  }

  Center content() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100, bottom: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(lat == 0 && lng == 0
                    ? "Press Get Location For Data"
                    : "Latitude $lat , Longitude $lng"),
                const SizedBox(
                  height: 20,
                ),
                mapContainer(),
              ],
            ),
            buttons(),
          ],
        ),
      ),
    );
  }

  Container mapContainer() {
    return Container(
      child: lat == 0 && lng == 0
          ? const Text("Press Get Location for Map View")
          : SizedBox(
              width: 300,
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  onMapReady: () {},
                  interactionOptions:
                      const InteractionOptions(flags: InteractiveFlag.none),
                  initialCenter: LatLng(lat, lng),
                  initialZoom: 9.2,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lng),
                        width: 100,
                        height: 1000,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Row buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () async {
              await openMap(context, lat, lng);
            },
            child: const Text("Go To Maps")),
        const SizedBox(
          width: 20,
        ),
        ElevatedButton(
            onPressed: getLocation, child: const Text("Get Location")),
        const SizedBox(
          width: 20,
        ),
        ElevatedButton(
            onPressed: () {
              setState(() {
                lat = 0;
                lng = 0;
              });
            },
            child: const Icon(Icons.clear_all))
      ],
    );
  }
}

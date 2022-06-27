import 'package:geocoding/geocoding.dart' as geocodificacion;
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart';
import 'dart:async';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class GeoService {

  final _logger = getLogger('GeoService');
  final GeoFlutterFire geo = GeoFlutterFire();

  Future<Position?> locationFromAddress(String address) async {
    _logger.d(address);
    List<geocodificacion.Location> geoposlist =
        await geocodificacion.locationFromAddress(address);

    if (geoposlist.isEmpty) return Future.value(null);
    _logger.d(geoposlist.first);

    Location location = geoposlist.first;

    GeoFirePoint center =
        geo.point(latitude: location.latitude, longitude: location.longitude);
    Position position =
        Position(geohash: center.hash, geopoint: center.geoPoint);
    return Future.value(position);
  }
}
import 'package:barikoi_api/model/place.dart';


class PickResult {
  PickResult({
    this.placeId,
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.area,
    this.city,
    this.postCode,
    this.pType,
    this.uCode
  });

  final int placeId;
  final num latitude;
  final num longitude;
  final String area;
  final String formattedAddress;
  final String city;
  final int postCode;
  final String pType;
  final String uCode;

  factory PickResult.fromGeocodingResult(Place result) {
    return PickResult(
      placeId: result.id,
      formattedAddress: result.address,
      area: result.area,
      city: result.city,
    );
  }

  factory PickResult.fromPlaceDetailResult(Place result) {
    return PickResult(
      placeId: result.id,
      latitude: num.parse(result.latitude),
      longitude: num.parse(result.longitude),
      formattedAddress: result.address,
      area: result.area,
      city: result.city,

    );
  }
}

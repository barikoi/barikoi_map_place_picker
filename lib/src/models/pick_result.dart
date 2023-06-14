import 'package:barikoi_api/barikoi_api.dart';

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
    this.uCode,
    this.union,
    this.subDistrict,
    this.district,
    this.division,
    this.areaComps,
    this.addrComps,
  });

  final int? placeId;
  num? latitude;
  num? longitude;
  final String? area;
  final String? formattedAddress;
  final String? city;
  int? postCode;
  String? pType;
  String? uCode;
  String? union;
  String? subDistrict;
  String? district;
  String? division;
  AreaComponents? areaComps;
  AddressComponents? addrComps;

  factory PickResult.fromGeocodingResult(Place result) {
    return PickResult(
        placeId: result.id,
        formattedAddress: result.address,
        area: result.area,
        city: result.city,
        uCode: result.uCode,
        union: result.union,
        subDistrict: result.subDistrict,
        district: result.district,
        division: result.division,
        areaComps: result.areaComponents,
        addrComps: result.addressComponents);
  }

  factory PickResult.fromPlaceDetailResult(Place result) {
    return PickResult(
      placeId: result.id,
      latitude: num.parse(result.latitude ?? "0"),
      longitude: num.parse(result.longitude ?? "0"),
      formattedAddress: result.address,
      area: result.area,
      city: result.city,
    );
  }

  PickResult setLongitude(num longitude) {
    this.longitude = longitude;
    return this;
  }

  PickResult setLatitude(num latitude) {
    this.latitude = latitude;
    return this;
  }
}

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
    this.sub_district,
    this.district,
    this.division,
    this.area_comps,
    this.addr_comps,
  });

  final int? placeId;
  num? latitude;
  num? longitude;
  final String? area;
  final String? formattedAddress;
  final String? city;
  final int? postCode;
  final String? pType;
  final String? uCode;
  final String? union;
  final String? sub_district;
  final String? district;
  final String? division;
  final AreaComponents? area_comps;
  final AddressComponents? addr_comps;

  factory PickResult.fromGeocodingResult(Place result) {
    return PickResult(
        placeId: result.id,
        formattedAddress: result.address,
        area: result.area,
        city: result.city,
        uCode: result.uCode,
        union: result.union,
        sub_district: result.subDistrict,
        district: result.subDistrict,
        division: result.division,
        area_comps: result.areaComponents,
        addr_comps: result.addressComponents);
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

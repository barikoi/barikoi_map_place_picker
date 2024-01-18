import 'dart:async';

import 'package:barikoi_api/barikoi_api.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:barikoi_maps_place_picker/src/autocomplete_search.dart';
import 'dart:developer';
import 'package:barikoi_maps_place_picker/src/models/pick_result.dart';
import 'package:barikoi_maps_place_picker/src/place_picker.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';

import '../../barikoi_maps_place_picker.dart';

class PlaceProvider extends ChangeNotifier {
  PlaceProvider(String apiKey) {
    /*geocoding = BarikoiMapsGeocoding(
      apiKey: apiKey,
      baseUrl: proxyBaseUrl,
      httpClient: httpClient,
    );*/
    var bkoi = new BarikoiApi();
    bkoi.setApiKey("key", apiKey);
    bkoiplace = bkoi.getPlaceApi();
  }

  static PlaceProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<PlaceProvider>(context, listen: listen);

  //BarikoiMapsGeocoding geocoding;
  bool isOnUpdateLocationCooldown = false;
  LocationAccuracy? desiredAccuracy;
  bool isAutoCompleteSearching = false;
  late PlaceApi bkoiplace;
  AutoCompleteSearch? bkoisearch;
  Future<Position?> updateCurrentLocation(
      bool forceAndroidLocationManager) async {
    try {
      LocationPermission value = await Geolocator.checkPermission();
      if (value == LocationPermission.whileInUse ||
          value == LocationPermission.always) {
        currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: desiredAccuracy ?? LocationAccuracy.high);
        notifyListeners();
        return currentPosition;
      } else if (value == LocationPermission.denied ||
          value == LocationPermission.unableToDetermine) {
        LocationPermission value = await Geolocator.requestPermission();
        if (value == LocationPermission.whileInUse ||
            value == LocationPermission.always) {
          currentPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: desiredAccuracy ?? LocationAccuracy.high);
          notifyListeners();
          return currentPosition;
        }
      } else {
        log(value.toString());
        return null;
      }

      // await Permission.location.request();
      // if ( await Permission.location.request().isGranted) {
      //
      //   Future<Position> curpos = Geolocator.getCurrentPosition(
      //       desiredAccuracy: desiredAccuracy ?? LocationAccuracy.high);
      //   curpos.then((value) => currentPosition=value);
      // } else {
      //   currentPosition = null;
      //   await Permission.location.request();
      // }
    } catch (e) {
      log(e.toString());
      currentPosition = null;
    }
    notifyListeners();
    return null;
  }

  Position? _currentPoisition;
  Position? get currentPosition => _currentPoisition;
  set currentPosition(Position? newPosition) {
    _currentPoisition = newPosition;
    notifyListeners();
  }

  Timer? _debounceTimer;
  Timer? get debounceTimer => _debounceTimer;
  set debounceTimer(Timer? timer) {
    _debounceTimer = timer;
    notifyListeners();
  }

  CameraPosition? _previousCameraPosition;
  CameraPosition? get prevCameraPosition => _previousCameraPosition;
  setPrevCameraPosition(CameraPosition prePosition) {
    _previousCameraPosition = prePosition;
  }

  CameraPosition? _currentCameraPosition;
  CameraPosition? get cameraPosition => _currentCameraPosition;
  setCameraPosition(CameraPosition? newPosition) {
    _currentCameraPosition = newPosition;
  }

  PickResult? _selectedPlace;
  PickResult? get selectedPlace => _selectedPlace;
  set selectedPlace(PickResult? result) {
    _selectedPlace = result;
    notifyListeners();
  }

  SearchingState _placeSearchingState = SearchingState.Idle;
  SearchingState get placeSearchingState => _placeSearchingState;
  set placeSearchingState(SearchingState newState) {
    _placeSearchingState = newState;
    notifyListeners();
  }

  MaplibreMapController? _mapController;
  MaplibreMapController? get mapController => _mapController;
  set mapController(MaplibreMapController? controller) {
    _mapController = controller;
    notifyListeners();
  }

  PinState _pinState = PinState.Preparing;
  PinState get pinState => _pinState;
  set pinState(PinState newState) {
    _pinState = newState;
    notifyListeners();
  }

  bool _isSeachBarFocused = false;
  bool get isSearchBarFocused => _isSeachBarFocused;
  set isSearchBarFocused(bool focused) {
    _isSeachBarFocused = focused;
    notifyListeners();
  }
}

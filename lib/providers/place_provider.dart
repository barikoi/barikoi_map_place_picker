import 'dart:async';

import 'package:barikoi_api/api.dart';
import 'package:barikoi_api/api/place_api.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:barikoi_maps_place_picker/src/autocomplete_search.dart';
//import 'package:barikoi_maps_flutter/barikoi_maps_flutter.dart';
import 'package:barikoi_maps_place_picker/src/models/pick_result.dart';
import 'package:barikoi_maps_place_picker/src/place_picker.dart';
import 'package:http/http.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PlaceProvider extends ChangeNotifier {
  PlaceProvider(String apiKey, String proxyBaseUrl, Client httpClient) {

    /*geocoding = BarikoiMapsGeocoding(
      apiKey: apiKey,
      baseUrl: proxyBaseUrl,
      httpClient: httpClient,
    );*/
    var bkoi=new BarikoiApi();
    bkoi.setApiKey("key",  apiKey);
    bkoiplace= bkoi.getPlaceApi();

  }

  static PlaceProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<PlaceProvider>(context, listen: listen);

  //BarikoiMapsGeocoding geocoding;
  bool isOnUpdateLocationCooldown = false;
  LocationAccuracy desiredAccuracy;
  bool isAutoCompleteSearching = false;
  PlaceApi bkoiplace;
  AutoCompleteSearch bkoisearch;
  Future<void> updateCurrentLocation(bool forceAndroidLocationManager) async {
    try {
      await Permission.location.request();
      if (await Permission.location.request().isGranted) {

        Future<Position> curpos = Geolocator.getCurrentPosition(
            desiredAccuracy: desiredAccuracy ?? LocationAccuracy.high);
        curpos.then((value) => currentPosition=value);
      } else {
        currentPosition = null;
      }
    } catch (e) {
      print(e);
      currentPosition = null;
    }

    notifyListeners();
  }

  Position _currentPoisition;
  Position get currentPosition => _currentPoisition;
  set currentPosition(Position newPosition) {
    _currentPoisition = newPosition;
    notifyListeners();
  }

  Timer _debounceTimer;
  Timer get debounceTimer => _debounceTimer;
  set debounceTimer(Timer timer) {
    _debounceTimer = timer;
    notifyListeners();
  }

  CameraPosition _previousCameraPosition;
  CameraPosition get prevCameraPosition => _previousCameraPosition;
  setPrevCameraPosition(CameraPosition prePosition) {
    _previousCameraPosition = prePosition;
  }

  CameraPosition _currentCameraPosition;
  CameraPosition get cameraPosition => _currentCameraPosition;
  setCameraPosition(CameraPosition newPosition) {
    _currentCameraPosition = newPosition;
  }

  PickResult _selectedPlace;
  PickResult get selectedPlace => _selectedPlace;
  set selectedPlace(PickResult result) {
    _selectedPlace = result;
    notifyListeners();
  }

  SearchingState _placeSearchingState = SearchingState.Idle;
  SearchingState get placeSearchingState => _placeSearchingState;
  set placeSearchingState(SearchingState newState) {
    _placeSearchingState = newState;
    notifyListeners();
  }

  MaplibreMapController _mapController;
  MaplibreMapController get mapController => _mapController;
  set mapController(MaplibreMapController controller) {
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

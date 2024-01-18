import 'dart:async';

import 'package:barikoi_api/barikoi_api.dart';
import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:barikoi_maps_place_picker/barikoi_maps_place_picker.dart';
import 'package:barikoi_maps_place_picker/src/providers/place_provider.dart';
import 'package:barikoi_maps_place_picker/src/autocomplete_search.dart';
import 'package:barikoi_maps_place_picker/src/controllers/autocomplete_search_controller.dart';
import 'package:barikoi_maps_place_picker/src/barikoi_map_place_picker.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

enum PinState { Preparing, Idle, Dragging }

enum SearchingState { Idle, Searching }

class PlacePicker extends StatefulWidget {
  PlacePicker(
      {Key? key,
      required this.apiKey,
      required this.onPlacePicked,
      required this.initialPosition,
      this.useCurrentLocation = true,
      // this.desiredLocationAccuracy = LocationAccuracy.high,
      this.onMapCreated,
      this.hintText,
      this.searchingText,
      this.onAutoCompleteFailed,
      this.onGeocodingSearchFailed,
      this.selectedPlaceWidgetBuilder,
      this.pinBuilder,
      this.autoCompleteDebounceInMilliseconds = 300,
      this.cameraMoveDebounceInMilliseconds = 350,
      this.enableMapTypeButton = true,
      this.enableMyLocationButton = true,
      this.myLocationButtonCooldown = 3,
      this.usePinPointingSearch = true,
      this.usePlaceDetailSearch = false,
      this.autocompleteOffset,
      this.autocompleteRadius,
      this.autocompleteLanguage,
      this.autocompleteTypes,
      this.getAdditionalPlaceData = const [],
      this.strictbounds,
      this.region,
      this.selectInitialPosition = false,
      this.resizeToAvoidBottomInset = true,
      this.initialSearchString,
      this.searchForInitialValue = false,
      this.forceAndroidLocationManager = false,
      this.forceSearchOnZoomChanged = false,
      this.automaticallyImplyAppBarLeading = true,
      this.autocompleteOnTrailingWhitespace = false,
      this.hidePlaceDetailsWhenDraggingPin = true, this.proxyBaseUrl})
      : super(key: key);

  final String apiKey;

  final LatLng initialPosition;
  final bool useCurrentLocation;
  // final LocationAccuracy desiredLocationAccuracy;

  final MapCreatedCallback? onMapCreated;

  final String? hintText;
  final String? searchingText;
  // final double searchBarHeight;
  // final EdgeInsetsGeometry contentPadding;
  final List<PlaceDetails> getAdditionalPlaceData;
  final ValueChanged<String?>? onAutoCompleteFailed;
  final ValueChanged<String?>? onGeocodingSearchFailed;
  final int autoCompleteDebounceInMilliseconds;
  final int cameraMoveDebounceInMilliseconds;

  final bool enableMapTypeButton;
  final bool enableMyLocationButton;
  final int myLocationButtonCooldown;

  final bool usePinPointingSearch;
  final bool usePlaceDetailSearch;

  final num? autocompleteOffset;
  final num? autocompleteRadius;
  final String? autocompleteLanguage;
  final List<String>? autocompleteTypes;
  final bool? strictbounds;
  final String? region;

  /// If true the [body] and the scaffold's floating widgets should size
  /// themselves to avoid the onscreen keyboard whose height is defined by the
  /// ambient [MediaQuery]'s [MediaQueryData.viewInsets] `bottom` property.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// scaffold, the body can be resized to avoid overlapping the keyboard, which
  /// prevents widgets inside the body from being obscured by the keyboard.
  ///
  /// Defaults to true.
  final bool resizeToAvoidBottomInset;

  final bool selectInitialPosition;

  /// By using default setting of Place Picker, it will result result when user hits the select here button.
  ///
  /// If you managed to use your own [selectedPlaceWidgetBuilder], then this WILL NOT be invoked, and you need use data which is
  /// being sent with [selectedPlaceWidgetBuilder].
  final ValueChanged<PickResult> onPlacePicked;

  /// optional - builds selected place's UI
  ///
  /// It is provided by default if you leave it as a null.
  /// INPORTANT: If this is non-null, [onPlacePicked] will not be invoked, as there will be no default 'Select here' button.
  final SelectedPlaceWidgetBuilder? selectedPlaceWidgetBuilder;

  /// optional - builds customized pin widget which indicates current pointing position.
  ///
  /// It is provided by default if you leave it as a null.
  final PinBuilder? pinBuilder;

  /// optional - sets 'proxy' value in barikoi_maps_webservice
  ///
  /// In case of using a proxy the baseUrl can be set.
  /// The apiKey is not required in case the proxy sets it.
  /// (Not storing the apiKey in the app is good practice)
  final String? proxyBaseUrl;



  /// Initial value of autocomplete search
  final String? initialSearchString;

  /// Whether to search for the initial value or not
  final bool searchForInitialValue;

  /// On Android devices you can set [forceAndroidLocationManager]
  /// to true to force the plugin to use the [LocationManager] to determine the
  /// position instead of the [FusedLocationProviderClient]. On iOS this is ignored.
  final bool forceAndroidLocationManager;

  /// Allow searching place when zoom has changed. By default searching is disabled when zoom has changed in order to prevent unwilling API usage.
  final bool forceSearchOnZoomChanged;

  /// Whether to display appbar backbutton. Defaults to true.
  final bool automaticallyImplyAppBarLeading;

  /// Will perform an autocomplete search, if set to true. Note that setting
  /// this to true, while providing a smoother UX experience, may cause
  /// additional unnecessary queries to the Places API.
  ///
  /// Defaults to false.
  final bool autocompleteOnTrailingWhitespace;

  final bool hidePlaceDetailsWhenDraggingPin;

  @override
  _PlacePickerState createState() => _PlacePickerState();
}

class _PlacePickerState extends State<PlacePicker> {
  GlobalKey appBarKey = GlobalKey();
  PlaceProvider? provider;
  SearchBarController searchBarController = SearchBarController();

  @override
  void initState() {
    super.initState();

    provider =
        PlaceProvider(widget.apiKey);

    //provider!.desiredAccuracy = widget.desiredLocationAccuracy;
  }

  @override
  void dispose() {
    searchBarController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          searchBarController.clearOverlay();
          return Future.value(true);
        },
        child: ChangeNotifierProvider.value(
          value: provider,
          child: Builder(
            builder: (context) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  key: appBarKey,
                  automaticallyImplyLeading: false,
                  iconTheme: Theme.of(context).iconTheme,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  titleSpacing: 0.0,
                  title: _buildSearchBar(),
                ),
                body: _buildMapWithLocation(),
              );
            },
          ),
        ));
  }

  Widget _buildSearchBar() {
    return Row(
      children: <Widget>[
        widget.automaticallyImplyAppBarLeading
            ? IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: Icon(
                  Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                ),
                padding: EdgeInsets.zero)
            : SizedBox(width: 15),
        Expanded(
          child: AutoCompleteSearch(
              appBarKey: appBarKey,
              searchBarController: searchBarController,
              hintText: widget.hintText,
              searchingText: widget.searchingText,
              debounceMilliseconds: widget.autoCompleteDebounceInMilliseconds,
              onPicked: (prediction) {
                _pickPrediction(prediction);
              },
              onSearchFailed: (status) {
                if (widget.onAutoCompleteFailed != null) {
                  widget.onAutoCompleteFailed!(status);
                }
              },
              autocompleteOffset: widget.autocompleteOffset,
              autocompleteRadius: widget.autocompleteRadius,
              autocompleteLanguage: widget.autocompleteLanguage,
              autocompleteTypes: widget.autocompleteTypes,
              strictbounds: widget.strictbounds,
              region: widget.region,
              initialSearchString: widget.initialSearchString,
              searchForInitialValue: widget.searchForInitialValue,
              autocompleteOnTrailingWhitespace:
                  widget.autocompleteOnTrailingWhitespace),
        ),
        SizedBox(width: 5),
      ],
    );
  }

  _pickPrediction(Place prediction) async {
    // provider!.placeSearchingState = SearchingState.Searching;

    /*final PlacesDetailsResponse response =
        await provider.bkoiplace.getDetailsByPlaceId(
      prediction.placeId,
      sessionToken: provider.sessionToken,
      language: widget.autocompleteLanguage,
    );

    if (response.errorMessage?.isNotEmpty == true ||
        response.status == "REQUEST_DENIED") {
      print("AutoCompleteSearch Error: " + response.errorMessage);
      if (widget.onAutoCompleteFailed != null) {
        widget.onAutoCompleteFailed(response.status);
      }
      return;
    }*/

    provider!.selectedPlace = PickResult.fromPlaceDetailResult(prediction);

    // Prevents searching again by camera movement.
    provider!.isAutoCompleteSearching = true;

    await _moveTo(provider!.selectedPlace!.latitude as double?,
        provider!.selectedPlace!.longitude as double?);

    provider!.placeSearchingState = SearchingState.Idle;
  }

  _moveTo(double? latitude, double? longitude) async {
    MaplibreMapController? controller = provider!.mapController;
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude!, longitude!),
          zoom: 16,
        ),
      ),
    );
  }

  _moveToCurrentPosition() async {
    if (provider!.currentPosition != null) {
      await _moveTo(provider!.currentPosition!.latitude,
          provider!.currentPosition!.longitude);
    }
  }

  Widget _buildMapWithLocation() {
    // if (widget.useCurrentLocation!) {
    //   return FutureBuilder(
    //       future: provider!
    //           .updateCurrentLocation(widget.forceAndroidLocationManager),
    //       builder: (context, snap) {
    //         if (snap.connectionState == ConnectionState.waiting) {
    //           return const Center(child: CircularProgressIndicator());
    //         } else {
    //           if (provider!.currentPosition == null) {
    //             return _buildMap(widget.initialPosition);
    //           } else {
    //             return _buildMap(LatLng(provider!.currentPosition!.latitude,
    //                 provider!.currentPosition!.longitude));
    //           }
    //         }
    //       });
    // } else {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: 1)),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return _buildMap(widget.initialPosition);
        }
      },
    );
    // }
  }

  Widget _buildMap(LatLng initialTarget) {
    return BarikoiMapPlacePicker(
      apikey: widget.apiKey,
      initialTarget: initialTarget,
      appBarKey: appBarKey,
      selectedPlaceWidgetBuilder: widget.selectedPlaceWidgetBuilder,
      pinBuilder: widget.pinBuilder,
      onSearchFailed: widget.onGeocodingSearchFailed,
      debounceMilliseconds: widget.cameraMoveDebounceInMilliseconds,
      enableMapTypeButton: widget.enableMapTypeButton,
      enableMyLocationButton: widget.enableMyLocationButton,
      useCurrentLocation: widget.useCurrentLocation,
      usePinPointingSearch: widget.usePinPointingSearch,
      usePlaceDetailSearch: widget.usePlaceDetailSearch,
      getAdditionalPlaceData: widget.getAdditionalPlaceData,
      onMapCreated: widget.onMapCreated,
      selectInitialPosition: widget.selectInitialPosition,
      language: widget.autocompleteLanguage,
      forceSearchOnZoomChanged: widget.forceSearchOnZoomChanged,
      hidePlaceDetailsWhenDraggingPin: widget.hidePlaceDetailsWhenDraggingPin,
      onMyLocation: () async {
        // Prevent to click many times in short period.
        if (provider!.isOnUpdateLocationCooldown == false) {
          provider!.isOnUpdateLocationCooldown = true;
          Timer(Duration(seconds: widget.myLocationButtonCooldown), () {
            provider!.isOnUpdateLocationCooldown = false;
          });
          provider!
              .updateCurrentLocation(widget.forceAndroidLocationManager)
              .then((value) => _moveToCurrentPosition());
        }
      },
      onMoveStart: () {
        searchBarController.reset();
      },
      onPlacePicked: widget.onPlacePicked,
    );
  }
}

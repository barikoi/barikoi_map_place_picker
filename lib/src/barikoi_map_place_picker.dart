import 'dart:async';
import 'dart:developer';

import 'package:barikoi_api/barikoi_api.dart';
import 'package:dio/src/response.dart';
import 'package:flutter/material.dart';

import 'package:barikoi_maps_place_picker/barikoi_maps_place_picker.dart';
import 'package:barikoi_maps_place_picker/src/providers/place_provider.dart';
import 'package:barikoi_maps_place_picker/src/components/animated_pin.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

typedef SelectedPlaceWidgetBuilder = Widget Function(
  BuildContext context,
  PickResult? selectedPlace,
  SearchingState state,
  bool isSearchBarFocused,
);

typedef PinBuilder = Widget Function(
  BuildContext context,
  PinState state,
);

class BarikoiMapPlacePicker extends StatelessWidget {
  const BarikoiMapPlacePicker({
    Key? key,
    required this.apikey,
    required this.initialTarget,
    required this.appBarKey,
    required this.onPlacePicked,
    this.selectedPlaceWidgetBuilder,
    this.pinBuilder,
    this.onSearchFailed,
    this.onMoveStart,
    this.onMapCreated,
    this.debounceMilliseconds,
    this.enableMapTypeButton,
    this.enableMyLocationButton,
    this.onToggleMapType,
    this.onMyLocation,
    this.usePinPointingSearch,
    this.usePlaceDetailSearch,
    this.getAdditionalPlaceData = const [],
    this.selectInitialPosition,
    this.language,
    this.forceSearchOnZoomChanged,
    this.hidePlaceDetailsWhenDraggingPin,
    this.useCurrentLocation = true,
  }) : super(key: key);

  final String apikey;
  final LatLng initialTarget;
  final GlobalKey appBarKey;

  final SelectedPlaceWidgetBuilder? selectedPlaceWidgetBuilder;
  final PinBuilder? pinBuilder;

  final ValueChanged<String?>? onSearchFailed;
  final VoidCallback? onMoveStart;
  final MapCreatedCallback? onMapCreated;
  final VoidCallback? onToggleMapType;
  final VoidCallback? onMyLocation;
  final ValueChanged<PickResult> onPlacePicked;

  final int? debounceMilliseconds;
  final bool? enableMapTypeButton;
  final bool? enableMyLocationButton;

  final bool? usePinPointingSearch;
  final bool? usePlaceDetailSearch;
  final List<PlaceDetails> getAdditionalPlaceData;
  final bool? selectInitialPosition;

  final String? language;
  final bool useCurrentLocation;
  final bool? forceSearchOnZoomChanged;
  final bool? hidePlaceDetailsWhenDraggingPin;

  _searchByCameraLocation(PlaceProvider provider) async {
    // We don't want to search location again if camera location is changed by zooming in/out.
    bool hasZoomChanged = provider.cameraPosition != null &&
        provider.prevCameraPosition != null &&
        provider.cameraPosition!.zoom != provider.prevCameraPosition!.zoom;

    if (forceSearchOnZoomChanged == false && hasZoomChanged) {
      provider.placeSearchingState = SearchingState.Idle;
      return;
    }

    provider.placeSearchingState = SearchingState.Searching;
    double? lat = provider.mapController?.cameraPosition?.target.latitude;
    double? lon = provider.mapController?.cameraPosition?.target.longitude;

    final Future<Response<Getrevgeoplace200Response>> response =
        provider.bkoiplace.getrevgeoplace(
      latitude: lat!,
      longitude: lon!,
      area: getAdditionalPlaceData.contains(PlaceDetails.area_components)
          ? true
          : null,
      address: getAdditionalPlaceData.contains(PlaceDetails.addr_components)
          ? true
          : null,
      union: getAdditionalPlaceData.contains(PlaceDetails.union) ? true : null,
      subDistrict: getAdditionalPlaceData.contains(PlaceDetails.sub_district)
          ? true
          : null,
      district:
          getAdditionalPlaceData.contains(PlaceDetails.district) ? true : null,
      pauroshova: getAdditionalPlaceData.contains(PlaceDetails.pauroshova)
          ? true
          : null,
      division:
          getAdditionalPlaceData.contains(PlaceDetails.division) ? true : null,
      country:
          getAdditionalPlaceData.contains(PlaceDetails.country) ? true : null,
    );
    response.then((value) {
      if (value.data!.status == 200) {
        provider.selectedPlace =
            PickResult.fromGeocodingResult(value.data!.place!)
                .setLatitude(lat)
                .setLongitude(lon);
        provider.placeSearchingState = SearchingState.Idle;
      } else {
        if (onSearchFailed != null) {
          onSearchFailed!(value.statusMessage);
        }
        provider.placeSearchingState = SearchingState.Idle;
      }
    }).catchError((error) {
      if (onSearchFailed != null) {
        onSearchFailed!(error.toString());
      }
      provider.placeSearchingState = SearchingState.Idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildMap(context),
        _buildPin(),
        _buildFloatingCard(),
        _buildMapIcons(context),
      ],
    );
  }

  Widget _buildMap(BuildContext context) {
    PlaceProvider provider = PlaceProvider.of(context, listen: false);
    CameraPosition initialCameraPosition =
        CameraPosition(target: initialTarget, zoom: 16);
    return MaplibreMap(
      styleString:
          "https://map.barikoi.com/styles/osm-liberty/style.json?key=" +
              this.apikey,
      initialCameraPosition: CameraPosition(target: initialTarget, zoom: 16),
      myLocationRenderMode: MyLocationRenderMode.NORMAL,
      compassEnabled: false,
      zoomGesturesEnabled: true,
      myLocationEnabled: false,
      onMapCreated: (MaplibreMapController controller) {
        provider.mapController = controller;
        provider.setCameraPosition(null);
        provider.pinState = PinState.Idle;
        provider.updateCurrentLocation(false);
        // When select initialPosition set to true.
        if (useCurrentLocation) {
          onMyLocation!();
        }
        if (selectInitialPosition!) {
          provider.setCameraPosition(initialCameraPosition);
          _searchByCameraLocation(provider);
        }
      },

      trackCameraPosition: true,
      onCameraIdle: () {
        log("camera movement stopped");
        if (provider.isSearchBarFocused) {
          provider.isAutoCompleteSearching = true;

          provider.pinState = PinState.Idle;
          return;
        }
        onMoveStart!();

        // Perform search only if the setting is to true.
        if (usePinPointingSearch!) {
          // Search current camera location only if camera has moved (dragged) before.
          log("revgeo in commence");
          // Cancel previous timer.
          if (provider.debounceTimer?.isActive ?? false) {
            provider.debounceTimer!.cancel();
          }
          provider.debounceTimer =
              Timer(Duration(milliseconds: debounceMilliseconds!), () {
            _searchByCameraLocation(provider);
          });
        }

        provider.pinState = PinState.Idle;
      },
      /*onCameraIdle: (CameraPosition position) {
          provider.setCameraPosition();
        },*/
      // gestureRecognizers make it possible to navigate the map when it's a
      // child in a scroll view e.g ListView, SingleChildScrollView...
      // gestureRecognizers: Set()..add(Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())),
    );
  }

  Widget _buildPin() {
    return Center(
      child: Selector<PlaceProvider, PinState>(
        selector: (_, provider) => provider.pinState,
        builder: (context, state, __) {
          if (pinBuilder == null) {
            return _defaultPinBuilder(context, state);
          } else {
            return Builder(
                builder: (builderContext) =>
                    pinBuilder!(builderContext, state));
          }
        },
      ),
    );
  }

  Widget _defaultPinBuilder(BuildContext context, PinState state) {
    if (state == PinState.Preparing) {
      return Container();
    } else if (state == PinState.Idle) {
      return Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.place, size: 36, color: Colors.red),
                SizedBox(height: 42),
              ],
            ),
          ),
          Center(
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedPin(
                    child: Icon(Icons.place, size: 36, color: Colors.red)),
                SizedBox(height: 42),
              ],
            ),
          ),
          Center(
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildFloatingCard() {
    return Selector<PlaceProvider,
        Tuple4<PickResult?, SearchingState, bool, PinState>>(
      selector: (_, provider) => Tuple4(
          provider.selectedPlace,
          provider.placeSearchingState,
          provider.isSearchBarFocused,
          provider.pinState),
      builder: (context, data, __) {
        if (((data.item1 == null || data.item1!.formattedAddress == null) &&
                data.item2 == SearchingState.Idle) ||
            data.item3 == true ||
            data.item4 == PinState.Dragging &&
                this.hidePlaceDetailsWhenDraggingPin!) {
          return Container();
        } else {
          if (selectedPlaceWidgetBuilder == null) {
            return _defaultPlaceWidgetBuilder(context, data.item1, data.item2);
          } else {
            return Builder(
                builder: (builderContext) => selectedPlaceWidgetBuilder!(
                    builderContext, data.item1, data.item2, data.item3));
          }
        }
      },
    );
  }

  Widget _defaultPlaceWidgetBuilder(
      BuildContext context, PickResult? data, SearchingState state) {
    return FloatingCard(
      bottomPosition: MediaQuery.of(context).size.height * 0.05,
      leftPosition: MediaQuery.of(context).size.width * 0.025,
      rightPosition: MediaQuery.of(context).size.width * 0.025,
      width: MediaQuery.of(context).size.width * 0.9,
      borderRadius: BorderRadius.circular(12.0),
      elevation: 4.0,
      color: Theme.of(context).cardColor,
      child: state == SearchingState.Searching
          ? _buildLoadingIndicator()
          : _buildSelectionDetails(context, data!),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 48,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildSelectionDetails(BuildContext context, PickResult result) {
    //log(result.formattedAddress);
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(
            result.formattedAddress!,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          OutlinedButton(
            child: Text(
              "Select here",
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              onPlacePicked(result);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapIcons(BuildContext context) {
    final RenderBox appBarRenderBox =
        appBarKey.currentContext!.findRenderObject() as RenderBox;

    return Positioned(
      top: appBarRenderBox.size.height,
      right: 15,
      child: Column(
        children: <Widget>[
          // enableMapTypeButton!
          //     ? Container(
          //         width: 35,
          //         height: 35,
          //         child: RawMaterialButton(
          //           shape: CircleBorder(),
          //           fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : Colors.white,
          //           elevation: 8.0,
          //           onPressed: onToggleMapType,
          //           child: Icon(Icons.layers),
          //         ),
          //       )
          //     : Container(),
          SizedBox(height: 10),
          enableMyLocationButton!
              ? Container(
                  width: 35,
                  height: 35,
                  child: RawMaterialButton(
                    shape: CircleBorder(),
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black54
                        : Colors.white,
                    elevation: 8.0,
                    onPressed: onMyLocation,
                    child: Icon(Icons.my_location),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}

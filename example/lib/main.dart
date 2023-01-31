import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:barikoi_maps_place_picker/barikoi_maps_place_picker.dart';
//import 'package:barikoi_maps_flutter/barikoi_maps_flutter.dart';
// Your api key storage.

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // Light Theme
  final ThemeData lightTheme = ThemeData.light().copyWith(
    // Background color of the FloatingCard
    cardColor: Colors.white,
    buttonTheme: ButtonThemeData(
      // Select here's button color
      buttonColor: Colors.black,
      textTheme: ButtonTextTheme.primary,
    ),
  );

  // Dark Theme
  final ThemeData darkTheme = ThemeData.dark().copyWith(
    // Background color of the FloatingCard
    cardColor: Colors.grey,
    buttonTheme: ButtonThemeData(
      // Select here's button color
      buttonColor: Colors.yellow,
      textTheme: ButtonTextTheme.primary,
    ),
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barikoi Map Place Picker Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static final kInitialPosition = LatLng(23.8567844, 90.213108);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PickResult? selectedPlace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Barikoi Map Place Picker Demo"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: Text("Load Barikoi Place Picker"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return PlacePicker(
                          apiKey: "BARIKOI_API_KEY_HERE",
                          initialPosition: LatLng(23.8567844, 90.213108),
                          useCurrentLocation: true,
                          selectInitialPosition: true,
                          usePinPointingSearch: true,
                          getAdditionalPlaceData: [
                            PlaceDetails.area_components,
                            PlaceDetails.addr_components,
                            PlaceDetails.district
                          ],
                          onPlacePicked: (result) {
                            selectedPlace = result;
                            log("place ucode: " +
                                result.toString() +
                                " sub_area: " +
                                (selectedPlace?.areaComps?.subArea ?? ""));

                            Navigator.of(context).pop();
                            setState(() {});
                          },
                          onAutoCompleteFailed: (status) {
                            print(status);
                          },
                          //forceSearchOnZoomChanged: true,
                          automaticallyImplyAppBarLeading: false,
                          //autocompleteLanguage: "ko",
                          //region: 'au',
                          /*selectedPlaceWidgetBuilder: (_, selectedPlace, state, isSearchBarFocused) {
                            print("state: $state, isSearchBarFocused: $isSearchBarFocused");
                            return isSearchBarFocused
                                ? Container()
                                : FloatingCard(
                                    bottomPosition: 0.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                                    leftPosition: 0.0,
                                    rightPosition: 0.0,
                                    width: 500,

                                    borderRadius: BorderRadius.circular(12.0),
                                    child: state == SearchingState.Searching
                                        ? Center(child: CircularProgressIndicator())
                                        : RaisedButton(
                                            child: Text("Pick Here"),
                                            onPressed: () {
                                              // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
                                              //            this will override default 'Select here' Button.
                                                Navigator.of(context).pop();
                                            },
                                          ),
                                  );
                          },*/
                          // pinBuilder: (context, state) {
                          //   if (state == PinState.Idle) {
                          //     return Icon(Icons.favorite_border);
                          //   } else {
                          //     return Icon(Icons.favorite);
                          //   }
                          // },
                        );
                      },
                    ),
                  );
                },
              ),
              selectedPlace == null
                  ? Container()
                  : Text((selectedPlace?.formattedAddress ?? "") +
                      " " +
                      (selectedPlace?.areaComps?.subArea ?? "") +
                      " " +
                      (selectedPlace?.areaComps?.area ?? "")),
            ],
          ),
        ));
  }
}

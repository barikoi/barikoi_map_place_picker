# barikoi_map_place_picker

### Github
If this Dart package is published to Github, please include the following in pubspec.yaml
```

dependencies:
  barikoi_map_place_picker:
    git: 
      url: https://github.com/barikoi/barikoi_map_place_picker.git
      ref: main
```

### Local
To use the package in your local drive, please include the following in pubspec.yaml
```
dependencies:
  barikoi_api:
    path: /path/to/barikoi_map_place_picker
```

## Getting Started
For iOS platform, go to your projects ios folder and add these lines to your pod file :  
```
pod 'MapLibre', :git =>  'https://github.com/m0nac0/maplibre-cocoapods.git'
pod 'MapLibreAnnotationExtension', :git => 'https://github.com/m0nac0/maplibre-annotation-extension.git'
```

open your info.plist file and add these string resources
```
xml ...
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>[Your explanation here]</string>
```

For android, add the location permissions in the app manifest
```
     <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

To use the place picker as a widget, add the following code 
``` 
PlacePicker(
    apiKey: "API_KEY", //Barikoi API key
    initialPosition: HomePage.kInitialPosition, //initial location position to start the map with 
    useCurrentLocation: true, // option to use the current location for picking a place, true by default
    selectInitialPosition: true, //option to load the initial position to start the map with
    usePinPointingSearch: true,  //option to use reversegeo api to get place from location point, default value is true
    onPlacePicked: (result) {   //returns the place object selected in the place picker 
    selectedPlace = result;
    },
);
```

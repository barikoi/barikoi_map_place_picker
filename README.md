# barikoi_map_place_picker

### Github
If this Dart package is published to Github, please include the following in pubspec.yaml
```

dependencies:
  barikoi_api:
    git: https://github.com/barikoi/barikoi_map_place_picker.git
      version: 'any'
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

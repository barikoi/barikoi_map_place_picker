import 'package:barikoi_api/barikoi_api.dart';
import 'package:barikoi_maps_place_picker/src/components/highlight_text.dart';
import 'package:flutter/material.dart';

class PredictionTile extends StatelessWidget {
  final Place prediction;
  final ValueChanged<Place>? onTap;
  final String? searchText;
  final Color? matchTextColor;
  final Color? unMatchedTextColor;

  PredictionTile({required this.prediction, this.onTap, this.searchText, this.matchTextColor, this.unMatchedTextColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.location_on),
      title: RichText(
        text: TextSpan(
          children: buildHighlightText(context, prediction, searchText: searchText, matchTextColor: matchTextColor, unMatchedTextColor: unMatchedTextColor),
        ),
      ),
      onTap: () {
        if (onTap != null) {
          onTap!(prediction);
        }
      },
    );
  }

}

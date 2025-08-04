import 'package:barikoi_api/barikoi_api.dart';
import 'package:flutter/material.dart';

List<TextSpan> buildHighlightText(BuildContext context, Place prediction, {String? searchText ,Color? matchTextColor, Color? unMatchedTextColor}) {
  final List<TextSpan> result = <TextSpan>[];
  final textColor = unMatchedTextColor ?? Theme.of(context).textTheme.titleLarge!.color;
  final highlightColor = matchTextColor ?? Theme.of(context).colorScheme.primary; // or any color you want

  final address = prediction.address;
  if (searchText == null || searchText.isEmpty) {
    result.add(
      TextSpan(
        text: address,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
    return result;
  }

  final lowerAddress = address.toLowerCase();
  final lowerSearch = searchText.toLowerCase();

  int start = 0;
  while (true) {
    final index = lowerAddress.indexOf(lowerSearch, start);
    if (index == -1) {
      // Add the remaining text
      result.add(
        TextSpan(
          text: address.substring(start),
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
      break;
    }

    // Add non-matching text before match
    if (index > start) {
      result.add(
        TextSpan(
          text: address.substring(start, index),
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }

    // Add matched text
    result.add(
      TextSpan(
        text: address.substring(index, index + searchText.length),
        style: TextStyle(
          color: highlightColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    start = index + searchText.length;
  }

  return result;
}

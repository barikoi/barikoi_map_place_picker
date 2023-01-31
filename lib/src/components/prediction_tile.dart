import 'package:barikoi_api/barikoi_api.dart';
import 'package:flutter/material.dart';

class PredictionTile extends StatelessWidget {
  final Place prediction;
  final ValueChanged<Place>? onTap;

  PredictionTile({required this.prediction, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.location_on),
      title: RichText(
        text: TextSpan(
          children: _buildPredictionText(context),
        ),
      ),
      onTap: () {
        if (onTap != null) {
          onTap!(prediction);
        }
      },
    );
  }

  List<TextSpan> _buildPredictionText(BuildContext context) {
    final List<TextSpan> result = <TextSpan>[];
    final textColor = Theme.of(context).textTheme.titleLarge!.color;

    result.add(
      TextSpan(
        text: prediction.address,
        style: TextStyle(
            color: textColor, fontSize: 16, fontWeight: FontWeight.w300),
      ),
    );

    return result;
  }
}

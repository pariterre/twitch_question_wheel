import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// The Color Picker with HUE Ring & HSV model.
class CustomHueRingPicker extends StatefulWidget {
  const CustomHueRingPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
    this.portraitOnly = false,
    this.colorPickerHeight = 250.0,
    this.hueRingStrokeWidth = 20.0,
    this.enableAlpha = false,
    this.displayThumbColor = true,
    this.pickerAreaBorderRadius = const BorderRadius.all(Radius.zero),
  });

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final bool portraitOnly;
  final double colorPickerHeight;
  final double hueRingStrokeWidth;
  final bool enableAlpha;
  final bool displayThumbColor;
  final BorderRadius pickerAreaBorderRadius;

  @override
  State<CustomHueRingPicker> createState() => _CustomHueRingPickerState();
}

class _CustomHueRingPickerState extends State<CustomHueRingPicker> {
  HSVColor currentHsvColor = const HSVColor.fromAHSV(0.0, 0.0, 0.0, 0.0);

  @override
  void initState() {
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
    super.initState();
  }

  @override
  void didUpdateWidget(CustomHueRingPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
  }

  void onColorChanging(HSVColor color) {
    setState(() => currentHsvColor = color);
    widget.onColorChanged(currentHsvColor.toColor());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: widget.pickerAreaBorderRadius,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  SizedBox(
                    width: widget.colorPickerHeight,
                    height: widget.colorPickerHeight,
                    child: ColorPickerHueRing(
                      currentHsvColor,
                      onColorChanging,
                      displayThumbColor: widget.displayThumbColor,
                      strokeWidth: widget.hueRingStrokeWidth,
                    ),
                  ),
                  SizedBox(
                    width: widget.colorPickerHeight / 1.6,
                    height: widget.colorPickerHeight / 1.6,
                    child: ColorPickerArea(
                        currentHsvColor, onColorChanging, PaletteType.hsv),
                  )
                ]),
          ),
        ),
        if (widget.enableAlpha)
          SizedBox(
            height: 40.0,
            width: widget.colorPickerHeight,
            child: ColorPickerSlider(
              TrackType.alpha,
              currentHsvColor,
              onColorChanging,
              displayThumbColor: widget.displayThumbColor,
            ),
          ),
      ],
    );
  }
}

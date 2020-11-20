// import 'package:flutter/material.dart';
//
// typedef AlbumArtSliderSizeProvider = double Function(
//     BuildContext context, int index, double centerDistance);
//
// typedef AlbumArtSliderWidgetBuilder = Widget Function(
//     BuildContext context, int index, double centerDistance);
//
// class AlbumArtSlider extends StatefulWidget {
//   /// The number of children.
//   final int itemCount;
//
//   /// Provides the size of the widget at the requested index.
//   ///
//   /// Used in snapping calculations.
//   final AlbumArtSliderSizeProvider sizeProvider;
//
//   /// The builder used to build children.
//   final AlbumArtSliderWidgetBuilder itemBuilder;
//
//   /// The animation curve to use for translations.
//   final Curve animationCurve;
//
//   /// The duration of translation animations.
//   final Duration animationDuration;
//
//   const AlbumArtSlider({
//     Key? key,
//     required this.itemCount,
//     required this.sizeProvider,
//     required this.itemBuilder,
//     this.animationCurve = Curves.linear,
//     this.animationDuration = const Duration(milliseconds: 200),
//   }) : super(key: key);
//
//   @override
//   _AlbumArtSliderState createState() => _AlbumArtSliderState();
// }
//
// class _AlbumArtSliderState extends State<AlbumArtSlider> {
//   final _controller = ScrollController();
//
//   double _calculateDistanceToCenter(double centerOffset) =>
//       _controller.offset - centerOffset;
//
//   double _calculateIndexOffset(BuildContext context, int index) {
//     if (index == 0) return widget.sizeProvider(context, 0, 0) / 2;
//
//     // Calculate all the offsets of the end of each child.
//     final endOffsets = List<double?>.filled(index + 1, null, growable: false);
//     endOffsets[0] = widget.sizeProvider(context, 0, 0);
//     for (var i = 1; i <= index; ++i) {
//       endOffsets[i] = endOffsets[i - 1]! +
//           widget.sizeProvider(context, i, _calculateDistanceToCenter(en));
//     }
//
//     // Calculate the offset of the middle of the last child.
//     return (endOffsets[index]! + endOffsets[index - 1]!) / 2;
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return NotificationListener(
//       onNotification: (scrollInfo) {
//         return false;
//       },
//       child: ListView.builder(
//         controller: _controller,
//         scrollDirection: Axis.horizontal,
//         itemCount: widget.itemCount,
//         itemBuilder: (context, index) {
//           return widget.itemBuilder(
//             context,
//             index,
//             _calculateIndexOffset(context, index),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:epimetheus/features/playback/entities/queue_display_item.dart';
import 'package:flutter/material.dart';

class QueueCarousel extends StatelessWidget {
  /// Use [Curves.easeInOut] as the transition curve to match [CarouselSlider].
  static const transitionCurve = Curves.easeInOut;

  /// The [CarouselController]. Can be used to manipulate the carousel
  /// programmatically.
  final CarouselController? carouselController;

  /// The queue to use.
  final List<QueueDisplayItem> queue;

  /// The height of the images shown.
  final double imageHeight;

  /// The initial index to display.
  final int initialIndex;

  /// The selected index in the carousel. Shown in the center.
  final int selectedIndex;

  /// The progress of a page change.
  /// 0 if no change is in progress.
  /// > -0.5, < 0 if changing to the page to the left.
  /// > 0, < 0.5 if changing to the page to the right.
  final double changeFraction;

  /// Called when the selected page changes.
  final ValueChanged<int> onIndexSelected;

  /// Called when the progress of a page change changes.
  final ValueChanged<double> onChangeFractionUpdated;

  const QueueCarousel({
    Key? key,
    this.carouselController,
    required this.queue,
    required this.imageHeight,
    required this.initialIndex,
    required this.selectedIndex,
    required this.changeFraction,
    required this.onIndexSelected,
    required this.onChangeFractionUpdated,
  }) : super(key: key);

  // TODO [selectedIndex] can sometimes update after [changeFraction] changes
  // its sign, resulting in a frame where the wrong side of the selected index
  // is eleveated.
  /// Calculates an elevation value based on the given index and
  /// [_changeFraction].
  ///
  /// [index] is the index of the widget that the elevation's being applied to.
  /// [baseElevation] is the minimum elevation, applied to all indexes.
  /// [variableElevation] is multiplied by the progress of the change and added
  /// to the [baseElevation] on the appropriate indexes.
  /// [curve] defines the [Curve] used to transform the change progress.
  double _calculateElevation({
    required int index,
    required double baseElevation,
    required double variableElevation,
    required Curve curve,
  }) {
    if (index == selectedIndex) {
      return baseElevation +
          variableElevation * curve.transform(1 - (changeFraction.abs() / 2));
    }
    if (index == selectedIndex + 1 && changeFraction > 0) {
      return baseElevation +
          variableElevation * curve.transform(changeFraction / 2);
    }
    if (index == selectedIndex - 1 && changeFraction < 0) {
      return baseElevation +
          variableElevation * curve.transform(-changeFraction / 2);
    }
    return baseElevation;
  }

  Widget _buildImagePlaceholder() {
    return Image.asset(
      'assets/music_note.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    // return queue[selectedIndex].artUri == null
    //     ? _buildImagePlaceholder()
    //     : Material(
    //         elevation: _calculateElevation(
    //           index: selectedIndex,
    //           baseElevation: 3,
    //           variableElevation: 5,
    //           curve: QueueCarousel.transitionCurve,
    //         ),
    //         animationDuration: Duration.zero,
    //         color: Colors.transparent,
    //         child: CachedNetworkImage(
    //           imageUrl: queue[selectedIndex].artUri,
    //           placeholder: (context, url) => _buildImagePlaceholder(),
    //           width: imageSize,
    //           height: imageSize,
    //         ),
    //       );
    return CarouselSlider.builder(
      carouselController: carouselController,
      options: CarouselOptions(
        initialPage: initialIndex,
        height: imageHeight,
        viewportFraction: 0.7,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
        onPageChanged: (index, reason) => onIndexSelected(index),
        onScrolled: (position) {
          final truncatedPosition = position.truncate();
          var newChangeFraction = 2 *
              (truncatedPosition < selectedIndex
                  ? (position - truncatedPosition) - 1
                  : (position - truncatedPosition));
          if (newChangeFraction > 1) {
            newChangeFraction = 1;
          } else if (newChangeFraction < -1) {
            newChangeFraction = -1;
          }
          onChangeFractionUpdated(newChangeFraction);
        },
      ),
      itemCount: queue.length,
      itemBuilder: (context, index) {
        final String? imageUrl = queue[index].mediaItem.artUri;
        return Material(
          elevation: _calculateElevation(
            index: index,
            baseElevation: 3,
            variableElevation: 5,
            curve: QueueCarousel.transitionCurve,
          ),
          animationDuration: Duration.zero,
          color: Colors.transparent,
          child: imageUrl == null
              ? _buildImagePlaceholder()
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => _buildImagePlaceholder(),
                ),
        );
      },
    );
  }
}

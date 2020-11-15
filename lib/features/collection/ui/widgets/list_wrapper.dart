import 'package:epimetheus/features/collection/ui/widgets/progress_indicator.dart';
import 'package:epimetheus/features/collection/ui/widgets/refresh_message.dart';
import 'package:flutter/material.dart';

/// This widget wraps collection lists, displaying any errors or notices that
/// should be displayed.
class TabListWrapper extends StatelessWidget {
  final String typeName;
  final bool hasError;
  final String? errorMessage;
  final bool showProgressIndicator;
  final bool hasData;
  final bool isEmpty;
  final RefreshCallback onRefresh;
  final Widget child;

  const TabListWrapper({
    Key? key,
    required this.typeName,
    required this.hasError,
    required this.errorMessage,
    required this.showProgressIndicator,
    required this.hasData,
    required this.isEmpty,
    required this.onRefresh,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return TabRefreshMessage(
        message: errorMessage ?? 'An unknown error has occurred.',
        onRefresh: onRefresh,
      );
    }

    if (showProgressIndicator) {
      return const TabProgressIndicator();
    }

    if (!hasData) {
      return TabRefreshMessage(
        message: 'No ${typeName}s are loaded!',
        onRefresh: onRefresh,
      );
    }

    if (isEmpty) {
      return TabRefreshMessage(
        message: 'You don\'t have any ${typeName}s!',
        onRefresh: onRefresh,
      );
    }

    return child;
  }
}

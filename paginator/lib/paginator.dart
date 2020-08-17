library paginator;

import 'package:async/async.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, int index, T item);
typedef PageProvider<T> = Future<List<T>> Function(int index);
typedef ErrorHandler = bool Function(dynamic error);

class Paginator<T> extends StatefulWidget {
  final List<T> initialData;
  final PageProvider pageProvider;
  final ItemBuilder<T> itemBuilder;
  final WidgetBuilder loadingIndicator;
  final ErrorHandler onError;

  final Axis scrollDirection;
  final bool reverse;
  final ScrollController controller;
  final bool primary;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final EdgeInsets padding;
  final double itemExtent;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double cacheExtent;
  final int semanticChildCount;
  final DragStartBehavior dragStartBehavior;

  Paginator({
    Key key,
    this.initialData,
    @required this.pageProvider,
    @required this.itemBuilder,
    this.loadingIndicator,
    this.onError,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : super(key: key);

  @override
  PaginatorState<T> createState() => PaginatorState<T>._internal(initialData?.toList() ?? <T>[]);
}

class PaginatorState<T> extends State<Paginator> with AutomaticKeepAliveClientMixin {
  List<T> _data;
  bool _loading = false;
  bool _completed = false;

  final _pendingRequests = <CancelableOperation<List<T>>>[];

  PaginatorState._internal(this._data);

  @override
  bool get wantKeepAlive => _data.length > (widget.initialData?.length ?? 0) || _completed;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding != null
          ? EdgeInsets.only(
              top: widget.padding.top,
              left: widget.padding.left,
              right: widget.padding.right,
            )
          : null,
      itemExtent: widget.itemExtent,
      itemBuilder: (context, index) {
        if (index < _data.length) return widget.itemBuilder(context, index, _data[index]);
        if (index == _data.length && !_completed) {
          if (!_loading) _nextPage();
          return widget.loadingIndicator?.call(context) ??
              const Align(
                alignment: Alignment.center,
                child: const Padding(
                  padding: const EdgeInsets.all(16),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
        }
        return null;
      },
    );
  }

  void _nextPage() {
    try {
      final request = CancelableOperation<List<T>>.fromFuture(widget.pageProvider(_data.length));
      request.value.then(
        (newPage) {
          if (newPage != null && mounted) {
            if (newPage.isEmpty) {
              setState(() {
                _completed = true;
              });
            } else {
              setState(() {
                _data.addAll(newPage);
              });
            }

            _pendingRequests.remove(request);
          }
        },
      );

      _pendingRequests.add(request);
    } catch (e) {
      if (mounted) {
        setState(() {
          _completed = !(widget?.onError?.call(e) ?? false);
        });
      }
    }
    _loading = false;
  }

  Future<void> reset() async {
    if (!mounted) return;
    _pendingRequests.forEach((request) => request.cancel());
    _pendingRequests.clear();
    _data.clear();
    _completed = false;
    _loading = false;
  }
}

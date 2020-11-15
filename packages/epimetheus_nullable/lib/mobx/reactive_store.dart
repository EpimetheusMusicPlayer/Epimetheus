import 'package:epimetheus_nullable/mobx/disposable_store.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

/// An abstract class to provide functionality for internal reactions in a
/// store.
///
/// Implementations should implement [initReactions].
///
/// When a [ReactiveStore] is used, [init] and [dispose] should be called when
/// appropriate.
abstract class ReactiveStore implements DisposableStore {
  List<ReactionDisposer> _reactionDisposers;

  /// Initialises the reactions. Returns a list of [ReactionDisposer]s, to be
  /// disposed in [dispose].
  @protected
  List<ReactionDisposer> initReactions();

  /// This function must be called to start up the reactions.
  @mustCallSuper
  @override
  void init() {
    assert(_reactionDisposers == null, 'init() has already been called!');
    _reactionDisposers = initReactions();
  }

  /// This function must be called to stop the reactions.
  @mustCallSuper
  @override
  void dispose() {
    assert(_reactionDisposers != null, 'init() has not been called yet!');
    for (final disposer in _reactionDisposers) {
      disposer();
    }
  }
}

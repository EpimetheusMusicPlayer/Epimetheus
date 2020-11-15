/// If a Store implements this, it's [init] and [dispose] should be called when
/// appropriate.
abstract class DisposableStore {
  /// Initialises the store. Call after constructing.
  void init();

  /// Disposes the store. Call when the store is no longer needed.
  void dispose();
}

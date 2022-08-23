// Despite being part of the delta document the markers can be hidden on demand.
// Toggling markers from the editor controller can be useful for situations where the developers want 
// to clear the text of any visual guides and show the pure rich text.
class MarkersVisibilityState {
  bool _visibility = true;

  bool get visibility => _visibility;

  void toggleMarkers(bool areVisible) {
    _visibility = areVisible;
  }
}

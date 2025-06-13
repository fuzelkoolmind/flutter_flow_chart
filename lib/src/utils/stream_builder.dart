import 'package:rxdart/rxdart.dart';

class StreamBuilderUtils {
  static BehaviorSubject<bool> isDragging = BehaviorSubject<bool>.seeded(false);
  static BehaviorSubject<bool> isClickElement = BehaviorSubject<bool>.seeded(false);
}

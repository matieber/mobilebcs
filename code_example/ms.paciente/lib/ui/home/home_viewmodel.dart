import 'package:stacked/stacked.dart';

class HomeViewModel extends IndexTrackingViewModel {
  HomeViewModel(int? focusedTab){
    if (focusedTab != null)
      this.setIndex(focusedTab);
  }
}

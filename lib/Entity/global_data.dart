import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/userdetail.dart';

class GlobalData {
  /// CART ITEMS OF ORDER
  static List<CartItem> _cartItemList = [];

  // Getter
  static List<CartItem> get cartItemList => _cartItemList;

  // Setter
  static set cartItemList(List<CartItem> value) {
    _cartItemList = value;
  }

  // userDetail
  static UserDetail _userDetail = UserDetail(
    uid: '',
    username: '',
    email: '',
    photoURL: 'assets/images/drink/user.png',
    rank: 'Hạng đồng',
    point: 0,
    role: 'user',
  );


  // Getter
  static UserDetail get userDetail => _userDetail;

  // Setter
  static set userDetail(UserDetail value) {
    _userDetail = value;
  }
}

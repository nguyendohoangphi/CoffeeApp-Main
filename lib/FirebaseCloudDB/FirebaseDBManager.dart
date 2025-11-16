import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/FirebaseCloudDB/adsservice.dart';
import 'package:coffeeapp/FirebaseCloudDB/authservice.dart';
import 'package:coffeeapp/FirebaseCloudDB/cartservice.dart';
import 'package:coffeeapp/FirebaseCloudDB/categoryproductservice.dart';
import 'package:coffeeapp/FirebaseCloudDB/couponservice.dart';
import 'package:coffeeapp/FirebaseCloudDB/favouriteservice.dart';
import 'package:coffeeapp/FirebaseCloudDB/orderservice.dart';
import 'package:coffeeapp/FirebaseCloudDB/productservice%20.dart';
import 'package:coffeeapp/FirebaseCloudDB/tablestatusservice.dart';

class FirebaseDBManager {
  static final AdsService adsService = AdsService();
  static final CategoryProductService categoryProductService =
      CategoryProductService();
  static final ProductService productService = ProductService();
  static final CartService cartService = CartService();
  static final OrderService orderService = OrderService();
  static final TableStatusService tableStatusService = TableStatusService();
  static final FavouriteService favouriteService = FavouriteService();
  static final AuthService authService = AuthService();
  static final CouponService couponService = CouponService();

  Future<bool> collectionExists(String collectionPath) async {
    final collectionRef = FirebaseFirestore.instance.collection(collectionPath);

    final querySnapshot = await collectionRef.limit(1).get();

    // If size is 0, collection doesn't exist (or has no documents)
    return querySnapshot.size > 0;
  }
}

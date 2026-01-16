// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeapp/services/ads_service.dart';
import 'package:coffeeapp/services/auth_service.dart';
import 'package:coffeeapp/services/cart_service.dart';
import 'package:coffeeapp/services/category_product_service.dart';
import 'package:coffeeapp/services/coupon_service.dart';
import 'package:coffeeapp/services/favourite_service.dart';
import 'package:coffeeapp/services/order_service.dart';
import 'package:coffeeapp/services/product_service.dart';
import 'package:coffeeapp/services/revenue_service.dart';
import 'package:coffeeapp/services/table_status_service.dart';

class FirebaseDBManager {
  static final AdsService adsService = AdsService();
  static final CategoryProductService categoryProductService = CategoryProductService();
  static final ProductService productService = ProductService();
  static final CartService cartService = CartService();
  static final OrderService orderService = OrderService();
  static final TableStatusService tableStatusService = TableStatusService();
  static final FavouriteService favouriteService = FavouriteService();
  static final AuthService authService = AuthService();
  static final CouponService couponService = CouponService();
  static final RevenueService revenueService = RevenueService();

  Future<bool> collectionExists(String collectionPath) async {
    final collectionRef = FirebaseFirestore.instance.collection(collectionPath);

    final querySnapshot = await collectionRef.limit(1).get();

    // If size is 0, collection doesn't exist (or has no documents)
    return querySnapshot.size > 0;
  }
}

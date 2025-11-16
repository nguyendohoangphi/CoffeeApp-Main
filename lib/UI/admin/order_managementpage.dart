import 'dart:ui';

import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:coffeeapp/UI/admin/orderdetail.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/Entity/orderitem.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  late List<OrderItem> orders = [];
  late Future<void> _loadDataFuture;

  Future<void> LoadData() async {
    orders = await FirebaseDBManager.orderService.getAllOrders();

    for (OrderItem orderItem in orders) {
      orderItem.cartItems = await FirebaseDBManager.cartService
          .getCartItemsByOrder(orderItem.id);
    }
  }

  Future<void> deleteOrder(String id) async {
    setState(() {
      orders.removeWhere((o) => o.id == id);
    });
    await FirebaseDBManager.orderService.deleteOrder(id);
  }

  Future<void> showOrderDetail(OrderItem order) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailPage(
          order: order,
          onStatusUpdated: (newStatus) {
            setState(() {
              order.statusOrder = newStatus;
            });
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDataFuture = LoadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý đơn hàng")),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, asyncSnapshot) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
            ),
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (_, index) {
                final order = orders[index];
                return Dismissible(
                  key: Key(order.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => deleteOrder(order.id),
                  child: ListTile(
                    title: Text(order.name),
                    subtitle: Text(
                      "Bàn ${order.table} - ${enumToString(order.statusOrder)}",
                    ),
                    trailing: Text(order.total),
                    onTap: () => showOrderDetail(order),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

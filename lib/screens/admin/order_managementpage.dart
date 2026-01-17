import 'dart:ui';
import 'package:coffeeapp/services/firebase_db_manager.dart';
import 'package:coffeeapp/screens/admin/orderdetail.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/models/orderitem.dart';
import 'package:intl/intl.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  late List<OrderItem> orders = [];
  late List<OrderItem> filteredOrders = [];
  late Future<void> _loadDataFuture;
  final TextEditingController _searchController = TextEditingController();

  Future<void> LoadData() async {
    orders = await FirebaseDBManager.orderService.getAllOrders();
    // Sort by date desc
    orders.sort((a, b) => b.createDate.compareTo(a.createDate));
    
    // Enrich with cart items
    for (OrderItem orderItem in orders) {
      orderItem.cartItems = await FirebaseDBManager.cartService.getCartItemsByOrder(orderItem.id);
    }
    filteredOrders = orders;
  }

  Future<void> deleteOrder(String id) async {
    bool confirm = await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa đơn hàng này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      )
    ) ?? false;

    if (confirm) {
      await FirebaseDBManager.orderService.deleteOrder(id);
      setState(() {
        orders.removeWhere((o) => o.id == id);
        _filterOrders(_searchController.text);
      });
    }
  }

  void _filterOrders(String query) {
    setState(() {
      filteredOrders = orders.where((order) {
        return order.name.toLowerCase().contains(query.toLowerCase()) || 
               order.id.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDataFuture = LoadData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Match parent
      child: Column(
        children: [
          // Header (Search & Actions)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Danh sách đơn hàng", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm đơn hàng...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    style: const TextStyle(color: Colors.black87),
                    onChanged: _filterOrders,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: FutureBuilder(
              future: _loadDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                   return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (orders.isEmpty) {
                   return const Center(child: Text("Chưa có đơn hàng nào"));
                }

                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                        columns: const [
                          DataColumn(label: Text("Thời gian", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Khách hàng", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Bàn", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Tổng tiền", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Trạng thái", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Hành động", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filteredOrders.map((order) {
                          return DataRow(
                            cells: [
                              DataCell(Text(order.timeOrder)),
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(order.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(order.phone, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                ],
                              )),
                              DataCell(Text(order.table)),
                              DataCell(Text(
                                "${NumberFormat("#,###", "vi_VN").format(double.tryParse(order.total) ?? double.tryParse(order.total.replaceAll(RegExp(r'[^\d]'), '')) ?? 0)} đ",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              )),
                              DataCell(_buildStatusBadge(order.statusOrder)),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility_outlined, color: Colors.blue),
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailPage(order: order, onStatusUpdated: (s) => setState(() => order.statusOrder = s)))),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => deleteOrder(order.id),
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(StatusOrder status) {
    Color color;
    String text;
    switch (status) {
      case StatusOrder.Waiting:
        color = Colors.orange;
        text = "Order Chờ";
        break;
      case StatusOrder.Processing:
        color = Colors.blue;
        text = "Đang pha chế";
        break;
      case StatusOrder.Shipping:
        color = Colors.purple;
        text = "Đang giao hàng";
        break;
      case StatusOrder.Finished:
        color = Colors.green;
        text = "Hoàn thành";
        break;
      default:
        color = Colors.grey;
        text = "Khác";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

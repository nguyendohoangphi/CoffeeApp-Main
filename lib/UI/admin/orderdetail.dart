import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/Entity/orderitem.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderItem order;
  final Function(StatusOrder) onStatusUpdated;

  const OrderDetailPage({
    super.key,
    required this.order,
    required this.onStatusUpdated,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late StatusOrder _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.statusOrder;
  }

  Future<void> _updateStatus(StatusOrder? newStatus) async {
    if (newStatus != null) {
      setState(() {
        _selectedStatus = newStatus;
      });
      widget.onStatusUpdated(newStatus);

      await FirebaseDBManager.orderService.updateOrderStatus(
        widget.order.id,
        newStatus,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "👤 Khách: ${order.name}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("📧 Email: ${order.email}"),
            Text("📞 SĐT: ${order.phone}"),
            Text("🪑 Bàn: ${order.table}"),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  "🚦 Trạng thái: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<StatusOrder>(
                  value: _selectedStatus,
                  onChanged: _updateStatus,
                  items: StatusOrder.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(enumToString(status)),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "🛒 Sản phẩm trong đơn:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: order.cartItems.length,
                itemBuilder: (context, index) {
                  final item = order.cartItems[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_cafe),
                      title: Text(item.productName),
                      subtitle: Text(
                        "Số lượng: ${item.amount} - Size: ${enumToString(item.size)}",
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Text(
              "💰 Tổng tiền: ${order.total}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "🎟 Mã giảm giá: ${order.coupon.isEmpty ? 'Không' : order.coupon}",
            ),
          ],
        ),
      ),
    );
  }
}

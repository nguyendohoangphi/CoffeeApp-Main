import 'package:flutter/material.dart';
import 'package:coffeeapp/constants/app_colors.dart';
import 'package:coffeeapp/models/global_data.dart';

class HomeHeader extends StatelessWidget {
  final bool isDark;

  const HomeHeader({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Xác định màu chữ dựa trên theme
    final Color textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final Color subTextColor = isDark ? AppColors.textSubDark : AppColors.textSubLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Xin chào,",
                style: TextStyle(fontSize: 14, color: subTextColor),
              ),
              const SizedBox(height: 4),
              Text(
                GlobalData.userDetail.username.isNotEmpty
                    ? GlobalData.userDetail.username
                    : "Khách hàng",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  GlobalData.userDetail.rank,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.primaryDark : AppColors.primary, 
                width: 2
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppColors.primaryDark : AppColors.primary).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundImage: AssetImage(GlobalData.userDetail.photoURL),
              backgroundColor: Colors.grey[200],
            ),
          )
        ],
      ),
    );
  }
}

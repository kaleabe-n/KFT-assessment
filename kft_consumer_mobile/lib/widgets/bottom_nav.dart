import 'package:flutter/material.dart';
import 'package:kft_consumer_mobile/lib.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomBarPages = [
      const HomePage(),
      const ProductsPage(),
      const TransactionsPage(),
      const ProfilePage(),
    ];
    final List<PreferredSizeWidget?> appBars = [
      getAppBar(
        title: "Home",
        iconData: Icons.home,
      ),
      getAppBar(
        title: "Products",
        iconData: Icons.storefront_outlined,
      ),
      getAppBar(
        iconData: Icons.receipt_long_outlined,
        title: 'Transactions',
      ),
      null
    ];

    return Scaffold(
        appBar: appBars[currIndex],
        body: bottomBarPages[currIndex],
        bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: AppColors.primary,
            currentIndex: currIndex,
            onTap: (index) {
              setState(() {
                currIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.electric_meter_outlined,
                  color: AppColors.primary,
                ),
                activeIcon: Icon(
                  Icons.electric_meter,
                  color: AppColors.primary,
                ),
                label: "Utilities",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.storefront_outlined,
                  color: AppColors.primary,
                ),
                activeIcon: Icon(
                  Icons.storefront,
                  color: AppColors.primary,
                ),
                label: "Products",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.receipt_outlined,
                  color: AppColors.primary,
                ),
                activeIcon: Icon(
                  Icons.receipt,
                  color: AppColors.primary,
                ),
                label: "Transactions",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
                activeIcon: Icon(
                  Icons.person,
                  color: AppColors.primary,
                ),
                label: "Profile",
              ),
            ]));
  }
}

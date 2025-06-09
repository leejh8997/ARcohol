import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF1F1F1F),
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text('ARcohol', style: TextStyle(color: Color(0xFFFCD19C))),
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.shopping_cart)),
        IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
        IconButton(onPressed: () {}, icon: Icon(Icons.account_circle)),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black87,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.black54),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("환영합니다", style: TextStyle(color: Colors.white)),
                TextButton(onPressed: () {}, child: Text("로그인 / 로그아웃", style: TextStyle(color: Colors.orange)))
              ],
            ),
          ),
          ListTile(title: Text('마이페이지', style: TextStyle(color: Colors.white)), onTap: () {}),
          ListTile(title: Text('AR제조법', style: TextStyle(color: Colors.white)), onTap: () {}),
          ListTile(title: Text('장바구니', style: TextStyle(color: Colors.white)), onTap: () {}),
          ListTile(title: Text('판매', style: TextStyle(color: Colors.white)), onTap: () {}),
          ListTile(title: Text('레시피', style: TextStyle(color: Colors.white)), onTap: () {}),
          ListTile(title: Text('마이바', style: TextStyle(color: Colors.white)), onTap: () {}),
        ],
      ),
    );
  }
}
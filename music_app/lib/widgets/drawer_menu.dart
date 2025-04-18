import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/loginstate_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginStateProvider>(context);

    return Drawer(
      backgroundColor: AppColors.backgroundSecondary,
      child: Column(
        children: [
          const DrawerHeader(
            child: Column(
              children: [
                CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
                SizedBox(height: 8),
                Text("User Name", style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          _buildDrawerItem(Icons.settings, "Settings"),
          _buildDrawerItem(Icons.history, "Recent"),
          _buildDrawerItem(Icons.new_releases, "What's new"),
          const Spacer(),
          ListTile(
            tileColor: AppColors.primary,
            leading: Icon(Icons.logout, color: AppColors.background),
            title: Text("Log out", style: TextStyle(color: AppColors.background)),
            onTap: () {
              Navigator.pop(context);
              loginState.user.isLoggedIn = false;
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/loginPage",
                    (route) => false,
                );
              },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {},
    );
  }
}
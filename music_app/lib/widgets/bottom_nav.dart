import 'package:flutter/material.dart';
import 'package:music_app/core/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const CustomBottomNavBar({
    super.key,
    required this.context,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => onNavItemTapped(context, currentIndex, index),
      backgroundColor: AppColors.backgroundSecondary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Playing"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: "Playlists",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.alternate_email), label: "Contact"),
      ],
      selectedItemColor: AppColors.textPrimary,
      unselectedItemColor: Colors.grey,
    );
  }

  void onNavItemTapped(BuildContext context, int selectedIndex, int index) {
    if (index == selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, "/playingPage");
        break;
      case 1:
        Navigator.pushReplacementNamed(context, "/searchPage");
        break;
      case 2:
        Navigator.pushReplacementNamed(context, "/playlistsPage");
        break;
      case 3:
        Navigator.pushReplacementNamed(context, "/contactPage");
        break;
    }
  }
}

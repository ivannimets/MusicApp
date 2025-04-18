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
      //Sets the current index to be highlighted
      currentIndex: currentIndex,
      //Calls the on NavItemTapped method
      onTap: (index) => onNavItemTapped(context, currentIndex, index),
      backgroundColor: AppColors.backgroundSecondary,
      items: const [
        //Creates all the clickable items for each screen
        BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Playing"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: "Playlists",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.alternate_email), label: "Contact"),
      ],
      //Sets the display colors for selected and unselected items
      selectedItemColor: AppColors.textPrimary,
      unselectedItemColor: Colors.grey,
    );
  }

  //Method that handles when the user clicks a navigation bar item
  void onNavItemTapped(BuildContext context, int selectedIndex, int index) {
    //Ensures that the index has changed
    if (index == selectedIndex) return;

    switch (index) {
      //Handles Case 0 (PlayingPage), then breaks from the switch
      case 0:
        Navigator.pushReplacementNamed(context, "/playingPage");
        break;
    //Handles Case 1 (SearchPage), then breaks from the switch
      case 1:
        Navigator.pushReplacementNamed(context, "/searchPage");
        break;
    //Handles Case 2 (PlaylistPage), then breaks from the switch
      case 2:
        Navigator.pushReplacementNamed(context, "/playlistsPage");
        break;
    //Handles Case 3 (ContactPage), then breaks from the switch
      case 3:
        Navigator.pushReplacementNamed(context, "/contactPage");
        break;
    }
  }
}

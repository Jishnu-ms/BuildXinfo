import 'package:buildxinfo/User/Pages/UserCostEstimationPage.dart';
import 'package:buildxinfo/User/Pages/UserDashboardPage.dart';
import 'package:buildxinfo/User/Pages/UserMyProjectsPage%20.dart';
import 'package:buildxinfo/Widgets/CustomSidebarButton.dart';
import 'package:buildxinfo/Widgets/SideNavItem.dart';
import 'package:buildxinfo/Widgets/TopNavBar.dart';
import 'package:flutter/material.dart';

class UserNavbar extends StatelessWidget {
  const UserNavbar({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF1F4FB),
        fontFamily: 'sans-serif',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Userdashboardpage(),
    const UserMyProjectsPage(),
    const UserCostEstimationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(
        title: "User Dashboard",
        notificationCount: "5",
        profileImageUrl: "your_image_url_here",
      ),
      body: Row(
        children: [
          // --- SIDE NAVBAR ---
          Container(
            width: 260,

            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Exact Icons matching the user_home.jpg sidebar
                SideNavItem(
                  icon: Icons.assessment_rounded, // Dashboard icon
                  title: "Dashboard",
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                SideNavItem(
                  icon: Icons.folder_outlined, // My Projects icon
                  title: "My Projects",
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                SideNavItem(
                  icon: Icons.help_outline_rounded, // Cost Estimation icon
                  title: "Cost Estimation",
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),

                const Spacer(),
                // --- LOGOUT BUTTON ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomSidebarButton(
                    text: "Logout",
                    icon: Icons.logout_rounded,
                    color: Colors.red,
                    borderColor: Colors.black26,
                    onTap: () {
                      // Add your logout logic here
                      print("User logged out");
                    },
                  ),
                ),
              ],
            ),
          ),
          // --- MAIN CONTENT ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 25, top: 25, bottom: 25),
              child: IndexedStack(index: _currentIndex, children: _pages),
            ),
          ),
        ],
      ),
    );
  }
}

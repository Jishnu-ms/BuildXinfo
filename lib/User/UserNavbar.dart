import 'package:buildxinfo/LoginPage.dart';
import 'package:buildxinfo/User/Pages/UserCostEstimationPage.dart';
import 'package:buildxinfo/User/Pages/UserDashboardPage.dart';
import 'package:buildxinfo/User/Pages/UserMyProjectsPage%20.dart';
import 'package:buildxinfo/Widgets/CustomSidebarButton.dart';
import 'package:buildxinfo/Widgets/SideNavItem.dart';
import 'package:buildxinfo/Widgets/TopNavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final List<Widget> _pages = const [
    Userdashboardpage(),
    Usermyprojectspage(),
    UserCostEstimationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          appBar: isMobile
              ? AppBar(
                  title: const Text("User Dashboard"),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 1,
                )
              : TopNavBar(
                  title: "User Dashboard",
                  notificationCount: "5",
                  profileImageUrl: "your_image_url_here",
                ),
          drawer: isMobile ? _buildDrawer(context) : null,
          body: Row(
            children: [
              if (!isMobile) _buildSidebar(context),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 25),
                  child: IndexedStack(index: _currentIndex, children: _pages),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _confirmAndLogout(BuildContext context,
    {bool closeDrawer = false}) async {
  if (closeDrawer) {
    Navigator.of(context).pop(); // close drawer
    await Future.delayed(const Duration(milliseconds: 250));
  }

  final shouldLogout = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () =>
                Navigator.of(dialogContext).pop(true),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  if (shouldLogout == true) {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context, rootNavigator: true)
        .pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}


  /* ===================== SIDEBAR ===================== */

  Widget _buildSidebar(BuildContext context) {
    return Container(
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
          SideNavItem(
            icon: Icons.assessment_rounded,
            title: "Dashboard",
            isSelected: _currentIndex == 0,
            onTap: () => setState(() => _currentIndex = 0),
          ),
          SideNavItem(
            icon: Icons.folder_outlined,
            title: "My Projects",
            isSelected: _currentIndex == 1,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          SideNavItem(
            icon: Icons.help_outline_rounded,
            title: "Cost Estimation",
            isSelected: _currentIndex == 2,
            onTap: () => setState(() => _currentIndex = 2),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomSidebarButton(
              text: "Logout",
              icon: Icons.logout_rounded,
              color: Colors.red,
              borderColor: Colors.black26,
              onTap: () => _confirmAndLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  /* ===================== DRAWER (MOBILE) ===================== */

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            SideNavItem(
              icon: Icons.assessment_rounded,
              title: "Dashboard",
              isSelected: _currentIndex == 0,
              onTap: () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context);
              },
            ),
            SideNavItem(
              icon: Icons.folder_outlined,
              title: "My Projects",
              isSelected: _currentIndex == 1,
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context);
              },
            ),
            SideNavItem(
              icon: Icons.help_outline_rounded,
              title: "Cost Estimation",
              isSelected: _currentIndex == 2,
              onTap: () {
                setState(() => _currentIndex = 2);
                Navigator.pop(context);
              },
            ),
            const Spacer(),
          Padding(
  padding: const EdgeInsets.all(16),
  child: CustomSidebarButton(
    text: "Logout",
    icon: Icons.logout_rounded,
    color: Colors.red,
    borderColor: Colors.black26,
   onTap: () => _confirmAndLogout(context),

  ),
)

          ],
        ),
      ),
    );
  }
}

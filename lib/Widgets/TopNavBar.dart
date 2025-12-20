import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String logoText;
  final IconData logoIcon;
  final Color logoColor;
  final String profileImageUrl;
  final String notificationCount;
  final List<Color> gradientColors;

  const TopNavBar({
    super.key,
    this.title = "BuildXinfo",
    this.logoText = "BuildXinfo",
    this.logoIcon = Icons.maps_home_work_rounded,
    this.logoColor = const Color(0xFFFF9800),
    this.profileImageUrl = 'https://i.imgur.com/8Km9tLL.png',
    this.notificationCount = '1',
    this.gradientColors = const [Color(0xFF1E4AD9), Color(0xFF3B67F2)],
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors, // Exact gradient from image
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 250,
        leading: Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Row(
            children: [
              Icon(
                logoIcon,
                color: logoColor, // Customizable logo color
                size: 26,
              ),
              const SizedBox(width: 12),
              Text(
                logoText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          title, // Customizable center title
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          _buildNotificationIcon(notificationCount),
          const SizedBox(width: 20),
          const Icon(Icons.settings_outlined, size: 22, color: Colors.white),
          const SizedBox(width: 20),
          const Icon(
            Icons.notifications_outlined,
            size: 22,
            color: Colors.white,
          ),
          const SizedBox(width: 20),
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              profileImageUrl,
            ), // Customizable profile
          ),
          const SizedBox(width: 25),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(String count) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Icon(
            Icons.notifications_none_rounded,
            size: 24,
            color: Colors.white,
          ),
        ),
        Positioned(
          right: 0,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red, // Matching red dot
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
            child: Text(
              count, // Passable count string
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

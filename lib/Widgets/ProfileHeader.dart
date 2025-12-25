import 'package:flutter/material.dart';

// --- 1. Data Model ---
class UserProfileData {
  final String name;
  final String role;
  final String email;
  final String imageUrl;

  UserProfileData({
    required this.name,
    required this.role,
    required this.email,
    required this.imageUrl,
  });
}

// --- 2. Full Separate Widget ---
class ProfileHeader extends StatelessWidget {
  final UserProfileData userData;

  const ProfileHeader({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Container
        Container(
          width: double.infinity,
          height: 160,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Profile Image with Border
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: NetworkImage(userData.imageUrl),
                ),
              ),
              const SizedBox(width: 24),
              // Text Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData.role,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      userData.email,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Abstract Wave Background (Top Right Decoration)
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: CustomPaint(painter: _HeaderWavePainter()),
          ),
        ),
      ],
    );
  }
}

// --- 3. Custom Painter for the background aesthetic ---
class _HeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDBEAFE).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.7, 0);
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.4,
      size.width,
      size.height * 0.3,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- 4. Usage Example ---
/*
  ProfileHeader(
    userData: UserProfileData(
      name: "Priya Mehta",
      role: "Project Manager",
      email: "priyalocation@orcail.com",
      imageUrl: "https://i.pravatar.cc/150?u=priya",
    ),
  )
*/

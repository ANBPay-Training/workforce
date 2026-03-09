import 'package:flutter/material.dart';

import '../utils/baseScaffold.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Admin Dashboard',
      body: const Center(
        child: Text(
          'Welcome Admin 👑',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

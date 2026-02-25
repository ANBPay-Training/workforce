import 'package:flutter/material.dart';

import 'logout_helper.dart';

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const BaseScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => LogoutHelper.logout(context),
          ),
        ],
      ),
      body: body,
    );
  }
}

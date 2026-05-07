import 'package:flutter/material.dart';

import 'app_platform.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: appPagePadding(context),
            sliver: SliverList.list(children: children),
          ),
        ],
      ),
    );
  }
}

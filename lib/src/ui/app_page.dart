import 'package:flutter/material.dart';

import 'app_platform.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required this.children,
    super.key,
  }) : state = null;

  const AppPage.state({
    required this.state,
    super.key,
  }) : children = const <Widget>[];

  final List<Widget> children;
  final Widget? state;

  @override
  Widget build(BuildContext context) {
    final state = this.state;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: appPagePadding(context),
            sliver: state == null
                ? SliverList.list(children: children)
                : SliverFillRemaining(
                    hasScrollBody: false,
                    child: state,
                  ),
          ),
        ],
      ),
    );
  }
}

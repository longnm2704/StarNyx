import 'package:flutter/material.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('app.title'.tr())),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.contentMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.horizontalPadding,
              vertical: AppLayout.verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppSectionTitle(
                  title: 'home.title'.tr(),
                  subtitle: 'home.subtitle'.tr(),
                ),
                const SizedBox(height: AppLayout.sectionSpacing),
                AppEmptyState(
                  title: 'home.empty_title'.tr(),
                  message: 'home.empty_message'.tr(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

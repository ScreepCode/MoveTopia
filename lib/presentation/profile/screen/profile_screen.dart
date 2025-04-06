import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/domain/repositories/profile_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../debug_settings/provider/debug_provider.dart';
import '../routes.dart';
import '../view_model/profile_view_model.dart';

final logger = Logger('ProfileScreen');

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final packageInfoFuture = useMemoized(() => PackageInfo.fromPlatform());
    final isDebugBuild = ref.watch(isDebugBuildProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navigation_profile),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: ListView(
            children: <Widget>[
              _buildActivityGoals(context, ref),
              _buildSettings(context, ref, isDebugBuild),
              _buildAboutSection(context, ref, packageInfoFuture),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityGoals(BuildContext context, WidgetRef ref) {
    final stepsGoal = ref.watch(profileProvider).stepGoal;
    TextEditingController stepsInputController =
        TextEditingController(text: stepsGoal.toString());
    FocusNode stepsFocusNode = FocusNode();
    stepsFocusNode.addListener(() {
      if (!stepsFocusNode.hasFocus) {
        final stepGoal = int.tryParse(stepsInputController.text);
        if (stepGoal != null) {
          ref.read(profileProvider.notifier).setStepGoal(stepGoal);
        } else {
          stepsInputController.text = stepsGoal.toString();
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.goal_activities_title,
                  style: Theme.of(context).textTheme.titleMedium),
              const Divider()
            ],
          ),
        ),
        TextField(
          controller: stepsInputController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.goal_steps_title,
            hintText: AppLocalizations.of(context)!.goal_steps_set_goal,
            border: const OutlineInputBorder(),
          ),
          focusNode: stepsFocusNode,
          onTapOutside: (context) {
            stepsFocusNode.unfocus();
          },
        ),
      ],
    );
  }

  Widget _buildSettings(
      BuildContext context, WidgetRef ref, AsyncValue<bool> isDebugBuild) {
    final l10n = AppLocalizations.of(context)!;
    final currentThemeMode = ref.watch(profileProvider).themeMode;
    final themeMenuKey = GlobalKey();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.navigation_app_settings,
                  style: Theme.of(context).textTheme.titleMedium),
              const Divider()
            ],
          ),
        ),

        // Theme Mode Dropdown
        ListTile(
          key: themeMenuKey,
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.palette_outlined),
          title: Text(l10n.common_theme_mode),
          subtitle: Text(_getThemeModeLabel(l10n, currentThemeMode)),
          trailing: const Icon(Icons.arrow_drop_down),
          onTap: () {
            final RenderBox itemBox =
                themeMenuKey.currentContext!.findRenderObject() as RenderBox;
            final itemPosition = itemBox.localToGlobal(Offset.zero);

            showMenu<AppThemeMode>(
              context: context,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              position: RelativeRect.fromLTRB(
                itemPosition.dx,
                itemPosition.dy + itemBox.size.height,
                itemPosition.dx + itemBox.size.width,
                itemPosition.dy,
              ),
              items: [
                PopupMenuItem<AppThemeMode>(
                  value: AppThemeMode.system,
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings_suggest_outlined,
                        color: currentThemeMode == AppThemeMode.system
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(l10n.common_theme_system),
                      if (currentThemeMode == AppThemeMode.system)
                        const Spacer()
                      else
                        const SizedBox.shrink(),
                      if (currentThemeMode == AppThemeMode.system)
                        Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary)
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
                PopupMenuItem<AppThemeMode>(
                  value: AppThemeMode.light,
                  child: Row(
                    children: [
                      Icon(
                        Icons.light_mode_outlined,
                        color: currentThemeMode == AppThemeMode.light
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(l10n.common_theme_light),
                      if (currentThemeMode == AppThemeMode.light)
                        const Spacer()
                      else
                        const SizedBox.shrink(),
                      if (currentThemeMode == AppThemeMode.light)
                        Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary)
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
                PopupMenuItem<AppThemeMode>(
                  value: AppThemeMode.dark,
                  child: Row(
                    children: [
                      Icon(
                        Icons.dark_mode_outlined,
                        color: currentThemeMode == AppThemeMode.dark
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(l10n.common_theme_dark),
                      if (currentThemeMode == AppThemeMode.dark)
                        const Spacer()
                      else
                        const SizedBox.shrink(),
                      if (currentThemeMode == AppThemeMode.dark)
                        Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary)
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ).then((value) {
              if (value != null) {
                ref.read(profileProvider.notifier).setThemeMode(value);
                logger.info('Theme mode changed to $value');
              }
            });
          },
        ),

        // App permissions
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.security),
          title: Text(l10n.permission_settings_title),
          subtitle: Text(l10n.permission_settings_subtitle),
          onTap: () {
            context.go('$profilePath/$profilePermissionsPath');
          },
        ),

        // Debug-Einstellungen Link, nur im Debug-Build zeigen
        isDebugBuild.when(
          data: (isDebug) {
            if (!isDebug) return const SizedBox.shrink();

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.bug_report, color: Colors.red),
              title: Text(
                l10n.settingsDebugTitle,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                context.go('$profilePath/$profileDebugPath');
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, WidgetRef ref,
      Future<PackageInfo> packageInfoFuture) {
    final l10n = AppLocalizations.of(context)!;
    final hiddenLogAccess = ref.watch(hiddenLogAccessProvider);
    final hiddenLogAccessNotifier = ref.watch(hiddenLogAccessProvider.notifier);

    return FutureBuilder<PackageInfo>(
      future: packageInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text(l10n.common_error_version);
        } else {
          final packageInfo = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.common_about,
                    style: Theme.of(context).textTheme.titleMedium),
                const Divider(),
                InkWell(
                  onTap: () {
                    hiddenLogAccessNotifier.incrementClickCount();
                    if (hiddenLogAccessNotifier.isLogAccessEnabled) {
                      hiddenLogAccessNotifier.resetClickCount();

                      // Vibrate as feedback
                      HapticFeedback.mediumImpact();

                      context.go('$profilePath/$profileLoggingPath');
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "${l10n.common_version}: ${packageInfo.version}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  String _getThemeModeLabel(AppLocalizations l10n, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return l10n.common_theme_system;
      case AppThemeMode.light:
        return l10n.common_theme_light;
      case AppThemeMode.dark:
        return l10n.common_theme_dark;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/domain/repositories/profile_repository.dart';

import '../../routes.dart';
import '../../view_model/profile_view_model.dart';

final logger = Logger('SettingsSection');

/// Section for settings in the profile screen
class SettingsSection extends ConsumerWidget {
  const SettingsSection({
    super.key,
    required this.ref,
    required this.isDebugBuild,
  });

  final WidgetRef ref;
  final AsyncValue<bool> isDebugBuild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        ThemeModeSelector(
          currentThemeMode: currentThemeMode,
          themeMenuKey: themeMenuKey,
          onThemeModeChanged: (mode) {
            ref.read(profileProvider.notifier).setThemeMode(mode);
            logger.info('Theme mode changed to $mode');
          },
        ),

        // App permissions
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.security),
          title: Text(l10n.permission_settings_title),
          subtitle: Text(l10n.permission_settings_subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.red),
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
}

/// Widget für die Theme-Mode-Auswahl
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({
    super.key,
    required this.currentThemeMode,
    required this.themeMenuKey,
    required this.onThemeModeChanged,
  });

  final AppThemeMode currentThemeMode;
  final GlobalKey themeMenuKey;
  final Function(AppThemeMode) onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            onThemeModeChanged(value);
          }
        });
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

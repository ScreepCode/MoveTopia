import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/health_authorized_view_model.dart';

class AuthorizationWrapper extends HookConsumerWidget {
  final Widget child;

  const AuthorizationWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(healthViewModelProvider);

    if (authState == HealthAuthViewModelState.notAuthorized) {
      return const Center(child: CircularProgressIndicator());
    } else if (authState == HealthAuthViewModelState.authorizationNotGranted ||
        authState == HealthAuthViewModelState.error) {
      return Center(
          child: Text(AppLocalizations.of(context)!.please_allow_access));
    } else if (authState == HealthAuthViewModelState.authorized) {
      return child;
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movetopia/data/repositories/badge_repository_impl.dart';
import 'package:movetopia/data/repositories/device_info_repository_impl.dart';
import 'package:movetopia/domain/repositories/badge_repository.dart';
import 'package:movetopia/domain/repositories/device_info_repository.dart';

final deviceInfoRepositoryProvider = Provider<DeviceInfoRepository>((ref) {
  return DeviceInfoRepositoryImpl();
});

final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  final deviceInfoRepository = ref.watch(deviceInfoRepositoryProvider);
  return BadgeRepositoryImpl(deviceInfoRepository);
});

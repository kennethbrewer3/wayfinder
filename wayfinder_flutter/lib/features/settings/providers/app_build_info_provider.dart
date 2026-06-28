import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_build_info.dart';

final appBuildInfoProvider = FutureProvider<AppBuildInfo>((ref) {
  return AppBuildInfo.load();
});

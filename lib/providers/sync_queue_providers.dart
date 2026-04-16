import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bilirubin/repositories/local_sync_outbox.dart';

final localSyncOutboxProvider = Provider<LocalSyncOutbox>((ref) {
  return LocalSyncOutbox();
});
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd_service/lxd_service.dart';
import 'package:lxd_store/lxd_store.dart';
import 'package:lxd_x/lxd_x.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

final instanceStore = Provider.autoDispose<InstanceStore>((ref) {
  final service = getService<LxdService>();
  final store = InstanceStore(service);
  ref.onDispose(store.dispose);
  return store;
});

final instanceStream = StreamProvider.autoDispose<List<String>>((ref) async* {
  final store = ref.watch(instanceStore);
  await store.init();
  yield* store.stream;
});

final instanceUpdated =
    StreamProvider.autoDispose.family<String, String>((ref, name) {
  final store = ref.watch(instanceStore);
  return store.onUpdated.where((instance) => instance == name);
});

final instanceState =
    FutureProvider.autoDispose.family<LxdInstance, String>((ref, name) {
  final service = getService<LxdService>();
  ref.watch(instanceUpdated(name));
  return service.getInstance(name);
});
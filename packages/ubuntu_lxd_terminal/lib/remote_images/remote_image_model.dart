import 'package:async_value/async_value.dart';
import 'package:lxd/lxd.dart';
import 'package:lxd_service/lxd_service.dart';
import 'package:meta/meta.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

// TODO:
const _kDefaultArchitecture = 'amd64';
const _kDefaultUrl = 'https://cloud-images.ubuntu.com/releases';

typedef RemoteImageList = AsyncValue<List<LxdRemoteImage>>;

class RemoteImageModel extends SafeChangeNotifier {
  RemoteImageModel(this._service);

  final LxdService _service;
  var _images = const RemoteImageList.data([]);

  RemoteImageList get images => _images;

  @protected
  set images(RemoteImageList images) {
    if (_images == images) return;
    _images = images;
    notifyListeners();
  }

  Future<void> init({
    String url = _kDefaultUrl,
    String architecture = _kDefaultArchitecture,
  }) async {
    images = const RemoteImageList.loading().copyWithPrevious(images);

    images = await RemoteImageList.guard(() async {
      final images = await _service.client.getRemoteImages(url);
      return images
          .where((image) => image.architecture == architecture)
          .fold<Map<String, LxdRemoteImage>>(
            {},
            (releases, image) => releases
              ..update(image.description, (_) => image, ifAbsent: () => image),
          )
          .values
          .toList();
    });
  }
}
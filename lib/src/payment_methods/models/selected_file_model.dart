import 'package:image_picker/image_picker.dart';

class SelectedFile {
  final String? url;
  final XFile? file;
  final bool isVideo;

  SelectedFile({
    this.url,
    this.file,
    this.isVideo = false,
  });

  bool get isEmpty => url == null && file == null;
  bool get isNotEmpty => !isEmpty;
}

class SelectedFileImage extends SelectedFile {
  SelectedFileImage({String? url, XFile? file})
      : super(url: url, file: file, isVideo: false);
}

class SelectedFileVideo extends SelectedFile {
  SelectedFileVideo({String? url, XFile? file})
      : super(url: url, file: file, isVideo: true);
}

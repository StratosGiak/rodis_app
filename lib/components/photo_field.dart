import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rodis_service/api_handler.dart';

typedef Photo = ({String? url, XFile? file});

class PhotoField extends StatefulWidget {
  PhotoField({super.key, required this.photos});

  final List<Photo> photos;
  final picker = ImagePicker();

  @override
  State<PhotoField> createState() => PhotoFieldState();
}

class PhotoFieldState extends State<PhotoField> {
  late final _photos = widget.photos;
  late final platformPhotos = _photos.map((p) => PlatformPhoto(p)).toList();

  int _index = 0;
  int get index => _index;
  set index(int value) {
    if (value < 0) {
      _index = 0;
    } else if (value > _photos.length - 1) {
      _index = _photos.length - 1;
    } else {
      _index = value;
    }
  }

  void pickGallery() async {
    final image = await widget.picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    Navigator.pop(context, image);
    if (image == null) return;
    final photo = (url: null, file: image);
    setState(() {
      _photos.add(photo);
      platformPhotos.add(PlatformPhoto(photo));
    });
  }

  void pickCamera() async {
    if (kIsWeb || !Platform.isAndroid && !Platform.isIOS) {
      Navigator.pop(context);
      return;
    }
    final image = await widget.picker.pickImage(
      source: ImageSource.camera,
      requestFullMetadata: false,
    );
    Navigator.pop(context, image);
    if (image == null) return;
    final photo = (url: null, file: image);
    setState(() {
      _photos.add(photo);
      platformPhotos.add(PlatformPhoto(photo));
      index = _photos.length - 1;
    });
  }

  void onRemovePressed(int index) {
    setState(() {
      _photos.removeAt(index);
      platformPhotos.removeAt(index);
      if (this.index > _photos.length - 1) this.index--;
    });
  }

  void addPhoto() async {
    final addedPhoto = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => PhotoPickerBottomSheet(
        onCameraTap: pickCamera,
        onGalleryTap: pickGallery,
      ),
    );
    if (addedPhoto != null) index = _photos.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final Widget mainPhoto;
    if (platformPhotos.isEmpty) {
      mainPhoto = Center(
        child: TextButton.icon(
          onPressed: addPhoto,
          label: const Text("Προσθήκη εικόνας"),
          icon: const Icon(Icons.camera_alt),
        ),
      );
    } else {
      mainPhoto = PhotoOverlay(
        onRemovePressed: () => onRemovePressed(index),
        onNextPressed:
            index >= _photos.length - 1 ? null : () => setState(() => index++),
        onPreviousPressed: index <= 0 ? null : () => setState(() => index--),
        photo: platformPhotos[index],
      );
    }

    return Column(
      children: [
        Container(
          height: 350,
          width: 500,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: mainPhoto,
        ),
        if (_photos.isNotEmpty)
          SizedBox(
            height: 65,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, index) => index < _photos.length - 1
                  ? const SizedBox(width: 4.0)
                  : const SizedBox(width: 10.0),
              itemCount: _photos.length + 1,
              itemBuilder: (context, index) => Center(
                child: index == _photos.length
                    ? IconButton(
                        tooltip: "Προσθήκη εικόνας",
                        onPressed: _photos.length < 5 ? addPhoto : null,
                        icon: const Icon(Icons.add),
                        color: Theme.of(context).primaryColor,
                      )
                    : SizedBox(
                        height: 60,
                        width: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.transparent,
                              onTap: this.index == index
                                  ? null
                                  : () => setState(() => this.index = index),
                              child: Opacity(
                                opacity: this.index == index ? 1 : 0.5,
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: platformPhotos[index],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

class PlatformPhoto extends StatelessWidget {
  const PlatformPhoto(this.photo, {super.key});

  final Photo photo;

  @override
  Widget build(BuildContext context) {
    final ImageProvider provider;
    if (photo.url != null) {
      provider = NetworkImage("${ApiHandler.photoUrl}/${photo.url!}");
    } else if (!kIsWeb) {
      provider = FileImage(File(photo.file!.path));
    } else {
      return FutureBuilder(
        future: Future(() async => await photo.file!.readAsBytes()),
        builder: (context, snapshot) => snapshot.hasData
            ? Image.memory(
                snapshot.data!,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame == null) {
                    return const SizedBox(
                      height: 60,
                      width: 60,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return child;
                },
              )
            : const SizedBox(
                height: 60,
                width: 60,
                child: Center(child: CircularProgressIndicator()),
              ),
      );
    }
    return Image(
      image: provider,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame == null) {
          return const SizedBox(
            height: 60,
            width: 60,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return child;
      },
    );
  }
}

class PhotoOverlay extends StatelessWidget {
  const PhotoOverlay({
    super.key,
    required this.photo,
    this.onLongPress,
    required this.onRemovePressed,
    required this.onNextPressed,
    required this.onPreviousPressed,
  });

  final PlatformPhoto photo;
  final void Function()? onLongPress;
  final void Function()? onRemovePressed;
  final void Function()? onNextPressed;
  final void Function()? onPreviousPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Stack(
          children: [
            photo,
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onLongPress: onLongPress,
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) => PhotoDialog(child: photo),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 6.0,
          right: 6.0,
          child: SizedBox(
            height: 30.0,
            width: 30.0,
            child: IconButton(
              iconSize: 16.0,
              padding: EdgeInsets.zero,
              onPressed: onRemovePressed,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(backgroundColor: Colors.white54),
            ),
          ),
        ),
        Visibility(
          visible: onNextPressed != null,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 35.0,
                width: 35.0,
                child: IconButton(
                  iconSize: 22.0,
                  padding: EdgeInsets.zero,
                  onPressed: onNextPressed,
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(backgroundColor: Colors.white54),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: onPreviousPressed != null,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 35.0,
                width: 35.0,
                child: IconButton(
                  iconSize: 22.0,
                  padding: EdgeInsets.zero,
                  onPressed: onPreviousPressed,
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(backgroundColor: Colors.white54),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PhotoDialog extends StatelessWidget {
  const PhotoDialog({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: child,
            ),
          ),
        ),
        Positioned(
          left: 30,
          top: 30,
          child: IconButton(
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(backgroundColor: Colors.white54),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}

class PhotoPickerBottomSheet extends StatelessWidget {
  const PhotoPickerBottomSheet({
    super.key,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final void Function() onCameraTap;
  final void Function() onGalleryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.camera),
          title: const Text("Κάμερα"),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 6.0,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
          ),
          onTap: onCameraTap,
        ),
        ListTile(
          title: const Text("Gallery"),
          leading: const Icon(Icons.photo),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 6.0,
          ),
          onTap: onGalleryTap,
        ),
      ],
    );
  }
}

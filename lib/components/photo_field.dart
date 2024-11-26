import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rodis_service/api_handler.dart';

class PhotoField extends StatefulWidget {
  PhotoField({super.key, this.photoUrl, required this.onPhotoSet});

  final String? photoUrl;
  final void Function(String? imagePath, bool removePhoto) onPhotoSet;
  final picker = ImagePicker();

  @override
  State<PhotoField> createState() => PhotoFieldState();
}

class PhotoFieldState extends State<PhotoField> {
  String? imagePath;
  bool removePhoto = false;

  void pickGallery() async {
    final image = await widget.picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    Navigator.pop(context);
    if (image == null) return;
    setState(() => imagePath = image.path);
    widget.onPhotoSet(imagePath, removePhoto);
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
    Navigator.pop(context);
    if (image == null) return;
    setState(() => imagePath = image.path);
    widget.onPhotoSet(imagePath, removePhoto);
  }

  void onRemovePressed() {
    setState(() {
      imagePath = null;
      removePhoto = true;
    });
    widget.onPhotoSet(imagePath, removePhoto);
  }

  void onTap(Widget child) async {
    await showDialog(
      context: context,
      builder: (context) => PhotoDialog(child: child),
    );
  }

  late final pickPhotoBottomSheet = Column(
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
        onTap: pickCamera,
      ),
      ListTile(
        title: const Text("Gallery"),
        leading: const Icon(Icons.photo),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 6.0,
        ),
        onTap: pickGallery,
      ),
    ],
  );

  void addPhoto() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => pickPhotoBottomSheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (imagePath != null) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: PhotoOverlay(
          onTap: () => onTap(
            Image.file(File(imagePath!)),
          ),
          onLongPress: addPhoto,
          onRemovePressed: onRemovePressed,
          child: Image.file(File(imagePath!)),
        ),
      );
    } else if (widget.photoUrl != null && !removePhoto) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: PhotoOverlay(
          onTap: () => onTap(
            Image.network("${ApiHandler.photoUrl}/${widget.photoUrl}"),
          ),
          onLongPress: addPhoto,
          onRemovePressed: onRemovePressed,
          child: Image.network("${ApiHandler.photoUrl}/${widget.photoUrl}"),
        ),
      );
    } else {
      child = TextButton.icon(
        onPressed: addPhoto,
        label: const Text("Προσθήκη εικόνας"),
        icon: const Icon(Icons.camera_alt),
      );
    }
    final decoration =
        imagePath == null && (widget.photoUrl == null || removePhoto)
            ? BoxDecoration(
                color: Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12.0),
              )
            : null;

    return Container(
      height: 350,
      width: 500,
      decoration: decoration,
      child: Center(child: child),
    );
  }
}

class PhotoOverlay extends StatelessWidget {
  const PhotoOverlay({
    super.key,
    required this.onTap,
    required this.onLongPress,
    required this.onRemovePressed,
    required this.child,
  });

  final void Function() onTap;
  final void Function() onLongPress;
  final void Function() onRemovePressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onLongPress: onLongPress,
              onTap: onTap,
              splashFactory: InkSplash.splashFactory,
            ),
          ),
        ),
        Positioned(
          top: 6.0,
          right: 6.0,
          child: SizedBox(
            height: 25.0,
            width: 25.0,
            child: IconButton(
              iconSize: 16.0,
              padding: EdgeInsets.zero,
              onPressed: onRemovePressed,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(backgroundColor: Colors.white54),
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
        GestureDetector(onTap: () => Navigator.pop(context)),
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(backgroundColor: Colors.white54),
          ),
        ),
      ],
    );
  }
}

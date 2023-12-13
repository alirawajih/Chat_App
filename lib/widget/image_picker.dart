import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerUser extends StatefulWidget {
  const ImagePickerUser({super.key, required this.onPickImage});
  final void Function(File image) onPickImage;

  @override
  State<StatefulWidget> createState() {
    return _ImagePicker();
  }
}

class _ImagePicker extends State<ImagePickerUser> {
  File? _selectedImage;
  void _takePicture() async {
    final imagePicker = ImagePicker();
    final getImage = await imagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 150, imageQuality: 50);
    if (getImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(getImage.path);
      widget.onPickImage(_selectedImage!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _selectedImage != null ? FileImage(_selectedImage!) : null,
        ),
        TextButton.icon(
          onPressed: _takePicture,
          icon: const Icon(Icons.camera_alt),
          label: Text(
            'Take a Picture',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        )
      ],
    );
  }
}

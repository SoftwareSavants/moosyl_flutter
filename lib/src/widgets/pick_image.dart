import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moosyl/src/payment_methods/models/selected_file_model.dart';

class PickImageCard extends StatefulWidget {
  final String? label;
  final ValueChanged<List<SelectedFile>> onChanged;

  const PickImageCard({super.key, this.label, required this.onChanged});

  @override
  _PickImageCardState createState() => _PickImageCardState();
}

class _PickImageCardState extends State<PickImageCard> {
  List<SelectedFile> selectedFiles = [];

  Future<void> _pickImage({required bool isCamera}) async {
    final picker = ImagePicker();
    final XFile? pickedFile = isCamera
        ? await picker.pickImage(source: ImageSource.camera)
        : await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedFiles = [SelectedFileImage(file: pickedFile)];
      });
      widget.onChanged(selectedFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    const iconSized = 116.0;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.cloud_upload),
                    label: Text('Upload'),
                    onPressed: () => _pickImage(isCamera: false),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.camera),
                    label: Text('Capture'),
                    onPressed: () => _pickImage(isCamera: true),
                  ),
                ),
              ],
            ),
          ),
          if (selectedFiles.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(top: 16),
              height: iconSized,
              child: Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: selectedFiles.first.isVideo
                          ? const SizedBox.shrink()
                          : Image.file(
                              File(selectedFiles.first.file!.path),
                              width: 116,
                              height: 116,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Center(
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          selectedFiles = [];
                        });
                        widget.onChanged(selectedFiles);
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

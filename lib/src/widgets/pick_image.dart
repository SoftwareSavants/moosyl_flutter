import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:moosyl/l10n/generated/moosyl_localization.dart';
import 'package:moosyl/src/helpers/exception_handling/error_handlers.dart';
import 'package:moosyl/src/widgets/app_image.dart';

class PickImageCard extends StatefulWidget {
  final String? label;
  final void Function(PlatformFile?) onChanged;

  const PickImageCard({super.key, this.label, required this.onChanged});

  @override
  State<PickImageCard> createState() => _PickImageCardState();
}

class _PickImageCardState extends State<PickImageCard> {
  PlatformFile? selectedFile;

  Future<void> _pickImage({
    required bool isCamera,
    required BuildContext context,
  }) async {
    final response = await ErrorHandlers.catchErrors(
      () => FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
      ),
    );

    if (response.isError) return;

    selectedFile = response.result!.files.first;
    widget.onChanged(selectedFile!);
  }

  @override
  Widget build(BuildContext context) {
    const size = 300.0;
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
          if (selectedFile == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  height: 200,
                  child: GestureDetector(
                    onTap: () => _pickImage(
                      isCamera: false,
                      context: context,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf5f5f5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_a_photo_outlined,
                              size: 64,
                              color: Color(0xFF636363),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                MoosylLocalization.of(context)!.upload,
                                style: const TextStyle(
                                  color: Color(0xFF636363),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (selectedFile != null)
            Container(
              padding: const EdgeInsets.only(top: 16),
              height: size,
              child: AppImage(
                uri: selectedFile!.path!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(10),
                customZoomIcon: GestureDetector(
                  onTap: () {
                    selectedFile = null;
                    widget.onChanged(selectedFile);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

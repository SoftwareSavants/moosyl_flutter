import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:moosyl/l10n/generated/moosyl_localization.dart';
import 'package:moosyl/src/helpers/exception_handling/error_handlers.dart';
import 'package:moosyl/src/widgets/buttons.dart';
import 'package:moosyl/src/widgets/container.dart';
import 'package:moosyl/src/widgets/icons.dart';

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
      context: context,
    );

    if (response.isError) return;

    selectedFile = response.result!.files.first;
    widget.onChanged(selectedFile!);
  }

  @override
  Widget build(BuildContext context) {
    const size = 300.0;
    final textTheme = Theme.of(context).textTheme;
    // final style = ElevatedButton.styleFrom(
    //   minimumSize: const Size(200, 60), // Fixed size (width, height)
    // );

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
            AppContainer(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                      child: AppButton(
                    minHeight: 40,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    leading: AppIcons.cloud,
                    background: Theme.of(context).colorScheme.onPrimary,
                    labelText: MoosylLocalization.of(context)!.upload,
                    onPressed: () => _pickImage(
                      isCamera: false,
                      context: context,
                    ),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      minHeight: 40,
                      textColor: Theme.of(context).colorScheme.onSurface,
                      leading: AppIcons.pic,
                      background: Theme.of(context).colorScheme.onPrimary,
                      labelText: MoosylLocalization.of(context)!.capture,
                      onPressed: () => _pickImage(
                        isCamera: true,
                        context: context,
                      ),
                    ),
                  )
                ],
              ),
            ),
          if (selectedFile != null)
            Container(
              padding: const EdgeInsets.only(top: 16),
              height: size,
              child: Stack(
                children: [
                  Center(
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: SizedBox(
                      width: 215,
                      child: AppPlatformFileView(file: selectedFile!),
                    ),
                  )),
                  Center(
                    child: IconButton(
                      icon: AppIcons.delete.apply(
                        size: 44,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      onPressed: () {
                        selectedFile = null;
                        widget.onChanged(selectedFile);
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

class AppPlatformFileView extends StatelessWidget {
  final PlatformFile file;

  const AppPlatformFileView({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    if (file.bytes != null) {
      return Image.memory(
        file.bytes!,
        fit: BoxFit.fill,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (file.path != null) {
      return Image.asset(
        file.path!,
        fit: BoxFit.fill,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      return const Center(child: Text('No image available'));
    }
  }
}

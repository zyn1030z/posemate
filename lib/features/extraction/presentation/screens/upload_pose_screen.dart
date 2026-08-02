import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posely_ai/core/error/app_exception.dart';
import 'package:posely_ai/features/extraction/presentation/controllers/extraction_controller.dart';
import 'package:posely_ai/features/pose/domain/entities/pose.dart';
import 'package:go_router/go_router.dart';

class UploadPoseScreen extends ConsumerStatefulWidget {
  const UploadPoseScreen({super.key});

  @override
  ConsumerState<UploadPoseScreen> createState() => _UploadPoseScreenState();
}

class _UploadPoseScreenState extends ConsumerState<UploadPoseScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        ref.read(extractionControllerProvider.notifier).reset();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image.')),
        );
      }
    }
  }

  void _extractPose() {
    if (_selectedImage != null) {
      ref.read(extractionControllerProvider.notifier).extractPose(_selectedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final extractionState = ref.watch(extractionControllerProvider);

    ref.listen<AsyncValue<Pose?>>(extractionControllerProvider, (previous, next) {
      if (next.hasError) {
        final error = next.error;
        final message = error is AppException
            ? error.userMessage
            : 'Failed to extract pose.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extract Pose'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _selectedImage!,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              if (extractionState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (extractionState.value != null) ...[
                const Text(
                  'Pose Extracted Successfully!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // For now, go back to previous screen or library.
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  child: const Text('Save & Finish'),
                ),
              ] else
                ElevatedButton.icon(
                  onPressed: _extractPose,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Extract Skeleton'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
            ] else ...[
              const SizedBox(height: 48),
              const Icon(
                Icons.image_search,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload a photo to extract its pose.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take a Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
            if (_selectedImage != null && !extractionState.isLoading && extractionState.value == null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                  });
                  ref.read(extractionControllerProvider.notifier).reset();
                },
                child: const Text('Choose a different photo'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

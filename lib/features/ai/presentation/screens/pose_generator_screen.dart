import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/shared/widgets/app_error_view.dart';
import 'package:posely_ai/core/theme/tokens/app_radius.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/features/ai/domain/entities/generate_prompt.dart';
import 'package:posely_ai/features/ai/presentation/controllers/generate_job_controller.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';
import 'package:posely_ai/features/pose/presentation/widgets/pose_card.dart';

class PoseGeneratorScreen extends ConsumerStatefulWidget {
  const PoseGeneratorScreen({super.key});

  @override
  ConsumerState<PoseGeneratorScreen> createState() =>
      _PoseGeneratorScreenState();
}

class _PoseGeneratorScreenState extends ConsumerState<PoseGeneratorScreen> {
  final _promptController = TextEditingController();
  final _focusNode = FocusNode();

  String _selectedStyle = 'photo';
  PeopleCount _selectedCount = PeopleCount.solo;

  static const _styles = ['photo', 'illustration', 'sketch', 'anime'];

  @override
  void dispose() {
    _promptController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;
    
    // Close keyboard
    _focusNode.unfocus();

    ref.read(generateJobControllerProvider.notifier).submit(
      GeneratePrompt(
        prompt: prompt,
        count: 4,
        style: _selectedStyle,
        peopleCount: _selectedCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generateJobControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Generator'),
        actions: [
          if (state.job?.result != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(generateJobControllerProvider.notifier).reset();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: switch (state) {
          _ when state.isIdle => _buildComposer(),
          _ when state.isGenerating => _buildProgress(state),
          _ when state.job?.result != null => _buildResults(state),
          _ when state.error != null => _buildError(state.error!),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _buildComposer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Describe your scene',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _promptController,
            focusNode: _focusNode,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'e.g., golden hour beach couple, candid walking...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            'Style',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: _styles.map((style) {
              final isSelected = _selectedStyle == style;
              return ChoiceChip(
                label: Text(style.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedStyle = style);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'Subjects',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: PeopleCount.values.map((count) {
              final isSelected = _selectedCount == count;
              return ChoiceChip(
                label: Text(count.label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedCount = count);
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Poses'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(GenerateJobState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            state.job?.status.name.toUpperCase() ?? 'GENERATING...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.job?.progress != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: LinearProgressIndicator(
                value: state.job!.progress / 100,
              ),
            ),
          if (state.job?.estimatedSeconds != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Estimated time: ${state.job!.estimatedSeconds}s',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResults(GenerateJobState state) {
    final poses = state.job?.result ?? [];
    
    if (poses.isEmpty) {
      return const Center(child: Text('No poses generated.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.75,
      ),
      itemCount: poses.length,
      itemBuilder: (context, index) {
        return PoseCard(
          pose: poses[index],
          onTap: () {
            // Note: Normally we'd push to detail screen, but for this Phase
            // we can just show a snackbar or implement saving.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped ${poses[index].name}')),
            );
          },
        );
      },
    );
  }

  Widget _buildError(String error) {
    // Check if error contains 402 for premium gating
    if (error.contains('402')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, size: 64, color: Colors.amber),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Out of tokens!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text('Upgrade to Premium to generate more poses.'),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () {
                // Navigate to premium screen or show paywall
                ref.read(generateJobControllerProvider.notifier).reset();
              },
              child: const Text('Upgrade'),
            ),
            TextButton(
              onPressed: () {
                ref.read(generateJobControllerProvider.notifier).reset();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return AppErrorView(
      message: error,
      onRetry: () {
        ref.read(generateJobControllerProvider.notifier).reset();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/core/theme/tokens/app_spacing.dart';
import 'package:posely_ai/core/theme/tokens/app_typography.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_collection.dart';
import 'package:posely_ai/features/pose/presentation/controllers/collection_controller.dart';

/// Shows a bottom sheet that lets the user add or remove [poseId]
/// from their collections. Returns the number of collections modified.
Future<int?> showCollectionPicker({
  required BuildContext context,
  required String poseId,
}) {
  return showPoselyBottomSheet<int>(
    context: context,
    title: 'Save to collection',
    builder: (_) => _CollectionPickerBody(poseId: poseId),
  );
}

/// The stateful body of the collection picker sheet.
class _CollectionPickerBody extends ConsumerStatefulWidget {
  const _CollectionPickerBody({required this.poseId});

  final String poseId;

  @override
  ConsumerState<_CollectionPickerBody> createState() =>
      _CollectionPickerBodyState();
}

class _CollectionPickerBodyState extends ConsumerState<_CollectionPickerBody> {
  /// Number of add/remove operations performed this session.
  int _changeCount = 0;

  /// Whether the "create" text field is currently visible.
  bool _isCreating = false;

  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _createCollection() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final controller = ref.read(collectionControllerProvider.notifier);
    final collection = await controller.create(name);
    await controller.addPose(collection.id, widget.poseId);
    _nameController.clear();
    _changeCount++;
    if (mounted) setState(() => _isCreating = false);
  }

  Future<void> _togglePose(PoseCollection collection) async {
    final controller = ref.read(collectionControllerProvider.notifier);
    final contains = collection.poseIds.contains(widget.poseId);
    if (contains) {
      await controller.removePose(collection.id, widget.poseId);
    } else {
      await controller.addPose(collection.id, widget.poseId);
    }
    _changeCount++;
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionControllerProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Collection list
        if (collections.isEmpty && !_isCreating)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                'No collections yet',
                style: AppTypography.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.35,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: collections.length,
              itemBuilder: (_, int index) {
                final collection = collections[index];
                final contains = collection.poseIds.contains(widget.poseId);
                return _CollectionTile(
                  collection: collection,
                  isSelected: contains,
                  onTap: () => _togglePose(collection),
                );
              },
            ),
          ),

        // Create new collection inline form
        if (_isCreating) ...<Widget>[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: PoselyTextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    hint: 'Collection name',
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _createCollection(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                PoselyIconButton(
                  icon: Icons.check_rounded,
                  active: true,
                  onPressed: _createCollection,
                  semanticLabel: 'Create collection',
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.md),

        // Create new collection button
        if (!_isCreating)
          PoselyButton(
            label: 'New collection',
            icon: Icons.add_rounded,
            variant: PoselyButtonVariant.glass,
            expand: true,
            onPressed: () {
              setState(() => _isCreating = true);
              // Focus after the next frame so the text field is mounted.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _nameFocusNode.requestFocus();
              });
            },
          ),

        const SizedBox(height: AppSpacing.sm),

        // Done button
        PoselyButton(
          label: 'Done',
          expand: true,
          onPressed: () => Navigator.of(context).pop(_changeCount),
        ),
      ],
    );
  }
}

/// A single row in the collection list with a checkbox indicator.
class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.collection,
    required this.isSelected,
    required this.onTap,
  });

  final PoseCollection collection;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      collection.name,
                      style: AppTypography.body.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${collection.poseIds.length} poses',
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

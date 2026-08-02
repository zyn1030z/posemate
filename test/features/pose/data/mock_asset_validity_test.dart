import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/features/pose/data/models/pose_category_model.dart';
import 'package:posely_ai/features/pose/data/models/pose_model.dart';
import 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';

/// Validates the real bundled dev dataset, so a bad edit to the asset fails
/// CI instead of breaking the dev flavor at runtime. The test runner's
/// working directory is the project root.
void main() {
  late List<PoseCategoryModel> categories;
  late List<PoseModel> poses;

  setUpAll(() {
    final raw = File('assets/mock/poses.json').readAsStringSync();
    final root = jsonDecode(raw) as Map<String, dynamic>;
    categories = (root['categories']! as List<dynamic>)
        .map(
          (item) => PoseCategoryModel.fromJson(item! as Map<String, dynamic>),
        )
        .toList();
    poses = (root['poses']! as List<dynamic>)
        .map((item) => PoseModel.fromJson(item! as Map<String, dynamic>))
        .toList();
  });

  test('contains 16 categories and 60 poses', () {
    expect(categories, hasLength(16));
    expect(poses, hasLength(60));
  });

  test('categories have unique ids and non-empty names and emoji', () {
    final ids = categories.map((category) => category.id).toSet();
    expect(ids, hasLength(categories.length));
    for (final category in categories) {
      expect(category.name, isNotEmpty);
      expect(category.emoji, isNotEmpty);
    }
  });

  test('every pose references an existing category', () {
    final categoryIds = categories.map((category) => category.id).toSet();
    for (final pose in poses) {
      expect(
        categoryIds,
        contains(pose.categoryId),
        reason: 'Pose ${pose.id} references unknown '
            'category ${pose.categoryId}',
      );
    }
  });

  test('every difficulty and gender string parses into its enum', () {
    for (final pose in poses) {
      expect(
        PoseDifficulty.tryParse(pose.difficulty),
        isNotNull,
        reason: 'Pose ${pose.id} has unknown difficulty ${pose.difficulty}',
      );
      expect(
        PoseGender.tryParse(pose.gender),
        isNotNull,
        reason: 'Pose ${pose.id} has unknown gender ${pose.gender}',
      );
    }
  });

  test('pose ids are unique and URLs are non-empty', () {
    final ids = poses.map((pose) => pose.id).toSet();
    expect(ids, hasLength(poses.length));
    for (final pose in poses) {
      expect(pose.previewUrl, isNotEmpty);
      expect(pose.overlayUrl, isNotEmpty);
    }
  });

  test('body direction and camera angle use known values', () {
    const directions = {'front', 'back', 'side', 'three-quarter'};
    const angles = {'eye-level', 'low', 'high'};
    for (final pose in poses) {
      expect(directions, contains(pose.bodyDirection), reason: pose.id);
      expect(angles, contains(pose.cameraAngle), reason: pose.id);
    }
  });

  test('scores and downloads stay in their expected ranges', () {
    for (final pose in poses) {
      expect(pose.aiScore, inInclusiveRange(3.9, 4.9), reason: pose.id);
      expect(pose.downloads, inInclusiveRange(900, 48000), reason: pose.id);
      expect(pose.tags.length, inInclusiveRange(3, 5), reason: pose.id);
    }
  });
}

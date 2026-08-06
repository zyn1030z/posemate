import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posely_ai/core/design/design.dart';
import 'package:posely_ai/core/router/route_paths.dart';
import 'package:posely_ai/core/theme/tokens/app_colors.dart';
import 'package:posely_ai/features/camera/domain/entities/ai_coach.dart';

/// Screen for users to select an AI Fitness Coach before entering the camera.
class CoachSelectionScreen extends StatefulWidget {
  final List<String>? poseIds;
  const CoachSelectionScreen({super.key, this.poseIds});

  @override
  State<CoachSelectionScreen> createState() => _CoachSelectionScreenState();
}

class _CoachSelectionScreenState extends State<CoachSelectionScreen> {
  AiCoach? _selectedCoach;

  // Mocked list of AI Coaches
  final List<AiCoach> _coaches = const [
    AiCoach(
      id: 'coach_1',
      name: 'Sarah',
      specialization: 'Yoga Expert',
      rating: 5.0,
      reviewCount: 342,
      imageUrl: '',
      description: 'Focuses on balance, breathing, and flexibility.',
      voicePitch: 1.2,
      voiceRate: 0.9,
    ),
    AiCoach(
      id: 'coach_2',
      name: 'Max',
      specialization: 'Strength & Core',
      rating: 4.9,
      reviewCount: 512,
      imageUrl: '',
      description: 'Pushes you to maintain perfect form for muscle gains.',
      voicePitch: 0.8,
      voiceRate: 1.1,
    ),
    AiCoach(
      id: 'coach_3',
      name: 'Elena',
      specialization: 'Dance & Cardio',
      rating: 4.8,
      reviewCount: 215,
      imageUrl: '',
      description: 'Energetic and upbeat, focusing on rhythm and flow.',
      voicePitch: 1.3,
      voiceRate: 1.2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCoach = _coaches.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: PoselyIconButton(
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Hero Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    'Choose Your AI Coach',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Get real-time feedback on your poses with your personal AI assistant.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // 2. Profiles Grid (Carousel/List)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: _coaches.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final coach = _coaches[index];
                  final isSelected = _selectedCoach?.id == coach.id;
                  return _buildCoachCard(coach, isSelected);
                },
              ),
            ),
            
            // 3. CTA Section
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: PoselyButton(
                  label: 'Start Session with ${_selectedCoach?.name ?? 'Coach'}',
                  expand: true,
                  onPressed: () {
                    // Navigate to Camera with the selected coach ID and original pose IDs
                    context.pushNamed(
                      RouteNames.camera,
                      queryParameters: {
                        'coachId': _selectedCoach!.id,
                        if (widget.poseIds != null) 'poseIds': widget.poseIds!.join(','),
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachCard(AiCoach coach, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCoach = coach),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                image: coach.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(coach.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: coach.imageUrl.isEmpty 
                  ? const Icon(Icons.person, color: AppColors.textSecondary)
                  : null,
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coach.specialization,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${coach.rating} (${coach.reviewCount} reviews)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isSelected 
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

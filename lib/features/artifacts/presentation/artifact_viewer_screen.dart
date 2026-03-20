import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state_card.dart';
import '../../../shared/models/app_models.dart';
import '../../projects/application/project_controller.dart';

class ArtifactViewerScreen extends ConsumerWidget {
  const ArtifactViewerScreen({
    super.key,
    required this.projectId,
    required this.artifactId,
  });

  final String projectId;
  final String artifactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artifact = ref.watch(
      artifactByIdProvider((projectId: projectId, artifactId: artifactId)),
    );

    if (artifact == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: EmptyStateCard(
          title: 'Artifact not found',
          message: 'The selected artifact is unavailable.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artifact.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('${artifact.type} • ${artifact.status.label}'),
                const SizedBox(height: 8),
                Text(artifact.summary),
                const SizedBox(height: 16),
                SelectableText(artifact.content),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

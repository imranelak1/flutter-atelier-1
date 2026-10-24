import 'package:flutter/material.dart';
import 'app.dart';
import 'widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.exercise,
    this.useNetworkImage = true,
  });
  final Exercise exercise;
  final bool useNetworkImage;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Atelier Flutter')),
    body: SafeArea(
      child: switch (exercise) {
        Exercise.a => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Bienvenue dans mon premier atelier Flutter !',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        Exercise.b => WorkshopBody(
          children: [CourseCard(useNetworkImage: useNetworkImage)],
        ),
        Exercise.c => const WorkshopBody(children: [LayoutExercises()]),
        Exercise.d => WorkshopBody(
          children: [
            CourseCard(useNetworkImage: useNetworkImage),
            const LayoutExercises(),
          ],
        ),
        Exercise.alignments => const AlignmentPage(),
        Exercise.overflow => const Padding(
          padding: EdgeInsets.all(16),
          child: Row(children: [Text(longDescription)]),
        ),
      },
    ),
    floatingActionButton: switch (exercise) {
      Exercise.alignments || Exercise.overflow => null,
      _ => FloatingActionButton(
        tooltip: 'Ajouter',
        onPressed: () => debugPrint('FAB cliqué'),
        child: const Icon(Icons.add),
      ),
    },
  );
}

class WorkshopBody extends StatelessWidget {
  const WorkshopBody({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(top: 8, bottom: 96),
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
}

class LayoutExercises extends StatelessWidget {
  const LayoutExercises({super.key});
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('En quelques chiffres', style: text.titleLarge),
          const SizedBox(height: 24),
          const StatisticsBar(),
          const SizedBox(height: 28),
          Text('Partager l’espace · 1 : 2 : 1', style: text.titleMedium),
          const SizedBox(height: 12),
          const ProportionRow(),
          const SizedBox(height: 28),
          const TextOverflowExamples(),
        ],
      ),
    );
  }
}

class AlignmentPage extends StatelessWidget {
  const AlignmentPage({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WorkshopBody(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Axe principal du Row', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              for (final alignment in MainAxisAlignment.values) ...[
                Text(alignment.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: theme.colorScheme.surfaceContainer,
                  child: Row(
                    mainAxisAlignment: alignment,
                    children: [
                      for (final value in ['A', 'B', 'C'])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            value,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 12),
              Text(
                'Axe secondaire de la Column',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              for (final alignment in [
                CrossAxisAlignment.start,
                CrossAxisAlignment.center,
                CrossAxisAlignment.end,
                CrossAxisAlignment.stretch,
              ]) ...[
                Text(alignment.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: theme.colorScheme.surfaceContainer,
                  child: Column(
                    crossAxisAlignment: alignment,
                    children: [
                      for (final value in [
                        'Flutter',
                        'Des widgets',
                        'Une interface',
                      ])
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          padding: const EdgeInsets.all(6),
                          color: theme.colorScheme.secondaryContainer,
                          child: Text(
                            value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

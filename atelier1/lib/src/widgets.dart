import 'package:flutter/material.dart';

const longDescription =
    'Flutter permet de composer une interface lisible et adaptable en combinant '
    'des widgets simples, tout en conservant une mise en page correcte sur '
    'les petits écrans comme sur les grandes fenêtres.';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, this.useNetworkImage = true});
  final bool useNetworkImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (useNetworkImage)
            Image.network(
              'https://picsum.photos/id/20/1000/500',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              semanticLabel: 'Bureau et outils de travail pour le cours',
              errorBuilder: (context, error, stackTrace) => const CourseImage(),
            )
          else
            const CourseImage(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ingénierie logicielle',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Construire des interfaces Flutter.\nDes widgets simples, un thème cohérent.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () =>
                        debugPrint('En savoir plus : cours Flutter'),
                    child: const Text('En savoir plus'),
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

class CourseImage extends StatelessWidget {
  const CourseImage({super.key});
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/course.jpg',
    height: 160,
    width: double.infinity,
    fit: BoxFit.cover,
    semanticLabel: 'Image locale du cours, disponible hors connexion',
  );
}

class WorkshopStat extends StatelessWidget {
  const WorkshopStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(value, style: theme.textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class StatisticsBar extends StatelessWidget {
  const StatisticsBar({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final statistic in const [
          WorkshopStat(icon: Icons.code, value: '12', label: 'Projets'),
          WorkshopStat(icon: Icons.work_outline, value: '3', label: 'Stages'),
          WorkshopStat(
            icon: Icons.menu_book_outlined,
            value: '8',
            label: 'Cours',
          ),
        ])
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth / 3),
            child: statistic,
          ),
      ],
    ),
  );
}

class ProportionRow extends StatelessWidget {
  const ProportionRow({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: ProportionBlock(
            label: '1',
            background: colors.primaryContainer,
            foreground: colors.onPrimaryContainer,
          ),
        ),
        Expanded(
          flex: 2,
          child: ProportionBlock(
            label: '2',
            background: colors.secondaryContainer,
            foreground: colors.onSecondaryContainer,
          ),
        ),
        Expanded(
          child: ProportionBlock(
            label: '1',
            background: colors.tertiaryContainer,
            foreground: colors.onTertiaryContainer,
          ),
        ),
      ],
    );
  }
}

class ProportionBlock extends StatelessWidget {
  const ProportionBlock({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });
  final String label;
  final Color background;
  final Color foreground;
  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    color: background,
    alignment: Alignment.center,
    child: Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: foreground),
    ),
  );
}

class TextOverflowExamples extends StatelessWidget {
  const TextOverflowExamples({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Retour à la ligne avec Expanded',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.wrap_text, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(longDescription, style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Une ligne avec Flexible', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.short_text, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                longDescription,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

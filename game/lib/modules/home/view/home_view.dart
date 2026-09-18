import 'package:game/modules/game/view/game_screen/game_screen.dart';
import 'package:game/resources/app_strings.dart';
import 'package:game/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game/shared/bloc/app/app.dart';

class _LevelPlate {
  final String order;
  final String title;
  final String tagline;
  final List<String> mood;
  final String quote;
  final Color accent;

  const _LevelPlate({
    required this.order,
    required this.title,
    required this.tagline,
    required this.mood,
    required this.quote,
    required this.accent,
  });
}

class _CastMember {
  final String name;
  final String role;
  final String tagline;
  final String description;
  final Color accent;

  const _CastMember({
    required this.name,
    required this.role,
    required this.tagline,
    required this.description,
    required this.accent,
  });
}

const _levelPlates = [
  _LevelPlate(
    order: 'PLATE I',
    title: 'Hearth Hollow',
    tagline:
        "Golden hour, wood smoke, and a stranger with an axe he hasn't earned yet.",
    mood: ['WARM', 'LOW', 'TRUSTING'],
    quote: 'Nothing here is hiding yet. Every shadow is just a shadow.',
    accent: AppColors.hearthHollow,
  ),
  _LevelPlate(
    order: 'PLATE II',
    title: 'The Cliffside Path',
    tagline:
        'One fire, one flag, one crack of the wrong color in the rock.',
    mood: ['WINDSWEPT', 'THINNING'],
    quote:
        "The world is still real here. It's just started leaving hints that it's tired of being.",
    accent: AppColors.cliffsidePath,
  ),
  _LevelPlate(
    order: 'PLATE III',
    title: 'The Corrupted Grove',
    tagline:
        'The same trees as before, except now you can see all their edges at once.',
    mood: ['FAMILIAR', 'DOUBLED', 'WRONG'],
    quote: 'Everything here has already happened once. That\'s the problem.',
    accent: AppColors.corruptedGrove,
  ),
  _LevelPlate(
    order: 'PLATE IV',
    title: 'The Haven',
    tagline:
        "Somewhere that was never built to be found, and doesn't mind that you did.",
    mood: ['HIDDEN', 'PATIENT'],
    quote: "It doesn't need you to believe in it anymore.",
    accent: AppColors.haven,
  ),
];

const _castMembers = [
  _CastMember(
    name: 'The Traveler',
    role: 'THE PLAYER CHARACTER',
    tagline: 'No name, no past given — just a rusty axe and somewhere to be.',
    description:
        'Kept deliberately unfinished — silhouette over detail, so any player can sit inside it.',
    accent: AppColors.textSecondary,
  ),
  _CastMember(
    name: 'The Blacksmith',
    role: 'LEVEL 1 — HEARTH HOLLOW',
    tagline:
        "Warm, loud, and telling you exactly enough to be wrong about somebody.",
    description:
        "The game's first voice, and its first unreliable one.",
    accent: AppColors.hearthHollow,
  ),
  _CastMember(
    name: 'The Forester',
    role: 'LEVEL 2 — THE CLIFFSIDE PATH',
    tagline: "Better they're afraid of an old man in the woods.",
    description:
        'Reads as a threat in silhouette and a guardian up close — same shape, different light.',
    accent: AppColors.cliffsidePath,
  ),
  _CastMember(
    name: 'Cedric Spooks Queen',
    role: 'THE GAME ALCHEMIST — VANISHED RESEARCHER',
    tagline: "Found only in notes, photographs, and the shape of what's missing.",
    description:
        'The one character who was never native to this world. The glitch bleeding in from one side is where he went.',
    accent: AppColors.corruptedGrove,
  ),
  _CastMember(
    name: 'The Guardian',
    role: 'LEVEL 4 — THE HAVEN',
    tagline: 'Speaks for a place that was never built to be found.',
    description:
        'No face on purpose — whether this is an Echo of Cedric or something older is left an open question.',
    accent: AppColors.haven,
  ),
];

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(Strings.appName, style: AppTextStyles.h2),
        actions: const [_AuthAction(), SizedBox(width: AppSpacing.md)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),
            _WorldSection(),
            _CastSection(),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _AuthAction extends StatelessWidget {
  const _AuthAction();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final isLoggedIn = state is AppContentLoadedState && state.isLoggedIn;
        return TextButton(
          onPressed: () {
            context.read<AppBloc>().add(
                  isLoggedIn ? const AppLogoutEvent() : const AppLoginEvent(),
                );
          },
          child: Text(
            isLoggedIn ? Strings.btnLogout : Strings.btnLogin,
            style: AppTextStyles.body.copyWith(color: AppColors.primary),
          ),
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < AppBreakpoints.tablet;
        final screenshot = ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 8)),
              ],
            ),
            child: Image.asset('assets/images/gameplay_screenshot.png', fit: BoxFit.cover),
          ),
        );
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Strings.heroTitle, style: AppTextStyles.title.copyWith(fontSize: 40)),
            const SizedBox(height: AppSpacing.md),
            Text(
              Strings.heroTagline,
              style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic, fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              },
              child: Text(Strings.btnPlayNow, style: AppTextStyles.body.copyWith(color: AppColors.background)),
            ),
          ],
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: isNarrow
              ? Column(children: [copy, const SizedBox(height: AppSpacing.xl), screenshot])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(child: screenshot),
                  ],
                ),
        );
      },
    );
  }
}

class _WorldSection extends StatelessWidget {
  const _WorldSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Strings.sectionWorldTitle, style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.sm),
          Text(Strings.sectionWorldIntro, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [for (final plate in _levelPlates) _PlateCard(plate: plate)],
          ),
        ],
      ),
    );
  }
}

class _PlateCard extends StatelessWidget {
  final _LevelPlate plate;
  const _PlateCard({required this.plate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(left: BorderSide(color: plate.accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(plate.order, style: AppTextStyles.bodySmall.copyWith(color: plate.accent)),
          const SizedBox(height: AppSpacing.xs),
          Text(plate.title, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),
          Text(plate.tagline, style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final tag in plate.mood)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                  color: AppColors.surface,
                  child: Text(tag, style: AppTextStyles.bodySmall.copyWith(color: plate.accent)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('"${plate.quote}"', style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _CastSection extends StatelessWidget {
  const _CastSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Strings.sectionCastTitle, style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.sm),
          Text(Strings.sectionCastIntro, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [for (final member in _castMembers) _CastCard(member: member)],
          ),
        ],
      ),
    );
  }
}

class _CastCard extends StatelessWidget {
  final _CastMember member;
  const _CastCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 48,
            color: member.accent,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(member.role, style: AppTextStyles.bodySmall.copyWith(color: member.accent)),
          const SizedBox(height: AppSpacing.xs),
          Text(member.name, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(member.tagline, style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: AppSpacing.sm),
          Text(member.description, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.lg),
      alignment: Alignment.center,
      child: Text(
        'Project Echo — concept: Team Echo',
        style: AppTextStyles.bodySmall,
      ),
    );
  }
}


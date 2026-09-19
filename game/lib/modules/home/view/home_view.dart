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
  final String imageAsset;

  const _LevelPlate({
    required this.order,
    required this.title,
    required this.tagline,
    required this.mood,
    required this.quote,
    required this.accent,
    required this.imageAsset,
  });
}

class _CastMember {
  final String name;
  final String role;
  final String tagline;
  final String description;
  final Color accent;
  final String imageAsset;

  const _CastMember({
    required this.name,
    required this.role,
    required this.tagline,
    required this.description,
    required this.accent,
    required this.imageAsset,
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
    imageAsset: 'assets/images/world_hearth_hollow.png',
  ),
  _LevelPlate(
    order: 'PLATE II',
    title: 'The Cliffside Path',
    tagline: 'One fire, one flag, one crack of the wrong color in the rock.',
    mood: ['WINDSWEPT', 'THINNING'],
    quote:
        "The world is still real here. It's just started leaving hints that it's tired of being.",
    accent: AppColors.cliffsidePath,
    imageAsset: 'assets/images/world_cliffside_path.png',
  ),
  _LevelPlate(
    order: 'PLATE III',
    title: 'The Corrupted Grove',
    tagline:
        'The same trees as before, except now you can see all their edges at once.',
    mood: ['FAMILIAR', 'DOUBLED', 'WRONG'],
    quote: 'Everything here has already happened once. That\'s the problem.',
    accent: AppColors.corruptedGrove,
    imageAsset: 'assets/images/world_corrupted_grove.png',
  ),
  _LevelPlate(
    order: 'PLATE IV',
    title: 'The Haven',
    tagline:
        "Somewhere that was never built to be found, and doesn't mind that you did.",
    mood: ['HIDDEN', 'PATIENT'],
    quote: "It doesn't need you to believe in it anymore.",
    accent: AppColors.haven,
    imageAsset: 'assets/images/world_haven.png',
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
    imageAsset: 'assets/images/cast_traveler.png',
  ),
  _CastMember(
    name: 'The Blacksmith',
    role: 'LEVEL 1 — HEARTH HOLLOW',
    tagline:
        "Warm, loud, and telling you exactly enough to be wrong about somebody.",
    description: "The game's first voice, and its first unreliable one.",
    accent: AppColors.hearthHollow,
    imageAsset: 'assets/images/cast_blacksmith.png',
  ),
  _CastMember(
    name: 'The Forester',
    role: 'LEVEL 2 — THE CLIFFSIDE PATH',
    tagline: "Better they're afraid of an old man in the woods.",
    description:
        'Reads as a threat in silhouette and a guardian up close — same shape, different light.',
    accent: AppColors.cliffsidePath,
    imageAsset: 'assets/images/cast_forester.png',
  ),
  _CastMember(
    name: 'Cedric Spooks Queen',
    role: 'THE GAME ALCHEMIST — VANISHED RESEARCHER',
    tagline:
        "Found only in notes, photographs, and the shape of what's missing.",
    description:
        'The one character who was never native to this world. The glitch bleeding in from one side is where he went.',
    accent: AppColors.corruptedGrove,
    imageAsset: 'assets/images/cast_cedric.png',
  ),
  _CastMember(
    name: 'The Guardian',
    role: 'LEVEL 4 — THE HAVEN',
    tagline: 'Speaks for a place that was never built to be found.',
    description:
        'No face on purpose — whether this is an Echo of Cedric or something older is left an open question.',
    accent: AppColors.haven,
    imageAsset: 'assets/images/cast_guardian.png',
  ),
];

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _scrollController = ScrollController();
  final _worldKey = GlobalKey();
  final _castKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToSection(GlobalKey key) {
    final sectionContext = key.currentContext;
    if (sectionContext != null) {
      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _TopHeader(
              onHomeTap: _scrollToTop,
              onWorldTap: () => _scrollToSection(_worldKey),
              onCastTap: () => _scrollToSection(_castKey),
            ),
            const _HeroSection(),
            _WorldSection(key: _worldKey),
            _CastSection(key: _castKey),
            const _Footer(),
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
            (isLoggedIn ? Strings.btnLogout : Strings.btnLogin).toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.background,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}

class _TopHeader extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onWorldTap;
  final VoidCallback onCastTap;

  const _TopHeader({
    required this.onHomeTap,
    required this.onWorldTap,
    required this.onCastTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield, color: AppColors.primary, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  Strings.appName.toUpperCase(),
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.background,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            color: AppColors.primaryDark,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.md,
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _NavPill(label: 'Home', onTap: onHomeTap),
                _NavPill(label: 'World', onTap: onWorldTap),
                _NavPill(label: 'Cast', onTap: onCastTap),
                const SizedBox(width: AppSpacing.sm),
                const _AuthAction(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _PlayNowButton(),
        ],
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _PlayNowButton extends StatelessWidget {
  const _PlayNowButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
      ),
      onPressed: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const GameScreen()));
      },
      child: Text(
        Strings.btnPlayNow.toUpperCase(),
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SectionBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.h1.copyWith(
              color: AppColors.background,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(subtitle, style: AppTextStyles.body),
      ],
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
        final screenshot = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/gameplay_screenshot.png',
            fit: BoxFit.cover,
          ),
        );
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Strings.heroSectionHeading,
              style: AppTextStyles.title.copyWith(fontSize: 34),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              Strings.heroTagline,
              style: AppTextStyles.body.copyWith(
                fontStyle: FontStyle.italic,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final plate in _levelPlates)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 8, color: plate.accent),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${plate.title} — ${plate.mood.join(', ').toLowerCase()}',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            const _PlayNowButton(),
          ],
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: isNarrow
              ? Column(
                  children: [
                    screenshot,
                    const SizedBox(height: AppSpacing.xl),
                    copy,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
  const _WorldSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionBanner(
            title: Strings.sectionWorldTitle,
            subtitle: Strings.sectionWorldIntro,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              for (final plate in _levelPlates) _PlateCard(plate: plate),
            ],
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
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: plate.accent, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(plate.imageAsset, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  plate.order,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: plate.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(plate.title, style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  plate.tagline,
                  style: AppTextStyles.body.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    for (final tag in plate.mood)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: plate.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: plate.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '"${plate.quote}"',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
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

class _CastSection extends StatelessWidget {
  const _CastSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionBanner(
            title: Strings.sectionCastTitle,
            subtitle: Strings.sectionCastIntro,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              for (final member in _castMembers) _CastCard(member: member),
            ],
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Image.asset(member.imageAsset, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 48,
                  decoration: BoxDecoration(
                    color: member.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  member.role,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: member.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(member.name, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  member.tagline,
                  style: AppTextStyles.body.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(member.description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
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
      color: AppColors.primaryDark,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const _PlayNowButton(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Project Echo — concept: Team Echo',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }
}

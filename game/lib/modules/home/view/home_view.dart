import 'dart:math' as math;

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
    return ClipPath(
      clipper: _ScallopedEdgeClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff3d2914), AppColors.primaryDark],
          ),
        ),
        padding: const EdgeInsets.only(
          top: AppSpacing.lg,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.xl,
        ),
        child: Column(
          children: [
            const _Crest(),
            const SizedBox(height: AppSpacing.sm),
            const _Wordmark(),
            const SizedBox(height: AppSpacing.lg),
            _NavBar(
              onHomeTap: onHomeTap,
              onWorldTap: onWorldTap,
              onCastTap: onCastTap,
            ),
            const SizedBox(height: AppSpacing.lg),
            const _PlayNowButton(),
          ],
        ),
      ),
    );
  }
}

/// Hexagonal crest badge that anchors the wordmark, echoing Hearth Hollow's hearth-fire motif.
class _Crest extends StatelessWidget {
  const _Crest();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: CustomPaint(
        painter: _CrestPainter(),
        child: const Center(
          child: Icon(
            Icons.local_fire_department,
            color: AppColors.primary,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _CrestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = AppColors.primaryDark);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      center,
      radius - 9,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Flourish(),
        const SizedBox(width: AppSpacing.sm),
        Text(
          Strings.appName.toUpperCase(),
          style: AppTextStyles.title.copyWith(
            color: AppColors.background,
            fontSize: 28,
            letterSpacing: 5,
            shadows: const [
              Shadow(
                color: Colors.black45,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const _Flourish(flipped: true),
      ],
    );
  }
}

/// Fading line + diamond ornament that flanks the wordmark like a banner scroll.
class _Flourish extends StatelessWidget {
  final bool flipped;
  const _Flourish({this.flipped = false});

  @override
  Widget build(BuildContext context) {
    final line = Container(
      width: 36,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0), AppColors.primary],
        ),
      ),
    );
    final diamond = Transform.rotate(
      angle: math.pi / 4,
      child: Container(width: 6, height: 6, color: AppColors.primary),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: flipped
          ? [
              diamond,
              const SizedBox(width: 6),
              Transform.flip(flipX: true, child: line),
            ]
          : [line, const SizedBox(width: 6), diamond],
    );
  }
}

class _NavBar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onWorldTap;
  final VoidCallback onCastTap;

  const _NavBar({
    required this.onHomeTap,
    required this.onWorldTap,
    required this.onCastTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _NavLink(label: 'Home', onTap: onHomeTap),
          const _NavDot(),
          _NavLink(label: 'World', onTap: onWorldTap),
          const _NavDot(),
          _NavLink(label: 'Cast', onTap: onCastTap),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 1,
            height: 14,
            color: AppColors.background.withValues(alpha: 0.3),
          ),
          const SizedBox(width: AppSpacing.md),
          const _AuthAction(),
        ],
      ),
    );
  }
}

class _NavDot extends StatelessWidget {
  const _NavDot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: 5,
          height: 5,
          color: AppColors.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.background,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

/// Cuts a scalloped, banner-like edge into the header's bottom so it reads as a
/// carved sign rather than a flat rectangle.
class _ScallopedEdgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const scallopWidth = 26.0;
    const scallopDepth = 10.0;
    final path = Path()..lineTo(0, size.height - scallopDepth);
    final count = (size.width / scallopWidth).ceil();
    for (var i = 0; i < count; i++) {
      final midX = i * scallopWidth + scallopWidth / 2;
      final endX = (i + 1) * scallopWidth;
      path.quadraticBezierTo(
        midX,
        size.height,
        endX,
        size.height - scallopDepth,
      );
    }
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _PlayNowButton extends StatelessWidget {
  const _PlayNowButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 8,
        shadowColor: Colors.black45,
        minimumSize: const Size(210, 58),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: AppColors.primaryDark, width: 3),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl + AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
      ),
      onPressed: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const GameScreen()));
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_arrow_rounded, size: 24),
          const SizedBox(width: AppSpacing.xs),
          Text(
            Strings.btnPlayNow.toUpperCase(),
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSurface extends StatefulWidget {
  final Widget child;
  const _CardSurface({required this.child});

  @override
  State<_CardSurface> createState() => _CardSurfaceState();
}

class _CardSurfaceState extends State<_CardSurface> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.988 : (_hovered ? 1.012 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

class _SectionBanner extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  const _SectionBanner({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(text: eyebrow),
        const SizedBox(height: AppSpacing.sm),
        Text(title, style: AppTextStyles.title.copyWith(fontSize: 34)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: AppTextStyles.body.copyWith(
            fontStyle: FontStyle.italic,
            fontSize: 16,
          ),
        ),
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
        const screenshot = _FramedScreenshot();
        const copy = _HeroCopy();
        final sectionPadding = EdgeInsets.symmetric(
          horizontal: isNarrow ? AppSpacing.md : AppSpacing.xl,
          vertical: isNarrow ? AppSpacing.xl + AppSpacing.sm : AppSpacing.xl,
        );

        return Container(
          width: double.infinity,
          padding: sectionPadding,
          child: isNarrow
              ? const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    copy,
                    SizedBox(height: AppSpacing.xl),
                    Center(child: screenshot),
                  ],
                )
              : const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: copy),
                    SizedBox(width: AppSpacing.xl),
                    Expanded(flex: 2, child: screenshot),
                  ],
                ),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Eyebrow(text: _levelPlates.first.order),
        const SizedBox(height: AppSpacing.sm),
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
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: const [
            _FeatureChip(icon: Icons.map, label: '4 Worlds to Explore'),
            _FeatureChip(icon: Icons.groups, label: '5 Characters to Meet'),
            _FeatureChip(
              icon: Icons.warning_amber_rounded,
              label: "A Story That's Hiding Something",
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _PlayNowButton(),
      ],
    );
  }
}

/// Small uppercase label with a leading gold rule, echoing the header's flourish motif.
class _Eyebrow extends StatelessWidget {
  final String text;
  const _Eyebrow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 24, height: 2, color: AppColors.primaryDark),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

/// Short, punchy hook badge — a scannable selling point instead of a paragraph.
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryDark),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Size-capped screenshot with gold corner brackets and a museum-style caption,
/// so the live gameplay art reads as a framed plate rather than a raw image dump.
class _FramedScreenshot extends StatelessWidget {
  const _FramedScreenshot();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border, width: 3),
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
                ),
                const _CornerBracket(alignment: Alignment.topLeft),
                const _CornerBracket(alignment: Alignment.topRight),
                const _CornerBracket(alignment: Alignment.bottomLeft),
                const _CornerBracket(alignment: Alignment.bottomRight),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Fig. I — Hearth Hollow, live from the build',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final Alignment alignment;
  const _CornerBracket({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    const side = BorderSide(color: AppColors.primary, width: 3);
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border(
              top: isTop ? side : BorderSide.none,
              bottom: !isTop ? side : BorderSide.none,
              left: isLeft ? side : BorderSide.none,
              right: !isLeft ? side : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldSection extends StatelessWidget {
  const _WorldSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < AppBreakpoints.tablet;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: AppColors.primaryDark.withValues(alpha: 0.25),
              ),
              bottom: BorderSide(
                color: AppColors.primaryDark.withValues(alpha: 0.25),
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isNarrow ? AppSpacing.xl + AppSpacing.sm : AppSpacing.xl,
            horizontal: isNarrow ? AppSpacing.md : AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionBanner(
                eyebrow: 'Part One',
                title: Strings.sectionWorldTitle,
                subtitle: Strings.sectionWorldIntro,
              ),
              SizedBox(height: isNarrow ? AppSpacing.lg : AppSpacing.xl),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: [
                  for (final plate in _levelPlates)
                    SizedBox(width: 240, child: _WorldPlaque(plate: plate)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Codex-style select tile inspired by classic RPG world/character-select
/// screens: a carved plaque frame, the art feathered so it fades into the
/// frame instead of ending in a hard rectangle, and just a title + mood line.
class _WorldPlaque extends StatefulWidget {
  final _LevelPlate plate;
  const _WorldPlaque({required this.plate});

  @override
  State<_WorldPlaque> createState() => _WorldPlaqueState();
}

class _WorldPlaqueState extends State<_WorldPlaque> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final plate = widget.plate;
    final borderColor = _hovered ? AppColors.primaryDark : AppColors.border;
    final plaqueShadow = _hovered
        ? const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ]
        : const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ];
    return _CardSurface(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 3),
            boxShadow: plaqueShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (rect) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.transparent,
                          ],
                          stops: [0, 0.7, 1],
                        ).createShader(rect),
                        child: Image.asset(plate.imageAsset, fit: BoxFit.cover),
                      ),
                    ),
                    const _CornerBracket(alignment: Alignment.topLeft),
                    const _CornerBracket(alignment: Alignment.topRight),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.xs,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.rotate(
                          angle: math.pi / 4,
                          child: Container(
                            width: 5,
                            height: 5,
                            color: plate.accent,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(plate.title, style: AppTextStyles.h3),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plate.mood.join(' · ').toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
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

class _CastSection extends StatelessWidget {
  const _CastSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < AppBreakpoints.tablet;
        return Container(
          width: double.infinity,
          color: AppColors.background,
          padding: EdgeInsets.symmetric(
            vertical: isNarrow ? AppSpacing.xl + AppSpacing.sm : AppSpacing.xl,
            horizontal: isNarrow ? AppSpacing.md : AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionBanner(
                eyebrow: 'Part Two',
                title: Strings.sectionCastTitle,
                subtitle: Strings.sectionCastIntro,
              ),
              SizedBox(height: isNarrow ? AppSpacing.md : AppSpacing.lg),
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
      },
    );
  }
}

class _CastCard extends StatefulWidget {
  final _CastMember member;
  const _CastCard({required this.member});

  @override
  State<_CastCard> createState() => _CastCardState();
}

class _CastCardState extends State<_CastCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final roleColor = Color.alphaBlend(
      AppColors.primaryDark.withValues(alpha: 0.28),
      member.accent,
    );

    return _CardSurface(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 260,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? AppColors.primaryDark : AppColors.border,
              width: 1,
            ),
            boxShadow: _hovered
                ? const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
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
                        color: roleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(member.name, style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      member.tagline,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontStyle: FontStyle.italic,
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

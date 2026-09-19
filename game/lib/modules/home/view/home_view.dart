import 'dart:math' as math;

import 'package:game/modules/game/view/game_screen/game_screen.dart';
import 'package:game/resources/app_strings.dart';
import 'package:game/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game/shared/bloc/app/app.dart';

class _LevelPlate {
  final String order;
  final String waypoint;
  final String elevation;
  final String terrain;
  final String atmosphere;
  final String nextLeg;
  final String title;
  final String tagline;
  final List<String> mood;
  final String quote;
  final Color accent;
  final String imageAsset;
  final IconData icon;
  final String threatLevel;
  final Color threatColor;
  final String canopyDensity;
  final String relicItem;
  final String trailTransition;

  const _LevelPlate({
    required this.order,
    required this.waypoint,
    required this.elevation,
    required this.terrain,
    required this.atmosphere,
    required this.nextLeg,
    required this.title,
    required this.tagline,
    required this.mood,
    required this.quote,
    required this.accent,
    required this.imageAsset,
    required this.icon,
    required this.threatLevel,
    required this.threatColor,
    required this.canopyDensity,
    required this.relicItem,
    required this.trailTransition,
  });
}

class _CastMember {
  final String name;
  final String role;
  final String stage;
  final String tagline;
  final String description;
  final Color accent;
  final String imageAsset;
  final String archetype;
  final String relicWeapon;
  final String encounterLocation;
  final String status;

  const _CastMember({
    required this.name,
    required this.role,
    required this.stage,
    required this.tagline,
    required this.description,
    required this.accent,
    required this.imageAsset,
    required this.archetype,
    required this.relicWeapon,
    required this.encounterLocation,
    required this.status,
  });
}

const _levelPlates = [
  _LevelPlate(
    order: 'PLATE I',
    waypoint: 'STAGE 01 · EXPEDITION START',
    elevation: 'ELV. 120M',
    terrain: 'River Basin & Timber Verge',
    atmosphere: 'Wood smoke, warm lantern light, and quiet clearing air.',
    nextLeg: 'Follow the eastern creek up toward the mountain pass →',
    title: 'Hearth Hollow',
    tagline:
        "Golden hour, wood smoke, and a stranger with an axe he hasn't earned yet.",
    mood: ['WARM', 'LOW', 'TRUSTING'],
    quote: 'Nothing here is hiding yet. Every shadow is just a shadow.',
    accent: AppColors.hearthHollow,
    imageAsset: 'assets/images/world_hearth_hollow.png',
    icon: Icons.cabin_rounded,
    threatLevel: 'THREAT: SAFE // OUTPOST',
    threatColor: Color(0xff4ade80),
    canopyDensity: 'CANOPY: 15% · CLEAR CLEARING',
    relicItem: 'RELIC: UNBLESSED IRON AXE',
    trailTransition: '▲ ASCENT +420M · CLIMBING TOWARD WINDWARD ESCARPMENT',
  ),
  _LevelPlate(
    order: 'PLATE II',
    waypoint: 'STAGE 02 · MOUNTAIN ASCENT',
    elevation: 'ELV. 540M',
    terrain: 'High Escarpment & Rock Traverse',
    atmosphere: 'Sharp mountain wind, sheer drops, and thinning vegetation.',
    nextLeg: 'Descend through the fissure into the humid jungle sinkhole →',
    title: 'The Cliffside Path',
    tagline: 'One fire, one flag, one crack of the wrong color in the rock.',
    mood: ['WINDSWEPT', 'THINNING'],
    quote:
        "The world is still real here. It's just started leaving hints that it's tired of being.",
    accent: AppColors.cliffsidePath,
    imageAsset: 'assets/images/world_cliffside_path.png',
    icon: Icons.terrain_rounded,
    threatLevel: 'THREAT: MODERATE // HIGH CRAGS',
    threatColor: Color(0xffeab308),
    canopyDensity: 'CANOPY: 35% · EXPOSED RIDGE',
    relicItem: 'RELIC: SIGNAL FIRE EMBERS',
    trailTransition: '▼ DESCENT -230M · PENETRATING DEEP JUNGLE CANOPY',
  ),
  _LevelPlate(
    order: 'PLATE III',
    waypoint: 'STAGE 03 · DEEP CANOPY DESCENT',
    elevation: 'ELV. 310M',
    terrain: 'Overgrown Jungle & Corrupted Foliage',
    atmosphere: 'Heavy humidity, twisted roots, and fluorescent spore glows.',
    nextLeg: 'Hack through the vine wall toward the sunken stone gate →',
    title: 'The Corrupted Grove',
    tagline:
        'The same trees as before, except now you can see all their edges at once.',
    mood: ['FAMILIAR', 'DOUBLED', 'WRONG'],
    quote: 'Everything here has already happened once. That\'s the problem.',
    accent: AppColors.corruptedGrove,
    imageAsset: 'assets/images/world_corrupted_grove.png',
    icon: Icons.forest_rounded,
    threatLevel: 'THREAT: SEVERE // GLITCH ANOMALY',
    threatColor: Color(0xffef4444),
    canopyDensity: 'CANOPY: 95% · DEEP TANGLE',
    relicItem: 'RELIC: GLITCHED SPORE CORE',
    trailTransition: '❖ SACRED PASSAGE · BREACHING THE SUNKEN SANCTUARY GATE',
  ),
  _LevelPlate(
    order: 'PLATE IV',
    waypoint: 'STAGE 04 · ANCIENT HEART',
    elevation: 'ELV. 680M',
    terrain: 'Forgotten Stone Sanctuary & Sunken Shrine',
    atmosphere: 'Absolute stillness, overgrown stone altars, and glowing relics.',
    nextLeg: 'Journey terminus · Uncover the origin of the glitch.',
    title: 'The Haven',
    tagline:
        "Somewhere that was never built to be found, and doesn't mind that you did.",
    mood: ['HIDDEN', 'PATIENT'],
    quote: "It doesn't need you to believe in it anymore.",
    accent: AppColors.haven,
    imageAsset: 'assets/images/world_haven.png',
    icon: Icons.auto_awesome_rounded,
    threatLevel: 'THREAT: UNKNOWN // ANCIENT CORE',
    threatColor: Color(0xffa855f7),
    canopyDensity: 'CANOPY: 80% · STONE VAULT',
    relicItem: 'RELIC: THE ECHO KEYSTONE',
    trailTransition: '★ EXPEDITION TERMINUS // DISCOVER THE ORIGIN',
  ),
];

const _castMembers = [
  _CastMember(
    name: 'The Traveler',
    role: 'PROTAGONIST // AXE BEARER',
    stage: 'OVERLAND EXPLORER',
    tagline: 'No name, no past given — just a rusty axe and somewhere to be.',
    description:
        'Kept deliberately unfinished — silhouette over detail, so any player can sit inside it. Guided by quiet grit through hostile jungle terrain.',
    accent: AppColors.primary,
    imageAsset: 'assets/images/cast_traveler.png',
    archetype: 'CLASS: WANDERER',
    relicWeapon: 'WEAPON: RUSTED TIMBER AXE',
    encounterLocation: 'SECTOR: HEARTH HOLLOW START',
    status: 'ACTIVE EXPEDITIONER',
  ),
  _CastMember(
    name: 'The Blacksmith',
    role: 'SETTLEMENT ALLY // FORGE MASTER',
    stage: 'STAGE 01 · HEARTH HOLLOW',
    tagline:
        "Warm, loud, and telling you exactly enough to be wrong about somebody.",
    description: "The game's first voice, and its first unreliable one. Anchors the hearth fire and shapes the tools required to survive the journey ahead.",
    accent: AppColors.hearthHollow,
    imageAsset: 'assets/images/cast_blacksmith.png',
    archetype: 'CLASS: CRAFTSMAN',
    relicWeapon: 'EQUIP: HEAVY ANVIL & HAMMER',
    encounterLocation: 'SECTOR: TIMBER FORGE CLEARING',
    status: 'STATIONARY OUTPOST VENDOR',
  ),
  _CastMember(
    name: 'The Forester',
    role: 'TRAIL GUARDIAN // CRAG GUIDE',
    stage: 'STAGE 02 · CLIFFSIDE PATH',
    tagline: "Better they're afraid of an old man in the woods.",
    description:
        'Reads as a threat in silhouette and a guardian up close — same shape, different light. Knows every hidden ledge and switchback up the windward cliffs.',
    accent: AppColors.cliffsidePath,
    imageAsset: 'assets/images/cast_forester.png',
    archetype: 'CLASS: RANGER / SCOUT',
    relicWeapon: 'EQUIP: CARVED COMPASS & QUIVER',
    encounterLocation: 'SECTOR: WINDWARD ESCARPMENT',
    status: 'PATROLLING HIGH RIDGE',
  ),
  _CastMember(
    name: 'Cedric Spooks Queen',
    role: 'THE GAME ALCHEMIST // VANISHED SCHOLAR',
    stage: 'STAGE 03 · CORRUPTED GROVE',
    tagline:
        "Found only in notes, photographs, and the shape of what's missing.",
    description:
        'The one character who was never native to this world. The glitch bleeding into the canopy is where he went — leaving behind unstable alchemical residues.',
    accent: AppColors.corruptedGrove,
    imageAsset: 'assets/images/cast_cedric.png',
    archetype: 'CLASS: ALCHEMIST / GLITCH RESEARCHER',
    relicWeapon: 'EQUIP: CODEX CIPHER & FLASKS',
    encounterLocation: 'SECTOR: ANOMALY EPICENTER',
    status: 'STATUS: DISPLACED // SIGNAL ONLY',
  ),
  _CastMember(
    name: 'The Guardian',
    role: 'SHRINE WARDEN // SENTINEL OF ECHO',
    stage: 'STAGE 04 · THE HAVEN',
    tagline: 'Speaks for a place that was never built to be found.',
    description:
        'No face on purpose — whether this is an Echo of Cedric or an ancient construct of the sunken sanctuary is left an open mystery to be unlocked.',
    accent: AppColors.haven,
    imageAsset: 'assets/images/cast_guardian.png',
    archetype: 'CLASS: ANCIENT CONSTRUCT',
    relicWeapon: 'EQUIP: ECHO RELIC MATRIX',
    encounterLocation: 'SECTOR: SUNKEN SANCTUARY CORE',
    status: 'STATUS: DORMANT // AWAITING CHALLENGE',
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
      body: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: _AmbientMotionOverlay())),
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _EntranceReveal(
                  delay: const Duration(milliseconds: 20),
                  child: _TopHeader(
                    onHomeTap: _scrollToTop,
                    onWorldTap: () => _scrollToSection(_worldKey),
                    onCastTap: () => _scrollToSection(_castKey),
                  ),
                ),
                _EntranceReveal(
                  delay: const Duration(milliseconds: 80),
                  child: _HeroSection(
                    onExploreTap: () => _scrollToSection(_worldKey),
                  ),
                ),
                _EntranceReveal(
                  delay: const Duration(milliseconds: 150),
                  child: _WorldSection(key: _worldKey),
                ),
                _EntranceReveal(
                  delay: const Duration(milliseconds: 220),
                  child: _CastSection(key: _castKey),
                ),
                _EntranceReveal(
                  delay: const Duration(milliseconds: 260),
                  yOffset: 0.015,
                  child: _Footer(
                    onHomeTap: _scrollToTop,
                    onWorldTap: () => _scrollToSection(_worldKey),
                    onCastTap: () => _scrollToSection(_castKey),
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

class _EntranceReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double yOffset;

  const _EntranceReveal({
    required this.child,
    this.delay = Duration.zero,
    this.yOffset = 0.02,
  });

  @override
  State<_EntranceReveal> createState() => _EntranceRevealState();
}

class _EntranceRevealState extends State<_EntranceReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : Offset(0, widget.yOffset),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 380),
        opacity: _visible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}

class _AmbientMotionOverlay extends StatelessWidget {
  const _AmbientMotionOverlay();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _AuthAction extends StatelessWidget {
  const _AuthAction();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final isLoggedIn = state is AppContentLoadedState && state.isLoggedIn;
        return InkWell(
          onTap: () {
            context.read<AppBloc>().add(
              isLoggedIn ? const AppLogoutEvent() : const AppLoginEvent(),
            );
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.45),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLoggedIn ? Icons.lock_open_rounded : Icons.lock_rounded,
                  size: 11,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  (isLoggedIn ? Strings.btnLogout : Strings.btnLogin).toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
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
    return Column(
      children: [
        // Top status ticker
        Container(
          width: double.infinity,
          color: const Color(0xff180d05),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xff4ade80),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'EXPEDITION READY // GODOT 4 WASM',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const _AuthAction(),
            ],
          ),
        ),

        // Main retro title marquee
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff2a180b), Color(0xff3f2512)],
            ),
            border: Border(
              top: BorderSide(color: Color(0xff5a381b), width: 1.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              const _Crest(),
              const SizedBox(height: AppSpacing.sm),
              const _Wordmark(),
              const SizedBox(height: 6),
              Text(
                '❖  AN ACTION-ADVENTURE IN A SHIFTING JUNGLE REALM  ❖',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.2,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _NavBar(
                onHomeTap: onHomeTap,
                onWorldTap: onWorldTap,
                onCastTap: onCastTap,
              ),
            ],
          ),
        ),

        // Retro dentil molding trim
        const _RetroMoldingBar(),
      ],
    );
  }
}

/// Hexagonal crest badge that anchors the wordmark, echoing Hearth Hollow's hearth-fire motif.
class _Crest extends StatefulWidget {
  const _Crest();

  @override
  State<_Crest> createState() => _CrestState();
}

class _CrestState extends State<_Crest> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final pulse = 0.72 + (0.28 * math.sin(t * math.pi * 2));
        final flicker = 0.78 + (0.22 * math.sin((t * math.pi * 2 * 3.1) + 0.5));
        final glow = (pulse * flicker).clamp(0.55, 1.0);

        return SizedBox(
          width: 58,
          height: 58,
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2 * glow),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              CustomPaint(
                painter: _CrestPainter(glow: glow),
                child: Center(
                  child: Icon(
                    Icons.local_fire_department,
                    color: Color.lerp(
                      AppColors.primary,
                      const Color(0xffffd08a),
                      0.35 * glow,
                    ),
                    size: 24,
                    shadows: [
                      Shadow(
                        color: AppColors.primary.withValues(alpha: 0.45 * glow),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CrestPainter extends CustomPainter {
  final double glow;

  _CrestPainter({this.glow = 1});

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
        ..color = AppColors.primary.withValues(alpha: 0.85 + (0.15 * glow))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 + (0.6 * glow),
    );
    canvas.drawCircle(
      center,
      radius - 9,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.34 + (0.22 * glow))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _CrestPainter oldDelegate) {
    return oldDelegate.glow != glow;
  }
}

class _Wordmark extends StatefulWidget {
  const _Wordmark();

  @override
  State<_Wordmark> createState() => _WordmarkState();
}

class _WordmarkState extends State<_Wordmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Flourish(phase: t),
            const SizedBox(width: AppSpacing.sm),
            Text(
              Strings.appName.toUpperCase(),
              style: AppTextStyles.title.copyWith(
                color: AppColors.background,
                fontSize: 32,
                letterSpacing: 6,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _Flourish(flipped: true, phase: t + 0.45),
          ],
        );
      },
    );
  }
}

class _Flourish extends StatelessWidget {
  final bool flipped;
  final double phase;

  const _Flourish({this.flipped = false, this.phase = 0});

  @override
  Widget build(BuildContext context) {
    final wave = math.sin(phase * math.pi * 2);
    final glow = 0.55 + ((wave + 1) * 0.2);
    final drift = 1.2 * wave;

    final line = Container(
      width: 36,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0),
            AppColors.primary.withValues(alpha: glow),
          ],
        ),
      ),
    );

    final diamond = Transform.rotate(
      angle: (math.pi / 4) + (0.07 * wave),
      child: Container(
        width: 6,
        height: 6,
        color: AppColors.primary,
      ),
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: flipped
          ? [
              diamond,
              const SizedBox(width: 6),
              Transform.flip(flipX: true, child: line),
            ]
          : [line, const SizedBox(width: 6), diamond],
    );

    return Transform.translate(
      offset: Offset(flipped ? -drift : drift, 0),
      child: content,
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
      decoration: BoxDecoration(
        color: const Color(0xff1f1207),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primaryDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          _NavLink(index: '01', label: 'HOME', onTap: onHomeTap),
          _NavLink(index: '02', label: 'OVERLAND', onTap: onWorldTap),
          _NavLink(index: '03', label: 'ROSTER', onTap: onCastTap),
          const SizedBox(width: AppSpacing.xs),
          const _NavLaunchButton(),
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String index;
  final String label;
  final VoidCallback onTap;

  const _NavLink({
    required this.index,
    required this.label,
    required this.onTap,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '❖',
                style: TextStyle(
                  color: _hovered ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${widget.index}. ${widget.label}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: _hovered ? const Color(0xffffe8b5) : AppColors.background,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLaunchButton extends StatefulWidget {
  const _NavLaunchButton();

  @override
  State<_NavLaunchButton> createState() => _NavLaunchButtonState();
}

class _NavLaunchButtonState extends State<_NavLaunchButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GameScreen()),
          );
        },
        borderRadius: BorderRadius.circular(3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xffe8a946) : AppColors.primary,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: AppColors.primaryDark,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sports_esports_rounded,
                size: 14,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 5),
              Text(
                'LAUNCH GAME',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RetroMoldingBar extends StatelessWidget {
  const _RetroMoldingBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 12,
      decoration: const BoxDecoration(
        color: Color(0xff231509),
        border: Border(
          top: BorderSide(color: Color(0xff5a381b), width: 1.5),
          bottom: BorderSide(color: AppColors.primaryDark, width: 2),
        ),
      ),
      child: CustomPaint(
        painter: _DentilMoldingPainter(),
      ),
    );
  }
}

class _DentilMoldingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const toothWidth = 8.0;
    const toothGap = 8.0;
    final total = toothWidth + toothGap;
    final count = (size.width / total).ceil();

    final toothPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.35);

    for (var i = 0; i < count; i++) {
      final x = i * total;
      canvas.drawRect(
        Rect.fromLTWH(x, 2, toothWidth, size.height - 4),
        toothPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlayNowButton extends StatefulWidget {
  const _PlayNowButton();

  @override
  State<_PlayNowButton> createState() => _PlayNowButtonState();
}

class _PlayNowButtonState extends State<_PlayNowButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.985 : (_hovered ? 1.015 : 1.0);
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _hovered ? const Color(0xffe8a946) : AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            minimumSize: const Size(200, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: AppColors.primaryDark, width: 2.5),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.sm + AppSpacing.xs,
            ),
          ),
          onHover: (value) => setState(() => _hovered = value),
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const GameScreen()));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow_rounded, size: 22),
              const SizedBox(width: AppSpacing.xs),
              Text(
                Strings.btnPlayNow.toUpperCase(),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
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
    final scale = _pressed ? 0.992 : (_hovered ? 1.008 : 1.0);

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
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

enum _EyebrowMarker { diamond, arrow }

class _Eyebrow extends StatelessWidget {
  final String text;
  final _EyebrowMarker marker;

  const _Eyebrow({
    required this.text,
    this.marker = _EyebrowMarker.diamond,
  });

  @override
  Widget build(BuildContext context) {
    final markerWidget = marker == _EyebrowMarker.arrow
        ? Icon(
            Icons.chevron_right_rounded,
            size: 14,
            color: AppColors.primaryDark.withValues(alpha: 0.78),
          )
        : Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 6,
              height: 6,
              color: AppColors.primary.withValues(alpha: 0.9),
            ),
          );

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
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        markerWidget,
      ],
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
        _Eyebrow(text: eyebrow, marker: _EyebrowMarker.arrow),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.title.copyWith(
            fontSize: 33,
            color: AppColors.primaryDark,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: AppTextStyles.body.copyWith(
            fontStyle: FontStyle.italic,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 1.5,
              color: AppColors.primaryDark.withValues(alpha: 0.65),
            ),
            const SizedBox(width: AppSpacing.xs),
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(width: 6, height: 6, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              width: 38,
              height: 1.5,
              color: AppColors.primaryDark.withValues(alpha: 0.65),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final VoidCallback? onExploreTap;

  const _HeroSection({this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < AppBreakpoints.tablet;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            isNarrow ? AppSpacing.md : AppSpacing.xl,
            AppSpacing.lg,
            isNarrow ? AppSpacing.md : AppSpacing.xl,
            AppSpacing.xl + AppSpacing.md,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Expedition Board Top Trim
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 7,
                      ),
                      color: const Color(0xff231509),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.explore_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'EXPEDITION DISPATCH 001 // SECTOR: HEARTH HOLLOW',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xff4ade80),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'CANOPY ENCOUNTER',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xff4ade80),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Main Content
                    Padding(
                      padding: EdgeInsets.all(
                        isNarrow ? AppSpacing.md : AppSpacing.xl,
                      ),
                      child: isNarrow
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _HeroCopy(onExploreTap: onExploreTap),
                                const SizedBox(height: AppSpacing.xl),
                                const Center(child: _FramedScreenshot()),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _HeroCopy(onExploreTap: onExploreTap),
                                ),
                                const SizedBox(width: AppSpacing.xl),
                                const Expanded(
                                  flex: 6,
                                  child: _FramedScreenshot(),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final VoidCallback? onExploreTap;

  const _HeroCopy({this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;
        final headingSize = isNarrow ? 28.0 : 34.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Eyebrow(
              text: 'MISSION BRIEFING ❖ CHAPTER 01',
              marker: _EyebrowMarker.diamond,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              Strings.heroSectionHeading,
              style: AppTextStyles.title.copyWith(
                fontSize: headingSize,
                color: AppColors.primaryDark,
                letterSpacing: 0.8,
                height: 1.1,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '"Golden hour, wood smoke, and an axe you haven\'t earned yet."',
              style: AppTextStyles.body.copyWith(
                color: AppColors.hearthHollow,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              Strings.heroTagline,
              style: AppTextStyles.body.copyWith(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Retro Spec Readout
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: const [
                _RetroSpecChip(
                  icon: Icons.forest_rounded,
                  label: '04 BIOMES',
                ),
                _RetroSpecChip(
                  icon: Icons.groups_rounded,
                  label: '05 DOSSIERS',
                ),
                _RetroSpecChip(
                  icon: Icons.sports_esports_rounded,
                  label: 'WASD / ARROWS',
                ),
                _RetroSpecChip(
                  icon: Icons.bolt_rounded,
                  label: 'GODOT 4 WASM',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const _PlayNowButton(),
                if (onExploreTap != null)
                  OutlinedButton.icon(
                    onPressed: onExploreTap,
                    icon: const Icon(Icons.explore_rounded, size: 16),
                    label: const Text(
                      'OVERLAND TRAIL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      side: const BorderSide(
                        color: AppColors.primaryDark,
                        width: 1.8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Text(
                  '> ',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTextStyles.fontFamily,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Instant browser launch · No installation required · Desktop & Mobile ready',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _RetroSpecChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RetroSpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primaryDark),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _FramedScreenshot extends StatefulWidget {
  const _FramedScreenshot();

  @override
  State<_FramedScreenshot> createState() => _FramedScreenshotState();
}

class _FramedScreenshotState extends State<_FramedScreenshot> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GameScreen()),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: const Color(0xff1f1207),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? AppColors.primary : AppColors.border,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.32 : 0.18),
                blurRadius: _hovered ? 16 : 10,
                offset: Offset(0, _hovered ? 6 : 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // CRT Header Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 5,
                ),
                color: const Color(0xff2a180b),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xffef4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xffeab308),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xff22c55e),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'MONITOR FEED 01 // OVERWORLD',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'REC ●',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xffef4444),
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              // Screenshot canvas
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/gameplay_screenshot.png',
                      fit: BoxFit.cover,
                    ),
                    const _CornerBracket(alignment: Alignment.topLeft),
                    const _CornerBracket(alignment: Alignment.topRight),
                    const _CornerBracket(alignment: Alignment.bottomLeft),
                    const _CornerBracket(alignment: Alignment.bottomRight),
                    if (_hovered)
                      Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs + 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.primaryDark,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 16,
                                  color: AppColors.textPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'CLICK TO LAUNCH',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // CRT Footer Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 5,
                ),
                color: const Color(0xff2a180b),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fig. I — Hearth Hollow Outpost',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.background.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      '60 FPS // STABLE',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        letterSpacing: 1,
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

class _WorldSection extends StatefulWidget {
  const _WorldSection({super.key});

  @override
  State<_WorldSection> createState() => _WorldSectionState();
}

class _WorldSectionState extends State<_WorldSection> {
  int _activeStage = 0;
  final List<GlobalKey> _stageKeys = List.generate(4, (_) => GlobalKey());

  void _scrollToStage(int index) {
    setState(() => _activeStage = index);
    final context = _stageKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < AppBreakpoints.tablet;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.jungleSurface,
            border: Border(
              top: BorderSide(
                color: AppColors.jungleBorder.withValues(alpha: 0.35),
                width: 2,
              ),
              bottom: BorderSide(
                color: AppColors.jungleBorder.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            isNarrow ? AppSpacing.md : AppSpacing.xl,
            AppSpacing.xl + AppSpacing.md,
            isNarrow ? AppSpacing.md : AppSpacing.xl,
            AppSpacing.xl + AppSpacing.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionBanner(
                    eyebrow: 'Chapter I · Jungle Expedition',
                    title: 'The Overland Journey',
                    subtitle:
                        'From the timber outpost of Hearth Hollow, up the windward cliffs, through the tangled corrupted canopy, and deep toward the ancient haven.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _JungleRouteStrip(
                    activeStage: _activeStage,
                    onSelectStage: _scrollToStage,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _JungleJourneyTrail(
                    isNarrow: isNarrow,
                    stageKeys: _stageKeys,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal interactive expedition route strip showing the 4 waypoints.
class _JungleRouteStrip extends StatelessWidget {
  final int activeStage;
  final ValueChanged<int> onSelectStage;

  const _JungleRouteStrip({
    required this.activeStage,
    required this.onSelectStage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.jungleBorder.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < _levelPlates.length; i++) ...[
              _RouteCheckpointButton(
                plate: _levelPlates[i],
                stepNumber: i + 1,
                isSelected: activeStage == i,
                onTap: () => onSelectStage(i),
              ),
              if (i < _levelPlates.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 2,
                        color: AppColors.jungleLeaf.withValues(alpha: 0.4),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: AppColors.jungleLeaf.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RouteCheckpointButton extends StatefulWidget {
  final _LevelPlate plate;
  final int stepNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const _RouteCheckpointButton({
    required this.plate,
    required this.stepNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_RouteCheckpointButton> createState() => _RouteCheckpointButtonState();
}

class _RouteCheckpointButtonState extends State<_RouteCheckpointButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final plate = widget.plate;
    final selected = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: selected
                ? plate.accent.withValues(alpha: 0.18)
                : (_hovered
                    ? AppColors.surface
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected
                  ? plate.accent
                  : (_hovered
                      ? AppColors.jungleBorder.withValues(alpha: 0.4)
                      : Colors.transparent),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selected ? plate.accent : plate.accent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: plate.accent, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '0${widget.stepNumber}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: selected ? AppColors.background : AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    plate.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${plate.elevation} · ${plate.threatLevel.split(' // ').first}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JungleJourneyTrail extends StatelessWidget {
  final bool isNarrow;
  final List<GlobalKey> stageKeys;

  const _JungleJourneyTrail({
    required this.isNarrow,
    required this.stageKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _levelPlates.length; i++) ...[
          _JungleStationCard(
            key: stageKeys[i],
            plate: _levelPlates[i],
            stepIndex: i,
            isNarrow: isNarrow,
          ),
          if (i < _levelPlates.length - 1)
            _JungleTrailTransitionConnector(
              plate: _levelPlates[i],
              nextPlate: _levelPlates[i + 1],
              isNarrow: isNarrow,
            ),
        ],
      ],
    );
  }
}

/// Comprehensive Expedition Field Plate with CRT bezel and explorer logbook.
class _JungleStationCard extends StatefulWidget {
  final _LevelPlate plate;
  final int stepIndex;
  final bool isNarrow;

  const _JungleStationCard({
    super.key,
    required this.plate,
    required this.stepIndex,
    required this.isNarrow,
  });

  @override
  State<_JungleStationCard> createState() => _JungleStationCardState();
}

class _JungleStationCardState extends State<_JungleStationCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final plate = widget.plate;
    final isNarrow = widget.isNarrow;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hovered ? plate.accent : AppColors.border,
            width: _hovered ? 2.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.18 : 0.08),
              blurRadius: _hovered ? 14 : 8,
              offset: Offset(0, _hovered ? 5 : 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Plaque Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 6,
              ),
              color: const Color(0xff221408),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        plate.icon,
                        size: 15,
                        color: plate.accent,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        plate.waypoint,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: plate.threatColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        plate.threatLevel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: plate.threatColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Card Body (Visual + Explorer Log)
            Padding(
              padding: EdgeInsets.all(isNarrow ? AppSpacing.md : AppSpacing.lg),
              child: isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _StationVisualBlock(plate: plate),
                        const SizedBox(height: AppSpacing.md),
                        _StationLogBlock(plate: plate, isHovered: _hovered),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _StationVisualBlock(plate: plate),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          flex: 6,
                          child: _StationLogBlock(plate: plate, isHovered: _hovered),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationVisualBlock extends StatelessWidget {
  final _LevelPlate plate;

  const _StationVisualBlock({required this.plate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  plate.imageAsset,
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
        // Environmental Telemetry Readouts
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _TelemetryChip(
              icon: Icons.filter_drama_rounded,
              text: plate.elevation,
              accent: plate.accent,
            ),
            _TelemetryChip(
              icon: Icons.nature_rounded,
              text: plate.canopyDensity,
              accent: AppColors.jungleLeaf,
            ),
            _TelemetryChip(
              icon: Icons.vpn_key_rounded,
              text: plate.relicItem,
              accent: AppColors.primaryDark,
            ),
          ],
        ),
      ],
    );
  }
}

class _TelemetryChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color accent;

  const _TelemetryChip({
    required this.icon,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: accent),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 9.5,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StationLogBlock extends StatelessWidget {
  final _LevelPlate plate;
  final bool isHovered;

  const _StationLogBlock({
    required this.plate,
    required this.isHovered,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: plate.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              plate.order,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '· ${plate.terrain.toUpperCase()}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          plate.title,
          style: AppTextStyles.title.copyWith(
            fontSize: 24,
            color: AppColors.primaryDark,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          plate.tagline,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontStyle: FontStyle.italic,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Carved field notebook quote
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(4),
            border: Border(
              left: BorderSide(color: plate.accent, width: 3),
            ),
          ),
          child: Text(
            '"${plate.quote}"',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Field observation note
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.visibility_rounded,
              size: 13,
              color: AppColors.jungleLeaf,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                plate.atmosphere,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Next waypoint trail direction
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.navigation_rounded,
              size: 13,
              color: AppColors.jungleLeaf,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                plate.nextLeg,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.jungleLeaf,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Action & Mood Pills
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              },
              icon: const Icon(Icons.explore_rounded, size: 15),
              label: Text(
                'TRAVERSE ${plate.title.toUpperCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(
                    color: isHovered ? plate.accent : AppColors.primary,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10,
                ),
              ),
            ),
            Wrap(
              spacing: 4,
              children: [
                for (final mood in plate.mood)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      mood,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Organic jungle trail connector between stations.
class _JungleTrailTransitionConnector extends StatelessWidget {
  final _LevelPlate plate;
  final _LevelPlate nextPlate;
  final bool isNarrow;

  const _JungleTrailTransitionConnector({
    required this.plate,
    required this.nextPlate,
    required this.isNarrow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          // Upper connecting vine line
          Container(
            width: 2,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  plate.accent.withValues(alpha: 0.7),
                  AppColors.jungleLeaf.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          // Trail badge pill
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xff1f1207),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.jungleLeaf.withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.route_rounded,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  plate.trailTransition,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xffffe8b5),
                    fontWeight: FontWeight.bold,
                    fontSize: isNarrow ? 9 : 10,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          // Lower connecting vine line
          Container(
            width: 2,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.jungleLeaf.withValues(alpha: 0.5),
                  nextPlate.accent.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CastSection extends StatefulWidget {
  const _CastSection({super.key});

  @override
  State<_CastSection> createState() => _CastSectionState();
}

class _CastSectionState extends State<_CastSection> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < AppBreakpoints.tablet;
        final selected = _castMembers[_selectedIndex];

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.background,
          ),
          padding: EdgeInsets.fromLTRB(
            isNarrow ? AppSpacing.md : AppSpacing.xl,
            AppSpacing.xl + AppSpacing.md,
            isNarrow ? AppSpacing.md : AppSpacing.xl,
            AppSpacing.xl + AppSpacing.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionBanner(
                    eyebrow: 'Chapter II · Expedition Dossier',
                    title: 'Party & Key Personas',
                    subtitle:
                        'Inspect the wanderers, guides, and ancient guardians encountered along the overland expedition.',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  isNarrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _CastMobileSelector(
                              selectedIndex: _selectedIndex,
                              onSelect: (i) => setState(() => _selectedIndex = i),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _CastDossierCard(member: selected),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 360,
                              child: _CastRosterList(
                                selectedIndex: _selectedIndex,
                                onSelect: (i) => setState(() => _selectedIndex = i),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xl),
                            Expanded(
                              child: _CastDossierCard(member: selected),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CastRosterList extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _CastRosterList({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Roster Header Strip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 7,
            ),
            color: const Color(0xff221408),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.groups_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'PARTY SELECT // 05 PROFILES',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
                Text(
                  'ACTIVE',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xff4ade80),
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                for (var i = 0; i < _castMembers.length; i++) ...[
                  _CastRosterEntry(
                    member: _castMembers[i],
                    selected: i == selectedIndex,
                    onTap: () => onSelect(i),
                  ),
                  if (i < _castMembers.length - 1)
                    const SizedBox(height: AppSpacing.xs + 2),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CastRosterEntry extends StatelessWidget {
  final _CastMember member;
  final bool selected;
  final VoidCallback onTap;

  const _CastRosterEntry({
    required this.member,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected
              ? member.accent.withValues(alpha: 0.16)
              : AppColors.surface.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? member.accent : AppColors.border.withValues(alpha: 0.35),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected
                      ? member.accent
                      : AppColors.border.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(member.imageAsset, fit: BoxFit.cover),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: member.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          member.stage.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: member.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.name,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.play_arrow_rounded,
                color: member.accent,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _CastMobileSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _CastMobileSelector({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _castMembers.length; i++) ...[
            InkWell(
              onTap: () => onSelect(i),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: i == selectedIndex
                      ? _castMembers[i].accent.withValues(alpha: 0.22)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: i == selectedIndex
                        ? _castMembers[i].accent
                        : AppColors.border.withValues(alpha: 0.3),
                    width: i == selectedIndex ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        _castMembers[i].imageAsset,
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _castMembers[i].name,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < _castMembers.length - 1)
              const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _CastDossierCard extends StatefulWidget {
  final _CastMember member;

  const _CastDossierCard({required this.member});

  @override
  State<_CastDossierCard> createState() => _CastDossierCardState();
}

class _CastDossierCardState extends State<_CastDossierCard> {
  bool _portraitHovered = false;

  @override
  Widget build(BuildContext context) {
    final member = widget.member;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;

        final portrait = MouseRegion(
          onEnter: (_) => setState(() => _portraitHovered = true),
          onExit: (_) => setState(() => _portraitHovered = false),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isCompact ? double.infinity : 260,
              maxHeight: isCompact ? 300 : 360,
            ),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _portraitHovered ? member.accent : AppColors.border,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: _portraitHovered ? 0.35 : 0.2),
                          blurRadius: _portraitHovered ? 14 : 8,
                          offset: Offset(0, _portraitHovered ? 6 : 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      member.imageAsset,
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
          ),
        );

        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: member.accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: member.accent.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    member.role,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
                Text(
                  member.status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: member.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.5,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              member.name,
              style: AppTextStyles.title.copyWith(
                fontSize: 30,
                color: AppColors.primaryDark,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              member.tagline,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
                fontSize: 15,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Retro Character Specs
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _CharacterSpecTag(
                  icon: Icons.shield_rounded,
                  text: member.archetype,
                  accent: member.accent,
                ),
                _CharacterSpecTag(
                  icon: Icons.hardware_rounded,
                  text: member.relicWeapon,
                  accent: AppColors.primaryDark,
                ),
                _CharacterSpecTag(
                  icon: Icons.location_on_rounded,
                  text: member.encounterLocation,
                  accent: AppColors.jungleLeaf,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 1,
              width: double.infinity,
              color: AppColors.border.withValues(alpha: 0.2),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              member.description,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              },
              icon: const Icon(Icons.sports_esports_rounded, size: 18),
              label: Text(
                'PLAY WITH ${member.name.toUpperCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: member.accent, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        );

        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Dossier Top Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                color: const Color(0xff221408),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.badge_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'EXPEDITION DOSSIER // CLASSIFIED RECORD',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      member.stage,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: member.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.5,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(child: portrait),
                          const SizedBox(height: AppSpacing.lg),
                          details,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          portrait,
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(child: details),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CharacterSpecTag extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color accent;

  const _CharacterSpecTag({
    required this.icon,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: accent),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onWorldTap;
  final VoidCallback? onCastTap;

  const _Footer({
    this.onHomeTap,
    this.onWorldTap,
    this.onCastTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top dentil molding bar to bookend the page layout
        const _RetroMoldingBar(),

        // Main Footer Container
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xff180d05),
            border: Border(
              top: BorderSide(color: Color(0xff3f2512), width: 1.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl + AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main 4-column layout on wide screens, stacked on narrow
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < AppBreakpoints.tablet;
                      final isMobile = constraints.maxWidth < 640;

                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _FooterIdentityBlock(onHomeTap: onHomeTap),
                            const SizedBox(height: AppSpacing.xl),
                            _FooterWaypointsBlock(onWorldTap: onWorldTap),
                            const SizedBox(height: AppSpacing.xl),
                            const _FooterControlsBlock(),
                            const SizedBox(height: AppSpacing.xl),
                            _FooterActionsBlock(
                              onHomeTap: onHomeTap,
                              onCastTap: onCastTap,
                            ),
                          ],
                        );
                      }

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _FooterIdentityBlock(onHomeTap: onHomeTap),
                                ),
                                const SizedBox(width: AppSpacing.xl),
                                Expanded(
                                  child: _FooterWaypointsBlock(onWorldTap: onWorldTap),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(child: _FooterControlsBlock()),
                                const SizedBox(width: AppSpacing.xl),
                                Expanded(
                                  child: _FooterActionsBlock(
                                    onHomeTap: onHomeTap,
                                    onCastTap: onCastTap,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: _FooterIdentityBlock(onHomeTap: onHomeTap),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            flex: 3,
                            child: _FooterWaypointsBlock(onWorldTap: onWorldTap),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          const Expanded(
                            flex: 3,
                            child: _FooterControlsBlock(),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            flex: 3,
                            child: _FooterActionsBlock(
                              onHomeTap: onHomeTap,
                              onCastTap: onCastTap,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl + AppSpacing.md),

                  // Divider with diamond flourish
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: Text(
                          '❖',
                          style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Bottom metadata & retro homage bar
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      Text(
                        '© 2026 TEAM ECHO · PROJECT ECHO ACTION-ADVENTURE',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '100% PURE PIXELS',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '· INSERT COIN TO CONTINUE ·',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterIdentityBlock extends StatelessWidget {
  final VoidCallback? onHomeTap;

  const _FooterIdentityBlock({this.onHomeTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onHomeTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDark,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_fire_department,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                Strings.appName.toUpperCase(),
                style: AppTextStyles.title.copyWith(
                  color: AppColors.background,
                  fontSize: 20,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'An action-adventure set across a shifting jungle frontier. Built with Godot Engine and deployed with Flutter Web CanvasKit.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
            height: 1.45,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _FooterChip(
              icon: Icons.sports_esports_rounded,
              text: 'GODOT 4.3 WASM',
              color: AppColors.primary,
            ),
            _FooterChip(
              icon: Icons.memory_rounded,
              text: 'WEBGL / CANVASKIT',
              color: const Color(0xff4ade80),
            ),
            _FooterChip(
              icon: Icons.volume_up_rounded,
              text: 'WEB AUDIO',
              color: const Color(0xff60a5fa),
            ),
          ],
        ),
      ],
    );
  }
}

class _FooterWaypointsBlock extends StatelessWidget {
  final VoidCallback? onWorldTap;

  const _FooterWaypointsBlock({this.onWorldTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FooterSectionTitle(
          title: 'OVERLAND ROUTE',
          icon: Icons.map_rounded,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < _levelPlates.length; i++) ...[
          InkWell(
            onTap: onWorldTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _levelPlates[i].accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '0${i + 1}. ${_levelPlates[i].title}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _levelPlates[i].elevation,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FooterControlsBlock extends StatelessWidget {
  const _FooterControlsBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _FooterSectionTitle(
          title: 'FIELD CONTROLS',
          icon: Icons.keyboard_rounded,
        ),
        SizedBox(height: AppSpacing.sm),
        _ControlRow(
          keyLabel: 'WASD / ARROWS',
          action: 'Navigate & Climb',
        ),
        SizedBox(height: 5),
        _ControlRow(
          keyLabel: 'SPACE / CLICK',
          action: 'Attack / Interact',
        ),
        SizedBox(height: 5),
        _ControlRow(
          keyLabel: 'ESC / TAB',
          action: 'Codex / Pause',
        ),
      ],
    );
  }
}

class _ControlRow extends StatelessWidget {
  final String keyLabel;
  final String action;

  const _ControlRow({
    required this.keyLabel,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xff2a180b),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Text(
            keyLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 9.5,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            action,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterActionsBlock extends StatelessWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onCastTap;

  const _FooterActionsBlock({
    this.onHomeTap,
    this.onCastTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FooterSectionTitle(
          title: 'EXPEDITION OPS',
          icon: Icons.explore_rounded,
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GameScreen()),
              );
            },
            icon: const Icon(Icons.sports_esports_rounded, size: 16),
            label: const Text(
              'LAUNCH MISSION',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        if (onHomeTap != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onHomeTap,
              icon: const Icon(Icons.arrow_upward_rounded, size: 14),
              label: const Text(
                'RETURN TO SUMMIT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  fontSize: 10.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.background,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 8,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FooterSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _FooterSectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _FooterChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _FooterChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xff221408),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 9,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

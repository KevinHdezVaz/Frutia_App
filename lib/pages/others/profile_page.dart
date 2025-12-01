import 'package:Frutia/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:Frutia/utils/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('assets/images/fondoAppFrutiaVideo.mp4')
          ..initialize().then((_) {
            setState(() {});
            _controller.setLooping(true);
            _controller.play();
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedText(String text,
      {required Duration delay, required Duration duration}) {
    return Text(
      text,
      style: GoogleFonts.lato(
        fontSize: 16,
        color: FrutiaColors.secondaryText,
      ),
    ).animate(delay: delay).custom(
          duration: duration,
          builder: (context, value, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: child,
              ),
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final videoAnimation = (Widget child) => child
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.05, 1.05),
          duration: 5500.ms,
          curve: Curves.easeInOutSine,
        )
        .then()
        .shimmer(
          duration: 5000.ms,
          color: FrutiaColors.accent.withOpacity(0.5),
        );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [FrutiaColors.accent, FrutiaColors.accent2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          l10n.aboutUs,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ).animate().slideY(
              begin: -1,
              end: 0,
              duration: 700.ms,
              curve: Curves.fastOutSlowIn,
            ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondoPantalla1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Center(
                  child: ClipOval(
                    child: videoAnimation(
                      _controller.value.isInitialized
                          ? SizedBox(
                              height: 180,
                              width: 180,
                              child: AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: VideoPlayer(_controller),
                              ),
                            )
                          : Container(
                              height: 180,
                              width: 180,
                              color: Colors.grey,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: FrutiaColors.secondaryBackground.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.ourStory,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: FrutiaColors.accent,
                            ),
                          )
                              .animate()
                              .rotate(
                                begin: -0.05,
                                end: 0,
                                duration: 800.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .slideX(begin: -0.5, end: 0, duration: 800.ms),
                          const Divider(height: 25, thickness: 2),
                          _buildAnimatedText(
                            l10n.ourStoryParagraph1,
                            delay: 400.ms,
                            duration: 2000.ms,
                          ),
                          const SizedBox(height: 16),
                          _buildAnimatedText(
                            l10n.ourStoryParagraph2,
                            delay: 600.ms,
                            duration: 1500.ms,
                          ),
                          const SizedBox(height: 16),
                          _buildAnimatedText(
                            l10n.ourStoryParagraph3,
                            delay: 800.ms,
                            duration: 1000.ms,
                          ),
                          const SizedBox(height: 16),
                          _buildAnimatedText(
                            l10n.ourStoryParagraph4,
                            delay: 1000.ms,
                            duration: 700.ms,
                          ),
                        ],
                      ),
                    ),
                  ).animate().slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 800.ms,
                        curve: Curves.easeOut,
                      ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

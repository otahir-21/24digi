import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChallengeRankingList extends StatelessWidget {
  final double s;
  final List<Map<String, dynamic>> rankings;
  final String currentUserName;
  final String? currentUserAvatarUrl;
  final int currentUserRank;

  const ChallengeRankingList({
    super.key,
    required this.s,
    required this.rankings,
    required this.currentUserName,
    this.currentUserAvatarUrl,
    this.currentUserRank = -1,
  });

  @override
  Widget build(BuildContext context) {
    if (rankings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top #10',
          style: GoogleFonts.inter(
            fontSize: 12 * s,
            color: Colors.white54,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16 * s),
        _buildPodiumFromData(),
        SizedBox(height: 24 * s),
        _buildRankListFromData(),
        SizedBox(height: 8 * s),
        Center(
          child: Text(
            'see more',
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              color: Colors.white38,
            ),
          ),
        ),
        SizedBox(height: 16 * s),
        _buildUserRank(),
      ],
    );
  }

  Widget _buildPodiumFromData() {
    final first = rankings.isNotEmpty ? rankings[0] : null;
    final second = rankings.length > 1 ? rankings[1] : null;
    final third = rankings.length > 2 ? rankings[2] : null;

    return SizedBox(
      height: 240 * s,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (second != null)
            _buildPodiumSpot(
              place: 2,
              height: 140 * s,
              name: second['display_name'] ?? 'User',
              titleColor: Colors.white,
              rankColor: const Color(0xFFC0C0C0),
              avatarAsset: second['avatar_url'] ?? 'assets/fonts/male.png',
              suffix: 'nd',
              tag: '#2',
              isLeft: true,
            ),
          if (first != null)
            _buildPodiumSpot(
              place: 1,
              height: 200 * s,
              name: '', // 1st place doesn't show name below avatar, it shows in the pill
              titleColor: Colors.transparent,
              rankColor: const Color(0xFFFFD700),
              avatarAsset: first['avatar_url'] ?? 'assets/fonts/female.png',
              suffix: 'st',
              tag: first['display_name'] ?? 'Winner',
              isCenter: true,
            ),
          if (third != null)
            _buildPodiumSpot(
              place: 3,
              height: 120 * s,
              name: third['display_name'] ?? 'User',
              titleColor: Colors.white,
              rankColor: const Color(0xFFCD7F32),
              avatarAsset: third['avatar_url'] ?? 'assets/fonts/male.png',
              suffix: 'rd',
              tag: '#3',
              isRight: true,
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumSpot({
    required int place,
    required double height,
    required String name,
    required Color titleColor,
    required Color rankColor,
    required String avatarAsset,
    required String suffix,
    required String tag,
    bool isCenter = false,
    bool isLeft = false,
    bool isRight = false,
  }) {
    final avatarSize = isCenter ? 80 * s : 64 * s;
    final themeGreen = const Color(0xFF00FF88);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withAlpha(50),
                  border: Border.all(color: themeGreen, width: 2 * s),
                  image: DecorationImage(
                    image: AssetImage(avatarAsset),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: -10 * s,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: (isCenter ? 12 : 8) * s,
                    vertical: 3 * s,
                  ),
                  decoration: BoxDecoration(
                    color: themeGreen,
                    borderRadius: BorderRadius.circular(12 * s),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: (isCenter ? 10 : 9) * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          if (name.isNotEmpty)
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            )
          else
            SizedBox(height: 15 * s),
          SizedBox(height: 4 * s),
          Container(
            width: double.infinity,
            height: height - avatarSize,
            decoration: BoxDecoration(
              gradient: isCenter
                  ? null
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        themeGreen.withAlpha(64),
                        themeGreen.withAlpha(0),
                      ],
                    ),
              color: isCenter ? themeGreen : null,
              border: Border(
                top: BorderSide(
                  color: isCenter
                      ? themeGreen
                      : themeGreen.withAlpha(153),
                  width: 2,
                ),
                left: isRight
                    ? BorderSide.none
                    : BorderSide(
                        color: isCenter
                            ? themeGreen
                            : themeGreen.withAlpha(77),
                        width: isCenter ? 0 : 1,
                      ),
                right: isLeft
                    ? BorderSide.none
                    : BorderSide(
                        color: isCenter
                            ? themeGreen
                            : themeGreen.withAlpha(77),
                        width: isCenter ? 0 : 1,
                      ),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 4 * s),
                Stack(
                  children: [
                    if (!isCenter)
                      Positioned(
                        bottom: 4 * s,
                        left: 12 * s,
                        right: 12 * s,
                        child: Container(height: 1 * s, color: rankColor),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$place',
                          style: GoogleFonts.outfit(
                            fontSize: isCenter ? 36 * s : 30 * s,
                            fontWeight: FontWeight.w800,
                            color: isCenter ? Colors.transparent : rankColor,
                            height: 1,
                          ).copyWith(
                            foreground: isCenter
                                ? (Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 2 * s
                                    ..color = const Color(0xFF0D1217))
                                : null,
                          ),
                        ),
                        Text(
                          suffix,
                          style: GoogleFonts.outfit(
                            fontSize: isCenter ? 14 * s : 10 * s,
                            fontWeight: FontWeight.w800,
                            color: isCenter ? const Color(0xFF0D1217) : rankColor,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankListFromData() {
    if (rankings.length < 4) return const SizedBox();
    return Column(
      children: [
        for (int i = 3; i < rankings.length && i < 10; i++)
          Padding(
            padding: EdgeInsets.only(bottom: 8 * s),
            child: _buildRankItem(
              (i + 1).toString().padLeft(2, '0'),
              rankings[i]['display_name'] ?? 'User Name',
              false,
              rankings[i]['avatar_url'] ?? 'assets/fonts/male.png',
            ),
          ),
      ],
    );
  }

  Widget _buildUserRank() {
    return _buildRankItem(
      currentUserRank > 0 ? currentUserRank.toString().padLeft(2, '0') : '24',
      currentUserName,
      true,
      currentUserAvatarUrl ?? 'assets/fonts/male.png',
    );
  }

  Widget _buildRankItem(String rank, String name, bool isUser, String avatarAsset) {
    final themeGreen = const Color(0xFF00FF88);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: isUser ? themeGreen : const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(16 * s),
        border: isUser ? null : Border.all(color: themeGreen, width: 1.5),
        boxShadow: isUser
            ? [
                BoxShadow(
                  color: themeGreen.withAlpha(77),
                  blurRadius: 10 * s,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24 * s,
            child: Text(
              rank,
              style: GoogleFonts.outfit(
                fontSize: 16 * s,
                fontWeight: FontWeight.w700,
                color: isUser ? Colors.black : themeGreen, // In figma rank text inside border is green, User rank is black!
              ),
            ),
          ),
          SizedBox(width: 12 * s),
          Container(
            width: 28 * s,
            height: 28 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white12,
              image: DecorationImage(
                image: AssetImage(avatarAsset),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                fontWeight: FontWeight.w600,
                color: isUser ? Colors.black : themeGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

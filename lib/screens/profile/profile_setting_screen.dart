import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_constants.dart';
import '../../auth/auth_provider.dart';
import '../../api/models/profile_models.dart';
import 'tutorial_screen.dart';
import 'rate_screen.dart';
import 'share_screen.dart';
import 'license_screen.dart';
import 'terms_screen.dart';
import 'privacy_screen.dart';
import 'support_screen.dart';
import 'widgets/profile_top_bar.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;

    if (profile == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1217),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00F0FF))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── TOP HEADER (Logo + Back + Mini Avatar) ──
            const ProfileTopBar(),

            // ── HERO PROFILE ──
            _buildHeroProfile(s, profile),
            SizedBox(height: 16 * s),

            // ── SOCIAL LINKS ──
            _buildSocialLinks(s),
            SizedBox(height: 32 * s),

            // ── SECTIONS ──
            _buildWarriorProfile(s, profile),
            SizedBox(height: 24 * s),

            _buildHealthStats(s, profile),
            SizedBox(height: 24 * s),

            _buildPreferredUnits(s, profile, auth),
            SizedBox(height: 24 * s),

            _buildAlertsReminders(s, profile, auth),
            SizedBox(height: 24 * s),

            _buildDefenseSecurity(s, profile, auth),
            SizedBox(height: 24 * s),

            _buildCommandCenter(s, profile, auth),
            SizedBox(height: 24 * s),

            _buildAppArsenal(s, profile, auth),
            SizedBox(height: 24 * s),

            _buildSupportIntel(s),
            SizedBox(height: 24 * s),

            _buildLegal(s),
            SizedBox(height: 32 * s),

            // ── LOG OUT BUTTON ──
            _buildLogoutButton(s),
            SizedBox(height: 40 * s),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // EDIT DIALOGS
  // ─────────────────────────────────────────────────────────────────

  void _showEditProfileDialog(double s, Profile profile) {
    final nameCtrl = TextEditingController(text: profile.name);
    final dobCtrl = TextEditingController(text: profile.dateOfBirth);
    String? gender = profile.gender;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20 * s),
        child: _buildDialogContent(
          s,
          title: 'Edit Profile',
          icon: Icons.person_outline,
          iconColor: const Color(0xFF00F0FF),
          onSave: () async {
            await context.read<AuthProvider>().updateSettings({
              'name': nameCtrl.text.trim(),
              'date_of_birth': dobCtrl.text.trim(),
              'gender': gender,
            });
            if (mounted) Navigator.pop(context);
          },
          children: [
            _buildDialogTextField(s, 'FULL NAME', nameCtrl),
            // _buildDialogTextField(s, 'EMAIL', TextEditingController(text: profile.email)), // Email typically read only or handled via specialized flow
            // _buildDialogTextField(s, 'PHONE NUMBER', TextEditingController(text: profile.phone)),
            _buildDialogTextField(s, 'DATE OF BIRTH', dobCtrl, hint: 'e.g. 14/08/2000'),
            _buildDialogDropdownField(s, 'GENDER', gender ?? 'Select', (val) => gender = val),
          ],
        ),
      ),
    );
  }

  void _showEditHealthStatsDialog(double s, Profile profile) {
    final heightCtrl = TextEditingController(text: profile.heightCm?.toString());
    final weightCtrl = TextEditingController(text: profile.weightKg?.toString());
    final targetWeightCtrl = TextEditingController(text: profile.targetWeight?.toString());
    String? bloodType = profile.bloodType;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20 * s),
        child: _buildDialogContent(
          s,
          title: 'Edit Health Stats',
          icon: Icons.favorite_border,
          iconColor: const Color(0xFF00F0FF),
          onSave: () async {
             await context.read<AuthProvider>().updateSettings({
              'height_cm': double.tryParse(heightCtrl.text.trim()),
              'weight_kg': double.tryParse(weightCtrl.text.trim()),
              'target_weight': double.tryParse(targetWeightCtrl.text.trim()),
              'blood_type': bloodType,
            });
            if (mounted) Navigator.pop(context);
          },
          children: [
            _buildDialogFieldWithUnit(s, 'HEIGHT', heightCtrl, 'cm'),
            _buildDialogFieldWithUnit(s, 'CURRENT WEIGHT', weightCtrl, 'kg'),
            _buildDialogTextField(s, 'TARGET WEIGHT', targetWeightCtrl),
            _buildDialogDropdownField(s, 'BLOOD TYPE', bloodType ?? 'Select', (val) => bloodType = val),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogContent(
    double s, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
    required VoidCallback onSave,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 30, spreadRadius: 5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20 * s),
              SizedBox(width: 8 * s),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: Colors.white38, size: 18 * s),
              ),
            ],
          ),
          SizedBox(height: 24 * s),
          ...children,
          SizedBox(height: 12 * s),
          GestureDetector(
            onTap: onSave,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14 * s),
              decoration: BoxDecoration(
                color: const Color(0xFF00D186),
                borderRadius: BorderRadius.circular(12 * s),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D186).withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'Save Changes',
                style: GoogleFonts.inter(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(height: 12 * s),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14 * s),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12 * s),
                border: Border.all(color: Colors.white12),
              ),
              alignment: Alignment.center,
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogLabel(double s, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * s),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10 * s,
          fontWeight: FontWeight.w700,
          color: Colors.white38,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDialogTextField(double s, String label, TextEditingController controller, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDialogLabel(s, label),
        Container(
          margin: EdgeInsets.only(bottom: 16 * s),
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 2 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2027),
            borderRadius: BorderRadius.circular(10 * s),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: TextFormField(
            controller: controller,
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12 * s),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDropdownField(double s, String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDialogLabel(s, label),
        Container(
          margin: EdgeInsets.only(bottom: 16 * s),
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 2 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2027),
            borderRadius: BorderRadius.circular(10 * s),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (value == 'Select' || value.isEmpty) ? null : value,
              dropdownColor: const Color(0xFF1B2027),
              hint: const Text('Select', style: TextStyle(color: Colors.white38)),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 16 * s),
              style: GoogleFonts.inter(fontSize: 14 * s, color: Colors.white, fontWeight: FontWeight.w600),
              isExpanded: true,
              items: _getOptionsForLabel(label).map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
                setState(() {}); // refresh dialog state if needed
              },
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getOptionsForLabel(String label) {
    if (label == 'GENDER') return ['Male', 'Female', 'Other'];
    if (label == 'BLOOD TYPE') return ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    return [];
  }

  Widget _buildDialogFieldWithUnit(
    double s,
    String label,
    TextEditingController controller,
    String unit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDialogLabel(s, label),
        Container(
          margin: EdgeInsets.only(bottom: 16 * s),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * s,
                    vertical: 2 * s,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2027),
                    borderRadius: BorderRadius.circular(10 * s),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      fontSize: 14 * s,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12 * s),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12 * s),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * s,
                  vertical: 14 * s,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2027),
                  borderRadius: BorderRadius.circular(10 * s),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Row(
                  children: [
                    Text(
                      unit,
                      style: GoogleFonts.inter(
                        fontSize: 14 * s,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white38,
                      size: 16 * s,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // UI COMPONENTS
  // ─────────────────────────────────────────────────────────────────

  Widget _buildHeroProfile(double s, Profile profile) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 140 * s,
              height: 140 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00F0FF).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            Container(
              width: 120 * s,
              height: 120 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00F0FF), width: 2),
              ),
              child: ClipOval(
                child: profile.profileImage != null && profile.profileImage!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: profile.profileImage!,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Image.asset(
                        profile.gender?.toLowerCase() == 'female' ? 'assets/fonts/female.png' : 'assets/fonts/male.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
              ),
            ),
            Positioned(
              right: 15 * s,
              top: 15 * s,
              child: Container(
                width: 14 * s,
                height: 14 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0D1217), width: 2),
                ),
              ),
            ),
            Positioned(
              bottom: -10 * s,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * s,
                  vertical: 4 * s,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2329),
                  borderRadius: BorderRadius.circular(20 * s),
                  border: Border.all(
                    color: const Color(0xFF00F0FF).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Color(0xFF00F0FF), size: 10),
                    SizedBox(width: 4 * s),
                    Text(
                      'ELITE II',
                      style: GoogleFonts.inter(
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24 * s),
        Text(
          profile.name ?? 'WARRIOR',
          style: GoogleFonts.inter(
            fontSize: 28 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: const Color(0xFF00F0FF),
              size: 14,
            ),
            SizedBox(width: 4 * s),
            Text(
              'Dubai, UAE',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialLinks(double s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(
          s,
          'assets/fonts/insta.png',
          true,
        ), // Use fallback or icon if needed
        SizedBox(width: 16 * s),
        _buildSocialIcon(s, 'assets/fonts/facebook.png', true),
        SizedBox(width: 16 * s),
        _buildSocialIcon(s, 'assets/fonts/share.png', true),
      ],
    );
  }

  Widget _buildSocialIcon(double s, String asset, bool isPlaceholder) {
    return Container(
      width: 40 * s,
      height: 40 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white12),
        color: Colors.white.withOpacity(0.02),
      ),
      child: Center(
        child: Icon(
          Icons.public,
          color: Colors.white54,
          size: 18 * s,
        ), // Placeholder icon
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SECTIONS
  // ─────────────────────────────────────────────────────────────────

  Widget _buildWarriorProfile(double s, Profile profile) {
    return _buildSection(
      s,
      'WARRIOR PROFILE',
      Icons.person_outline,
      const Color(0xFF00F0FF),
      [
        _buildItem(
          s,
          Icons.person_outline,
          const Color(0xFF00F0FF),
          'Full Name',
          subtitle: profile.name ?? 'Not set',
        ),
        _buildItem(
          s,
          Icons.email_outlined,
          const Color(0xFF00F0FF),
          'Email',
          subtitle: 'alex.morgan@email.com', // Placeholder or use profile.email if exists
        ),
        _buildItem(
          s,
          Icons.phone_outlined,
          const Color(0xFF00F0FF),
          'Phone',
          subtitle: '+1 (555) 234-5678',
        ),
        _buildItem(
          s,
          Icons.calendar_today_outlined,
          const Color(0xFF00F0FF),
          'Date of Birth',
          subtitle: profile.dateOfBirth ?? 'Not set',
        ),
        _buildItem(
          s,
          Icons.group_outlined,
          const Color(0xFF00F0FF),
          'Gender',
          subtitle: profile.gender ?? 'Not set',
          showLine: false,
        ),
      ],
      trailingText: 'Edit',
      onTrailingTap: () => _showEditProfileDialog(s, profile),
    );
  }

  Widget _buildHealthStats(double s, Profile profile) {
    return _buildSection(
      s,
      'HEALTH STATS',
      Icons.favorite_border,
      const Color(0xFF00F0FF),
      [
        _buildItem(
          s,
          Icons.height,
          const Color(0xFF00F0FF),
          'Height',
          subtitle: '${profile.heightCm ?? 0} cm',
          trailing: _buildPill('cm', s),
        ),
        _buildItem(
          s,
          Icons.monitor_weight_outlined,
          const Color(0xFF00F0FF),
          'Current Weight',
          subtitle: '${profile.weightKg ?? 0} kg',
          trailing: _buildPill('kg', s),
        ),
        _buildItem(
          s,
          Icons.track_changes,
          const Color(0xFF00F0FF),
          'Target Weight',
          subtitle: '${profile.targetWeight ?? 0} kg',
        ),
        _buildItem(
          s,
          Icons.water_drop_outlined,
          const Color(0xFF00F0FF),
          'Blood Type',
          subtitle: profile.bloodType ?? 'Not set',
          trailing: _buildPill(profile.bloodType ?? '-', s, color: Colors.redAccent),
          showLine: false,
        ),
      ],
      trailingText: 'Edit',
      onTrailingTap: () => _showEditHealthStatsDialog(s, profile),
    );
  }

  Widget _buildPreferredUnits(double s, Profile profile, AuthProvider auth) {
    return _buildSection(
      s,
      'PREFERRED UNITS',
      Icons.settings_overscan,
      const Color(0xFFFFB061),
      [
        _buildItem(
          s,
          Icons.straighten,
          const Color(0xFFFFB061),
          'Distance',
          trailing: _buildToggle('km', 'miles', profile.preferredDistanceUnit == 'km', (isKm) {
             auth.updateSettings({'preferred_distance_unit': isKm ? 'km' : 'miles'});
          }, s),
        ),
        _buildItem(
          s,
          Icons.fitness_center,
          const Color(0xFFFFB061),
          'Weight',
          trailing: _buildToggle('kg', 'lbs', profile.preferredWeightUnit == 'kg', (isKg) {
             auth.updateSettings({'preferred_weight_unit': isKg ? 'kg' : 'lbs'});
          }, s),
        ),
        _buildItem(
          s,
          Icons.thermostat,
          const Color(0xFFFFB061),
          'Temperature',
          trailing: _buildToggle('°C', '°F', profile.preferredTempUnit == '°C', (isC) {
             auth.updateSettings({'preferred_temp_unit': isC ? '°C' : '°F'});
          }, s),
          showLine: false,
        ),
      ],
    );
  }

  Widget _buildAlertsReminders(double s, Profile profile, AuthProvider auth) {
    return _buildSection(
      s,
      'ALERTS & REMINDERS',
      Icons.notifications_none,
      const Color(0xFFB161FF),
      [
        _buildItem(
          s,
          Icons.notifications_active_outlined,
          const Color(0xFFB161FF),
          'Push Notifications',
          subtitle: 'Master toggle for all alerts',
          trailing: _buildSwitch(profile.notificationsEnabled ?? false, (val) {
             auth.updateSettings({'notifications_enabled': val});
          }, s),
        ),
        _buildItem(
          s,
          Icons.directions_run,
          const Color(0xFFB161FF),
          'Activity Reminders',
          subtitle: 'Time to move, warrior!',
          trailing: _buildSwitch(profile.activityRemindersEnabled ?? false, (val) {
             auth.updateSettings({'activity_reminders_enabled': val});
          }, s),
        ),
        _buildItem(
          s,
          Icons.local_drink_outlined,
          const Color(0xFFB161FF),
          'Hydration Reminders',
          subtitle: 'Stay hydrated, stay strong',
          trailing: _buildSwitch(profile.hydrationRemindersEnabled ?? false, (val) {
             auth.updateSettings({'hydration_reminders_enabled': val});
          }, s),
        ),
        _buildItem(
          s,
          Icons.bedtime_outlined,
          const Color(0xFFB161FF),
          'Sleep Reminders',
          subtitle: 'Recovery is key',
          trailing: _buildSwitch(profile.sleepRemindersEnabled ?? false, (val) {
             auth.updateSettings({'sleep_reminders_enabled': val});
          }, s),
        ),
        _buildItem(
          s,
          Icons.bar_chart,
          const Color(0xFFB161FF),
          'Weekly Summary',
          subtitle: 'Your weekly over it report',
          trailing: _buildSwitch(profile.weeklySummaryEnabled ?? false, (val) {
             auth.updateSettings({'weekly_summary_enabled': val});
          }, s),
        ),
        _buildItem(
          s,
          Icons.email_outlined,
          const Color(0xFFB161FF),
          'Email Notifications',
          trailing: _buildSwitch(profile.emailNotificationsEnabled ?? false, (val) {
             auth.updateSettings({'email_notifications_enabled': val});
          }, s),
        ),
        _buildItem(
          s,
          Icons.volume_up_outlined,
          const Color(0xFFB161FF),
          'Notification Sound',
          subtitle: 'Default',
          trailing: _buildDropdown('Default', s),
        ),
        _buildItem(
          s,
          Icons.do_not_disturb_alt,
          const Color(0xFFB161FF),
          'Quiet Hours',
          subtitle: '22:00 - 07:00',
          trailing: _buildSwitch(profile.quietHoursEnabled ?? false, (val) {
             auth.updateSettings({'quiet_hours_enabled': val});
          }, s),
          showLine: false,
        ),
      ],
    );
  }

  Widget _buildDefenseSecurity(double s, Profile profile, AuthProvider auth) {
    return _buildSection(
      s,
      'DEFENSE & SECURITY',
      Icons.security,
      const Color(0xFF00B2FF),
      [
        GestureDetector(
          onTap: () => _showComingSoon(context, 'Change Password'),
          child: _buildItem(
            s,
            Icons.lock_outline,
            const Color(0xFF00B2FF),
            'Change Password',
            trailing: _buildChevron(s),
          ),
        ),
        GestureDetector(
          onTap: () => _showComingSoon(context, 'Email Verification'),
          child: _buildItem(
            s,
            Icons.verified_user_outlined,
            const Color(0xFF00B2FF),
            'Email Verification',
            trailing: _buildVerifiedPill(s),
          ),
        ),
        GestureDetector(
          onTap: () => _showComingSoon(context, 'Two-Factor Authentication'),
          child: _buildItem(
            s,
            Icons.shield_outlined,
            const Color(0xFF00B2FF),
            'Two-Factor Auth',
            subtitle: 'Shield down',
            trailing: _buildSwitch(false, (val) {}, s),
          ),
        ),
        _buildItem(
          s,
          Icons.face,
          const Color(0xFF00B2FF),
          'Face ID / Touch ID',
          trailing: _buildSwitch(profile.faceIdEnabled ?? false, (val) {
             auth.updateSettings({'face_id_enabled': val});
          }, s),
        ),
        _buildItem(
          s,
          Icons.fingerprint,
          const Color(0xFF00B2FF),
          'App Lock',
          subtitle: 'Pin or Biometric',
          trailing: _buildSwitch(profile.appLockEnabled ?? false, (val) {
             auth.updateSettings({'app_lock_enabled': val});
          }, s),
        ),
        _buildItem(
          s,
          Icons.privacy_tip_outlined,
          const Color(0xFF00B2FF),
          'Data & Privacy',
          trailing: _buildChevron(s),
        ),
        _buildItem(
          s,
          Icons.link,
          const Color(0xFF00B2FF),
          'Connected Apps',
          subtitle: 'Manage integrations',
          trailing: _buildChevron(s),
          showLine: false,
        ),
      ],
    );
  }

  Widget _buildCommandCenter(double s, Profile profile, AuthProvider auth) {
    return _buildSection(
      s,
      'COMMAND CENTER',
      Icons.settings_input_component,
      const Color(0xFFFFB061),
      [
        _buildItem(
          s,
          Icons.language,
          const Color(0xFFFFB061),
          'Language',
          trailing: _buildToggle('English', 'Arabic', profile.language != 'Arabic', (isEng) {
             auth.updateSettings({'language': isEng ? 'English' : 'Arabic'});
          }, s),
        ),
        _buildItem(
          s,
          Icons.access_time,
          const Color(0xFFFFB061),
          'Time Zone',
          subtitle: profile.timezone ?? 'Auto-detected (UTC+4)',
          trailing: _buildChevron(s),
        ),
        _buildItem(
          s,
          Icons.calendar_month,
          const Color(0xFFFFB061),
          'Date Format',
          trailing: _buildToggle('DD/MM', 'MM/DD', profile.dateFormat != 'MM/DD', (isDD) {
             auth.updateSettings({'date_format': isDD ? 'DD/MM' : 'MM/DD'});
          }, s),
        ),
        _buildItem(
          s,
          Icons.schedule,
          const Color(0xFFFFB061),
          'Time Format',
          trailing: _buildToggle('12h', '24h', profile.timeFormat != '24h', (is12) {
             auth.updateSettings({'time_format': is12 ? '12h' : '24h'});
          }, s),
        ),
        _buildItem(
          s,
          Icons.cloud_sync_outlined,
          const Color(0xFFFFB061),
          'Data Backup',
          subtitle: 'Auto sync enabled',
          trailing: Row(
            children: [
              Text(
                'Sync',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFFB061),
                  fontSize: 10 * s,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8 * s),
              _buildSwitch(profile.reminderEnabled ?? true, (val) {
                 auth.updateSettings({'reminder_enabled': val}); // using reminder_enabled as placeholder for sync
              }, s),
            ],
          ),
        ),
        _buildItem(
          s,
          Icons.download_outlined,
          const Color(0xFFFFB061),
          'Download My Data',
          subtitle: 'GDPR compliance',
          trailing: _buildChevron(s),
        ),
        _buildItem(
          s,
          Icons.delete_outline,
          Colors.redAccent,
          'Delete Account',
          subtitle: 'Permanently delete your account and data',
          isDestructive: true,
          showLine: false,
        ),
      ],
    );
  }

  Widget _buildAppArsenal(double s, Profile profile, AuthProvider auth) {
    return _buildSection(
      s,
      'APP ARSENAL',
      Icons.rocket_launch_outlined,
      const Color(0xFFFF61A6),
      [
        _buildItem(
          s,
          Icons.palette_outlined,
          const Color(0xFFFF61A6),
          'Theme',
          trailing: _buildThemeToggle(profile.theme ?? 'Dark', (val) {
             auth.updateSettings({'theme': val});
          }, s),
        ),
        _buildItem(
          s,
          Icons.vibration,
          const Color(0xFFFF61A6),
          'Haptic Feedback',
          trailing: _buildSwitch(profile.hapticEnabled ?? true, (val) {
             auth.updateSettings({'haptic_enabled': val});
          }, s),
        ),
        _buildItem(
          s,
          Icons.animation,
          const Color(0xFFFF61A6),
          'Animation Effects',
          subtitle: 'Reduce motion',
          trailing: _buildSwitch(profile.animationsEnabled ?? false, (val) {
             auth.updateSettings({'animations_enabled': val});
          }, s),
        ),
        _buildItem(
          s,
          Icons.home_outlined,
          const Color(0xFFFF61A6),
          'Default Home Tab',
          trailing: _buildDropdown('Home', s),
        ),
        _buildItem(
          s,
          Icons.delete_sweep_outlined,
          const Color(0xFFFF61A6),
          'Clear Cache',
          subtitle: 'Frees up 45 MB',
          trailing: _buildPill('Clear', s, color: const Color(0xFFFF61A6)),
        ),
        _buildItem(
          s,
          Icons.sd_storage_outlined,
          const Color(0xFFFF61A6),
          'Storage Used',
          subtitle: 'App using 234 MB',
          showLine: false,
        ),
      ],
    );
  }

  Widget _buildSupportIntel(double s) {
    return _buildSection(
      s,
      'SUPPORT & INTEL',
      Icons.headset_mic_outlined,
      const Color(0xFFFFB061),
      [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SupportScreen()),
            );
          },
          child: _buildItem(
            s,
            Icons.help_outline,
            const Color(0xFFFFB061),
            'Help Center',
            trailing: _buildChevron(s),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SupportScreen()),
            );
          },
          child: _buildItem(
            s,
            Icons.support_agent,
            const Color(0xFFFFB061),
            'Contact Support',
            trailing: _buildChevron(s),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TutorialScreen()),
            );
          },
          child: _buildItem(
            s,
            Icons.play_circle_outline,
            const Color(0xFFFFB061),
            'Tutorial',
            subtitle: 'Replay getting started guide',
            trailing: _buildChevron(s),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RateScreen()),
            );
          },
          child: _buildItem(
            s,
            Icons.star_outline,
            const Color(0xFFFFB061),
            'Rate 24DIGI',
            trailing: _buildChevron(s),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShareScreen()),
            );
          },
          child: _buildItem(
            s,
            Icons.share_outlined,
            const Color(0xFFFFB061),
            'Share 24DIGI',
            trailing: _buildChevron(s),
            showLine: false,
          ),
        ),
      ],
    );
  }

  Widget _buildLegal(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(s, 'LEGAL', null, null, [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              );
            },
            child: _buildItem(
              s,
              Icons.privacy_tip_outlined,
              const Color(0xFFFFB061),
              'Privacy Policy',
              trailing: _buildChevron(s),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              );
            },
            child: _buildItem(
              s,
              Icons.description_outlined,
              const Color(0xFFFFB061),
              'Terms of Service',
              trailing: _buildChevron(s),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LicenseScreen()),
              );
            },
            child: _buildItem(
              s,
              Icons.workspace_premium_outlined,
              const Color(0xFFFFB061),
              'Licenses & Credits',
              trailing: _buildChevron(s),
              showLine: false,
            ),
          ),
        ]),
        SizedBox(height: 16 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white24, size: 12),
              SizedBox(width: 8 * s),
              Text(
                'v1.0.0 - Build 202',
                style: GoogleFonts.inter(
                  fontSize: 10 * s,
                  color: Colors.white24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(double s) {
    return GestureDetector(
      onTap: () async {
        await context.read<AuthProvider>().logout();
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24 * s),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16 * s),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.redAccent, size: 18),
            SizedBox(width: 8 * s),
            Text(
              'Log Out',
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────

  Widget _buildSection(
    double s,
    String title,
    IconData? headerIcon,
    Color? headerColor,
    List<Widget> items, {
    String? trailingText,
    VoidCallback? onTrailingTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 12 * s),
          child: Row(
            children: [
              if (headerIcon != null) ...[
                Icon(headerIcon, color: headerColor, size: 14 * s),
                SizedBox(width: 8 * s),
              ],
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white54,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (trailingText != null)
                GestureDetector(
                  onTap: onTrailingTap,
                  child: Text(
                    trailingText,
                    style: GoogleFonts.inter(
                      fontSize: 11 * s,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00F0FF),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF13181D),
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildItem(
    double s,
    IconData icon,
    Color iconColor,
    String title, {
    String? subtitle,
    Widget? trailing,
    bool isDestructive = false,
    bool showLine = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 16 * s),
      decoration: BoxDecoration(
        border: showLine
            ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * s),
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.redAccent.withOpacity(0.1)
                  : iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10 * s),
            ),
            child: Icon(
              icon,
              color: isDestructive ? Colors.redAccent : iconColor,
              size: 18 * s,
            ),
          ),
          SizedBox(width: 16 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? Colors.redAccent : Colors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4 * s),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11 * s,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildToggle(String opt1, String opt2, bool isOpt1, ValueChanged<bool> onChanged, double s) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onChanged(true),
            child: _buildToggleOption(opt1, isOpt1, s),
          ),
          GestureDetector(
            onTap: () => onChanged(false),
            child: _buildToggleOption(opt2, !isOpt1, s),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(String currentTheme, ValueChanged<String> onChanged, double s) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(onTap: () => onChanged('Light'), child: _buildToggleOption('Light', currentTheme == 'Light', s)),
          GestureDetector(onTap: () => onChanged('Dark'), child: _buildToggleOption('Dark', currentTheme == 'Dark', s)),
          GestureDetector(onTap: () => onChanged('Auto'), child: _buildToggleOption('Auto', currentTheme == 'Auto', s)),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String text, bool active, double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF00F0FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10 * s,
          fontWeight: FontWeight.w700,
          color: active ? Colors.black : Colors.white54,
        ),
      ),
    );
  }

  Widget _buildSwitch(bool value, ValueChanged<bool> onChanged, double s) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 44 * s,
        height: 24 * s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * s),
          color: value ? const Color(0xFF00F0FF) : Colors.white.withOpacity(0.1),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20 * s,
            height: 20 * s,
            margin: EdgeInsets.all(2 * s),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(
    String text,
    double s, {
    Color color = const Color(0xFF00F0FF),
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10 * s,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildVerifiedPill(double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: Color(0xFF4CAF50), size: 12),
          SizedBox(width: 4 * s),
          Text(
            'Verified',
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String text, double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8 * s),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white54,
            size: 16,
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D1217),
        title: Text(feature, style: GoogleFonts.outfit(color: Colors.white)),
        content: Text('This feature is currently being tacticaly deployed. High command will notify you once it\'s available.', 
          style: GoogleFonts.inter(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ACKNOWLEDGED', style: TextStyle(color: Color(0xFF00F0FF))),
          ),
        ],
      ),
    );
  }

  Widget _buildChevron(double s) {
    return Icon(Icons.chevron_right, color: Colors.white24, size: 18 * s);
  }
}

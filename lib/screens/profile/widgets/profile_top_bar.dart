// This file is kept for backward compatibility.
// All screens now use DigiPillHeader from lib/widgets/digi_pill_header.dart.
// ProfileTopBar simply delegates to DigiPillHeader.
export 'package:kivi_24/widgets/digi_pill_header.dart' show DigiPillHeader;

import 'package:flutter/material.dart';
import 'package:kivi_24/widgets/digi_pill_header.dart';

class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({super.key});

  @override
  Widget build(BuildContext context) => const DigiPillHeader();
}

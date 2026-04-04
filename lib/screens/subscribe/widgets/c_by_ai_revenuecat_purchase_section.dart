import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/api_config.dart';
import '../../../subscriptions/revenuecat_service.dart';

/// Real App Store / Play purchase + restore for C BY AI (RevenueCat).
/// Shown on the subscription screen when RevenueCat is configured.
class CByAiRevenueCatPurchaseSection extends StatefulWidget {
  const CByAiRevenueCatPurchaseSection({super.key});

  @override
  State<CByAiRevenueCatPurchaseSection> createState() =>
      _CByAiRevenueCatPurchaseSectionState();
}

class _CByAiRevenueCatPurchaseSectionState
    extends State<CByAiRevenueCatPurchaseSection> {
  bool _busy = false;

  Future<void> _subscribe() async {
    if (_busy || !RevenueCatService.isConfigured) return;
    setState(() => _busy = true);
    try {
      final result = await RevenueCatService.purchaseCByAiPackage();
      if (!mounted) return;
      if (result != null &&
          result.customerInfo.entitlements.active
              .containsKey(ApiConfig.revenueCatCByAiEntitlementId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('C BY AI subscription is active.')),
        );
      }
    } on StateError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Purchase failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    if (_busy || !RevenueCatService.isConfigured) return;
    setState(() => _busy = true);
    try {
      final info = await RevenueCatService.restorePurchases();
      if (!mounted) return;
      final ok = info.entitlements.active
          .containsKey(ApiConfig.revenueCatCByAiEntitlementId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Purchases restored. C BY AI is active.'
                : 'No active C BY AI subscription found.',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!RevenueCatService.isConfigured) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'C BY AI — subscribe',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFEAF2F5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Use your App Store or Google Play account. Entitlement: ${ApiConfig.revenueCatCByAiEntitlementId}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF7A8A94),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : _subscribe,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00F0FF),
            foregroundColor: const Color(0xFF0A0C0E),
          ),
          child: _busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Subscribe to C BY AI'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _busy ? null : _restore,
          child: Text(
            'Restore purchases',
            style: GoogleFonts.inter(
              color: const Color(0xFF00F0FF),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

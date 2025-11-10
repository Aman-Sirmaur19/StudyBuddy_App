import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../secrets.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() => _instance;

  AdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  int _navigationCount = 0;

  void initialize() {
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Secrets.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;

          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isAdLoaded = false;
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              log('Ad failed to show: ${error.message}');
              ad.dispose();
              _isAdLoaded = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          log('Failed to load interstitial ad: ${error.message}');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void incrementNavigationCount() {
    _navigationCount++;
    if (_navigationCount >= 5) {
      showInterstitialAd();
      _navigationCount = 0;
    }
  }

  void showInterstitialAd() {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
      _isAdLoaded = false;
      _interstitialAd = null;
    }
  }

  void navigateWithAd(BuildContext context, Widget page) {
    AdManager().incrementNavigationCount();
    Navigator.push(context, CupertinoPageRoute(builder: (_) => page));
  }
}

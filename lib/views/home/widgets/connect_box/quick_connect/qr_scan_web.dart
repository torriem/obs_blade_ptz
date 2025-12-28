import 'package:flutter/cupertino.dart';
import 'package:obs_blade/shared/general/themed/cupertino_button.dart';
import 'package:obs_blade/shared/general/transculent_cupertino_navbar_wrapper.dart';

class QRScan extends StatelessWidget {
  const QRScan({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TransculentCupertinoNavBarWrapper(
      title: 'Quick Connect',
      actions: ThemedCupertinoButton(
        padding: const EdgeInsets.all(0),
        text: 'Close',
        onPressed: () => Navigator.of(context).pop(),
      ),
      customBody: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.xmark_circle,
                size: 64,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 24),
              Text(
                'QR Scanner Not Available',
                style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'QR code scanning is only available on mobile devices (iOS and Android).',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please use manual connection entry instead.',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

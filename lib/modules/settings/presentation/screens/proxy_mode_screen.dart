import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:defyx_vpn/shared/providers/connection_state_provider.dart';
import 'package:defyx_vpn/shared/layout/main_screen_background.dart';
import '../../providers/proxy_mode_provider.dart';

class ProxyModeScreen extends ConsumerWidget {
  const ProxyModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionStateProvider);
    final proxyMode = ref.watch(proxyModeProvider);
    final proxyNotifier = ref.read(proxyModeProvider.notifier);

    return MainScreenBackground(
      connectionStatus: connectionState.status,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 393.w),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  _buildHeader(context),
                  SizedBox(height: 20.h),
                  _buildDescription(),
                  SizedBox(height: 40.h),
                  _buildProxyModeOptions(proxyMode, proxyNotifier),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'Proxy Mode',
          style: TextStyle(
            fontSize: 28.sp,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            color: const Color(0xFFFFC927),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      'Choose how V2Ray should handle network traffic',
      style: TextStyle(
        fontSize: 14.sp,
        fontFamily: 'Lato',
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildProxyModeOptions(
      ProxyModeType currentMode, ProxyModeNotifier notifier) {
    final modes = [
      {
        'type': ProxyModeType.vpnMode,
        'title': 'VPN Mode',
        'description': 'Full system-wide VPN. All traffic goes through V2Ray',
        'icon': '🛡️',
      },
      {
        'type': ProxyModeType.proxyOnly,
        'title': 'Proxy Only',
        'description':
            'Apps must support proxy settings. More battery efficient',
        'icon': '🔌',
      },
      {
        'type': ProxyModeType.split,
        'title': 'Split Tunneling',
        'description': 'Route traffic based on bypassed apps list',
        'icon': '↔️',
      },
    ];

    return Column(
      children: modes.map((mode) {
        final modeType = mode['type'] as ProxyModeType;
        final isSelected = currentMode == modeType;

        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFC927).withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFFC927)
                  : Colors.white.withOpacity(0.2),
              width: isSelected ? 3 : 2,
            ),
          ),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            leading: Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFC927).withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: Text(
                  mode['icon'] as String,
                  style: TextStyle(fontSize: 32.sp),
                ),
              ),
            ),
            title: Text(
              mode['title'] as String,
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                color: isSelected ? const Color(0xFFFFC927) : Colors.white,
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                mode['description'] as String,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.6),
                  height: 1.4,
                ),
              ),
            ),
            trailing: Radio<ProxyModeType>(
              value: modeType,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  notifier.setProxyMode(value);
                }
              },
              activeColor: const Color(0xFFFFC927),
            ),
            onTap: () {
              notifier.setProxyMode(modeType);
            },
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:defyx_vpn/shared/providers/connection_state_provider.dart';
import 'package:defyx_vpn/shared/layout/main_screen_background.dart';
import 'package:defyx_vpn/core/services/device_apps_service.dart';
import '../../providers/app_bypass_provider.dart';

class AppBypassScreen extends ConsumerStatefulWidget {
  const AppBypassScreen({super.key});

  @override
  ConsumerState<AppBypassScreen> createState() => _AppBypassScreenState();
}

class _AppBypassScreenState extends ConsumerState<AppBypassScreen> {
  List<InstalledApp> _installedApps = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  Future<void> _loadInstalledApps() async {
    setState(() => _isLoading = true);

    final apps = await DeviceAppsService.getUserApps();

    setState(() {
      _installedApps = apps;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    final bypassedApps = ref.watch(appBypassProvider);
    final bypassNotifier = ref.read(appBypassProvider.notifier);

    return MainScreenBackground(
      connectionStatus: connectionState.status,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 393.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                _buildHeader(context),
                SizedBox(height: 20.h),
                _buildDescription(),
                SizedBox(height: 10.h),
                _buildSearchBar(),
                SizedBox(height: 20.h),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _buildAppList(bypassedApps, bypassNotifier),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
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
            'App Bypass',
            style: TextStyle(
              fontSize: 28.sp,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFC927),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text(
        'Select apps that should bypass VPN and use direct connection',
        style: TextStyle(
          fontSize: 14.sp,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search apps...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: const Color(0xFFFFC927),
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading installed apps...',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppList(Set<String> bypassedApps, AppBypassNotifier notifier) {
    // فیلتر برنامه‌ها بر اساس جستجو
    final filteredApps = _installedApps.where((app) {
      if (_searchQuery.isEmpty) return true;
      return app.appName.toLowerCase().contains(_searchQuery) ||
          app.packageName.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredApps.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? 'No apps installed'
              : 'No apps found matching "$_searchQuery"',
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: filteredApps.length,
      itemBuilder: (context, index) {
        final app = filteredApps[index];
        final isBypassed = bypassedApps.contains(app.packageName);

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isBypassed
                  ? const Color(0xFFFFC927)
                  : Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: DeviceAppsService.createAppIcon(
                  app.icon,
                  size: 48.w,
                ),
              ),
            ),
            title: Text(
              app.appName,
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              app.packageName,
              style: TextStyle(
                fontSize: 11.sp,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Switch(
              value: isBypassed,
              onChanged: (value) {
                if (value) {
                  notifier.addBypassedApp(app.packageName);
                } else {
                  notifier.removeBypassedApp(app.packageName);
                }
              },
              activeColor: const Color(0xFFFFC927),
              activeTrackColor: const Color(0xFFFFC927).withOpacity(0.5),
            ),
          ),
        );
      },
    );
  }
}

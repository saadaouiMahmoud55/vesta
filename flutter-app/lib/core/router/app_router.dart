import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/auth/email_verification_banner.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/require_sign_in.dart';
import '../../features/auth/sign_up_screen.dart';
import '../../features/chat/chat_controller.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/listings/listing_detail_screen.dart';
import '../../features/listings/listings_screen.dart';
import '../../features/listings/publish_listing_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/onboarding/onboarding_controller.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/profile_controller.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/ui_kit_screen.dart';

abstract class AppRoutes {
  static const explore = '/';
  static const onboarding = '/onboarding';
  static const search = '/search';
  static const map = '/map';
  static const favorites = '/favorites';
  static const profile = '/profile';
  static const login = '/login';
  static const signup = '/signup';
  static const chat = '/chat';
  static const chatRoom = '/chat/:conversationId';
  static const notifications = '/notifications';
  static const publish = '/publish';
  static const editProfile = '/profile/edit';
  static const settings = '/settings';

  /// Debug only: every shared widget on one screen (VST-93).
  static const uiKit = '/ui-kit';
  static const listingDetail = '/listing/:id';

  static String listingDetailPath(String id) => '/listing/$id';
  static String chatRoomPath(String conversationId) => '/chat/$conversationId';
}

/// Pages that need an account. A guest never reaches them from the UI (the
/// buttons use `requireSignIn`); this is the safety net for a direct link.
const _accountOnlyRoutes = {
  AppRoutes.publish,
  AppRoutes.chat,
  AppRoutes.notifications,
  AppRoutes.editProfile,
};

/// Router for guest browsing (VST-72): everybody opens the app on the home
/// screen and can use the tabs. Login and Sign up are pushed on top of the
/// current screen by `requireSignIn`, so after signing in the user is back
/// where he was.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (previous, next) => refresh.value++);
  ref.listen(onboardingSeenProvider, (previous, next) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.explore,
    refreshListenable: refresh,
    redirect: (context, state) {
      // First launch only (VST-99): the 3 onboarding screens, then the home.
      final onboardingSeen = ref.read(onboardingSeenProvider);
      final inOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!onboardingSeen && !inOnboarding) return AppRoutes.onboarding;
      if (onboardingSeen && inOnboarding) return AppRoutes.explore;
      final auth = ref.read(authStateProvider);
      if (auth.isLoading) return null; // wait for the first auth state
      final signedIn = auth.value != null;
      final location = state.matchedLocation;
      final accountOnly = _accountOnlyRoutes.contains(location) ||
          location.startsWith('${AppRoutes.chat}/');
      if (!signedIn && accountOnly) {
        return AppRoutes.explore;
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) => const ListingsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.search,
              builder: (context, state) => const SearchScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.map,
              builder: (context, state) => const MapScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.favorites,
              builder: (context, state) => const FavoritesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const _SubPage(child: LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const _SubPage(child: SignUpScreen()),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => _SubPage(
          title: AppLocalizations.of(context).chatTitle,
          child: const ChatListScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.chatRoom,
        builder: (context, state) => _SubPage(
          child: ChatScreen(
            conversationId: state.pathParameters['conversationId']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) =>
            const _SubPage(child: NotificationsScreen()),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => _SubPage(
          title: AppLocalizations.of(context).settingsTitle,
          child: const SettingsScreen(),
        ),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.uiKit,
          builder: (context, state) => const UiKitScreen(),
        ),
      GoRoute(
        path: AppRoutes.publish,
        builder: (context, state) => const PublishListingScreen(),
      ),
      // Details of one listing, open to guests (VST-72).
      GoRoute(
        path: AppRoutes.listingDetail,
        builder: (context, state) => _SubPage(
          child: ListingDetailScreen(listingId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => Consumer(
          builder: (context, ref, _) {
            final profile = ref.watch(myProfileProvider).value;
            if (profile == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return EditProfileScreen(profile: profile);
          },
        ),
      ),
    ],
  );
});

/// Bottom navigation shared by the 5 main tabs.
class _MainShell extends ConsumerWidget {
  const _MainShell({required this.shell});

  final StatefulNavigationShell shell;

  /// Chat and notifications need an account: a guest gets the sign-in sheet,
  /// then the screen opens once he is signed in.
  Future<void> _openAccountPage(
      BuildContext context, WidgetRef ref, String route) async {
    if (!await requireSignIn(context, ref)) return;
    if (context.mounted) context.push(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final titles = [
      l10n.tabExplore,
      l10n.tabSearch,
      l10n.tabMap,
      l10n.tabFavorites,
      l10n.tabProfile,
    ];

    final unread = ref.watch(unreadTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[shell.currentIndex]),
        actions: [
          IconButton(
            // Red number when somebody wrote to me (VST-44).
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            tooltip: l10n.chatTitle,
            onPressed: () => _openAccountPage(context, ref, AppRoutes.chat),
          ),
          IconButton(
            // Same red number as the chat icon: messages to read.
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              child: const Icon(Icons.notifications_none),
            ),
            tooltip: l10n.notificationsTitle,
            onPressed: () =>
                _openAccountPage(context, ref, AppRoutes.notifications),
          ),
        ],
      ),
      body: Column(
        children: [
          const EmailVerificationBanner(),
          Expanded(child: shell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_work_outlined), label: titles[0]),
          NavigationDestination(
              icon: const Icon(Icons.search), label: titles[1]),
          NavigationDestination(
              icon: const Icon(Icons.map_outlined), label: titles[2]),
          NavigationDestination(
              icon: const Icon(Icons.favorite_border), label: titles[3]),
          NavigationDestination(
              icon: const Icon(Icons.person_outline), label: titles[4]),
        ],
      ),
    );
  }
}

/// Simple page with a back button, used for screens outside the tabs.
class _SubPage extends StatelessWidget {
  const _SubPage({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: title == null ? null : Text(title!)),
      body: child,
    );
  }
}
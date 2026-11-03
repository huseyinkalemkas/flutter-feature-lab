import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:go_router/go_router.dart' as go;

import 'link_parser.dart';
import 'media.dart';
import 'storage.dart';
import 'storage_examples.dart';
import 'stream_example.dart';
import 'workspace.dart';
import 'pagination.dart';
import 'motion.dart';
import 'animation_lab.dart';
import 'network.dart';
import 'app_banner.dart';
import 'sync_async.dart';

part 'main.gr.dart';

void main() => runApp(const StorageStartup());

class StorageStartup extends StatefulWidget {
  const StorageStartup({super.key});
  @override
  State<StorageStartup> createState() => _StorageStartupState();
}

class _StorageStartupState extends State<StorageStartup> {
  late Future<void> startup = AppStorage.initialize();
  NetworkMonitor? network;
  @override
  void dispose() {
    network?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: startup,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          !snapshot.hasError) {
        network ??= NetworkMonitor.live()..start();
        return DeepLinkApp(networkMonitor: network);
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: snapshot.hasError
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Yerel arşiv açılamadı. Tarayıcı veya cihaz depolama izinlerini kontrol edin.',
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            setState(() => startup = AppStorage.initialize()),
                        child: const Text('Yeniden dene'),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      );
    },
  );
}

AppRouter createRouter({String? initialLocation}) =>
    AppRouter(initialLocation: initialLocation);

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  final String? initialLocation;
  bool _usedInitialLocation = false;
  AppRouter({this.initialLocation});

  @override
  RouteType get defaultRouteType => RouteType.custom(
    transitionsBuilder: AppMotion.transition,
    duration: const Duration(milliseconds: 550),
    reverseDuration: const Duration(milliseconds: 450),
  );

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: WorkspaceRoute.page, path: '/', initial: true),
    AutoRoute(page: HomeRoute.page, path: '/demo'),
    AutoRoute(page: AnimationLabRoute.page, path: '/animation-lab'),
    AutoRoute(page: SyncAsyncRoute.page, path: '/sync-async'),
    AutoRoute(page: HiveExampleRoute.page, path: '/hive-example'),
    AutoRoute(page: PreferencesExampleRoute.page, path: '/preferences-example'),
    AutoRoute(page: SqliteExampleRoute.page, path: '/sqlite-example'),
    AutoRoute(page: StreamExampleRoute.page, path: '/stream-example'),
    AutoRoute(page: AnimationPreviewRoute.page, path: '/animation-preview'),
    AutoRoute(page: PaginationRoute.page, path: '/project-list'),
    AutoRoute(page: ProjectRoute.page, path: '/projects/:projectId'),
    AutoRoute(page: DetailRoute.page, path: '/products/:id'),
    AutoRoute(page: ProfileRoute.page, path: '/profile/:name'),
    AutoRoute(page: MediaRoute.page, path: '/media/:id'),
    AutoRoute(page: MissingRoute.page, path: '*'),
  ];

  late final configuration = config(
    includePrefixMatches: true,
    deepLinkBuilder: (link) {
      if (initialLocation != null && !_usedInitialLocation) {
        _usedInitialLocation = true;
        return DeepLink.path(initialLocation!);
      }
      return link;
    },
  );
}

go.GoRouter createGoRouter({String? initialLocation}) => go.GoRouter(
  initialLocation: initialLocation,
  routes: [
    animatedGoRoute(
      path: '/',
      builder: (_, __) => const WorkspacePage(),
      routes: [
        animatedGoRoute(
          path: 'stream-example',
          builder: (_, __) => const StreamExamplePage(),
        ),
        animatedGoRoute(
          path: 'hive-example',
          builder: (_, __) => const HiveExamplePage(),
        ),
        animatedGoRoute(
          path: 'preferences-example',
          builder: (_, __) => const PreferencesExamplePage(),
        ),
        animatedGoRoute(
          path: 'sqlite-example',
          builder: (_, __) => const SqliteExamplePage(),
        ),
        animatedGoRoute(
          path: 'sync-async',
          builder: (_, __) => const SyncAsyncPage(),
        ),
        animatedGoRoute(
          path: 'animation-lab',
          builder: (_, __) => const AnimationLabPage(),
        ),
        animatedGoRoute(
          path: 'animation-preview',
          builder: (_, __) => const AnimationPreviewPage(),
        ),
        animatedGoRoute(
          path: 'project-list',
          builder: (_, state) => PaginationPage(
            page: state.uri.queryParameters['page'] ?? '1',
            size: state.uri.queryParameters['size'] ?? '10',
            search: state.uri.queryParameters['q'] ?? '',
            demo: state.uri.queryParameters['demo'] ?? 'false',
            view: state.uri.queryParameters['view'] ?? 'list',
            mode: state.uri.queryParameters['load'] ?? 'pages',
            loading: state.uri.queryParameters['loading'] ?? 'standard',
          ),
        ),
        animatedGoRoute(path: 'demo', builder: (_, __) => const HomePage()),
        animatedGoRoute(
          path: 'projects/:projectId',
          builder: (_, state) =>
              ProjectPage(projectId: state.pathParameters['projectId']!),
        ),
        animatedGoRoute(
          path: 'media/:id',
          builder: (_, state) => MediaPage(
            id: state.pathParameters['id']!,
            media: state.extra is MediaAttachment
                ? state.extra as MediaAttachment
                : null,
          ),
        ),
        animatedGoRoute(
          path: 'products/:id',
          builder: (_, state) => DetailPage(
            id: state.pathParameters['id']!,
            user: state.uri.queryParameters['user'] ?? 'ayse',
            quantity: state.uri.queryParameters['quantity'] ?? '1',
            source: state.uri.queryParameters['ref'],
          ),
        ),
        animatedGoRoute(
          path: 'profile/:name',
          builder: (_, state) => ProfilePage(
            name: state.pathParameters['name']!,
            user: state.uri.queryParameters['user'] ?? 'ayse',
            quantity: state.uri.queryParameters['quantity'] ?? '1',
            source: state.uri.queryParameters['ref'],
            productId: state.uri.queryParameters['product'],
          ),
        ),
      ],
    ),
  ],
  errorBuilder: (_, __) => const MissingPage(),
);

go.GoRoute animatedGoRoute({
  required String path,
  required Widget Function(BuildContext, go.GoRouterState) builder,
  List<go.RouteBase> routes = const [],
}) => go.GoRoute(
  path: path,
  routes: routes,
  pageBuilder: (context, state) => go.CustomTransitionPage<void>(
    key: state.pageKey,
    child: builder(context, state),
    transitionDuration: const Duration(milliseconds: 550),
    reverseTransitionDuration: const Duration(milliseconds: 450),
    transitionsBuilder: AppMotion.transition,
  ),
);

enum RouterEngine { autoRoute, goRouter }

class RouterMode extends InheritedWidget {
  final RouterEngine engine;
  final ValueChanged<RouterEngine>? onEngineChanged;
  const RouterMode({
    super.key,
    required this.engine,
    this.onEngineChanged,
    required super.child,
  });
  static RouterEngine of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RouterMode>()?.engine ??
      RouterEngine.autoRoute;
  @override
  bool updateShouldNotify(RouterMode oldWidget) => engine != oldWidget.engine;
}

// Ortak ekranlar, seçilen gerçek router üzerinden hareket eder.
class DemoNavigation {
  static void animationLab(BuildContext context) {
    if (isGo(context)) {
      go.GoRouter.of(context).go('/animation-lab');
    } else {
      context.router.navigate(const AnimationLabRoute());
    }
  }

  static Future<void> animationPreview(
    BuildContext context,
    String effect,
  ) async {
    await AppMotion.setStyle(effect);
    if (!context.mounted) return;
    if (isGo(context)) {
      await go.GoRouter.of(context).push('/animation-preview');
    } else {
      await context.router.push(const AnimationPreviewRoute());
    }
  }

  static void animationBack(BuildContext context) {
    if (isGo(context)) {
      final router = go.GoRouter.of(context);
      if (router.canPop()) {
        router.pop();
      } else {
        animationLab(context);
      }
    } else {
      if (context.router.canPop()) {
        context.router.pop();
      } else {
        animationLab(context);
      }
    }
  }

  static void pagination(BuildContext context, PageRequest request) {
    if (isGo(context)) {
      go.GoRouter.of(context).go(request.location);
    } else {
      context.router.navigate(
        PaginationRoute(
          page: '${request.page}',
          size: '${request.size}',
          search: request.search,
          demo: '${request.demo}',
          view: request.view,
          mode: request.mode,
          loading: request.loading,
        ),
      );
    }
  }

  static Future<void> media(BuildContext context, MediaAttachment media) async {
    await MediaStore.add(media);
    if (!context.mounted) return;
    if (isGo(context)) {
      go.GoRouter.of(context).push('/media/${media.id}', extra: media);
    } else {
      context.router.push(MediaRoute(id: media.id, media: media));
    }
  }

  static void project(BuildContext context, String id) {
    if (isGo(context)) {
      go.GoRouter.of(context).go('/projects/$id');
    } else {
      context.router.navigate(ProjectRoute(projectId: id));
    }
  }

  static bool isGo(BuildContext context) =>
      RouterMode.of(context) == RouterEngine.goRouter;
  static void openLink(BuildContext context, String path) {
    if (isGo(context)) {
      go.GoRouter.of(context).go(path);
    } else {
      context.router.navigatePath(path, includePrefixMatches: true);
    }
  }

  static void home(BuildContext context) {
    if (isGo(context)) {
      go.GoRouter.of(context).go('/');
    } else {
      context.router.navigate(const WorkspaceRoute());
    }
  }

  static void product(
    BuildContext context,
    PageParameters parameters,
    String id, {
    bool returning = false,
  }) {
    if (isGo(context)) {
      go.GoRouter.of(context).go(parameters.productLocation(id));
    } else if (returning) {
      context.router.navigate(parameters.productRoute(id));
    } else {
      context.router.push(parameters.productRoute(id));
    }
  }

  static void profile(
    BuildContext context, {
    PageParameters? parameters,
    String? productId,
  }) {
    if (isGo(context)) {
      go.GoRouter.of(context).push(
        parameters == null
            ? '/profile/ayse'
            : parameters.profileLocation(productId!),
      );
    } else {
      context.router.push(
        parameters == null
            ? ProfileRoute(name: 'ayse')
            : parameters.profileRoute(productId!),
      );
    }
  }
}

// URL üzerinde taşındığı için yenilemede ve dış bağlantılarda da korunur.
class PageParameters {
  final String user;
  final String? source;
  final int quantity;
  const PageParameters({this.user = 'ayse', this.source, this.quantity = 1});

  factory PageParameters.fromUri(Uri uri) {
    final quantity = int.tryParse(uri.queryParameters['quantity'] ?? '') ?? 1;
    final user = uri.queryParameters['user']?.trim();
    return PageParameters(
      user: user == null || user.isEmpty ? 'ayse' : user,
      source: uri.queryParameters['ref'],
      quantity: quantity.clamp(1, 10).toInt(),
    );
  }

  Map<String, String> get query => {
    'user': user,
    'quantity': '$quantity',
    if (source != null) 'ref': source!,
  };
  String productLocation(String id) =>
      Uri(path: '/products/$id', queryParameters: query).toString();
  String profileLocation(String productId) => Uri(
    pathSegments: ['', 'profile', user],
    queryParameters: {...query, 'product': productId},
  ).toString();

  DetailRoute productRoute(String id) =>
      DetailRoute(id: id, user: user, quantity: '$quantity', source: source);
  ProfileRoute profileRoute(String productId) => ProfileRoute(
    name: user,
    user: user,
    quantity: '$quantity',
    source: source,
    productId: productId,
  );
}

class DeepLinkApp extends StatefulWidget {
  final RouterEngine initialEngine;
  final String? initialLocation;
  final NetworkMonitor? networkMonitor;
  const DeepLinkApp({
    super.key,
    this.initialEngine = RouterEngine.autoRoute,
    this.initialLocation,
    this.networkMonitor,
  });
  @override
  State<DeepLinkApp> createState() => _DeepLinkAppState();
}

class _DeepLinkAppState extends State<DeepLinkApp> {
  late RouterEngine engine;
  AppRouter? autoRouter;
  go.GoRouter? goRouter;
  String get location => engine == RouterEngine.autoRoute
      ? autoRouter!.currentUrl
      : goRouter!.routerDelegate.currentConfiguration.isEmpty
      ? widget.initialLocation ?? '/'
      : goRouter!.state.uri.toString();
  String get path => Uri.tryParse(location)?.path ?? '/';
  BuildContext? get navigationContext => engine == RouterEngine.autoRoute
      ? autoRouter!.navigatorKey.currentContext
      : goRouter!.routerDelegate.navigatorKey.currentContext;
  void navigate(String target) {
    if (engine == RouterEngine.autoRoute) {
      autoRouter!.navigatePath(target, includePrefixMatches: true);
    } else {
      goRouter!.go(target);
    }
  }

  String get backTooltip => path.startsWith('/media/')
      ? 'Projeye dön'
      : path == '/sync-async'
      ? 'Ana sayfaya dön'
      : path.endsWith('-example')
      ? 'Ana sayfa'
      : path == '/animation-preview'
      ? 'Stüdyoya dön'
      : 'Projeler';
  void back() {
    if (path.startsWith('/media/')) {
      final projectId = MediaStore.find(Uri.parse(path).pathSegments.last)
          ?.projectId;
      navigate(projectId == null ? '/' : '/projects/$projectId');
    } else if (path == '/animation-preview') {
      if (engine == RouterEngine.autoRoute && autoRouter!.canPop()) {
        autoRouter!.pop();
      } else if (engine == RouterEngine.goRouter && goRouter!.canPop()) {
        goRouter!.pop();
      } else {
        navigate('/animation-lab');
      }
    } else if (path.startsWith('/products/') || path.startsWith('/profile/')) {
      navigate('/demo');
    } else {
      navigate('/');
    }
  }

  @override
  void initState() {
    super.initState();
    engine = widget.initialEngine;
    if (engine == RouterEngine.autoRoute) {
      autoRouter = createRouter(initialLocation: widget.initialLocation);
    } else {
      goRouter = createGoRouter(initialLocation: widget.initialLocation);
    }
  }

  void switchEngine(RouterEngine selected) {
    if (engine == selected) return;
    final location = engine == RouterEngine.autoRoute
        ? autoRouter!.currentUrl
        : goRouter!.state.uri.toString();
    final oldAuto = autoRouter;
    final oldGo = goRouter;
    setState(() {
      engine = selected;
      autoRouter = selected == RouterEngine.autoRoute
          ? createRouter(initialLocation: location)
          : null;
      goRouter = selected == RouterEngine.goRouter
          ? createGoRouter(initialLocation: location)
          : null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldAuto?.dispose();
      oldGo?.dispose();
    });
  }

  @override
  void dispose() {
    autoRouter?.dispose();
    goRouter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    key: ValueKey(engine),
    title: 'ProjeDosya',
    debugShowCheckedModeBanner: false,
    routerConfig: engine == RouterEngine.autoRoute
        ? autoRouter!.configuration
        : goRouter!,
    builder: (context, child) => HeroControllerScope.none(
      child: Navigator(
        pages: [
          MaterialPage<void>(
            key: const ValueKey('app-frame'),
            child: RouterMode(
              engine: engine,
              onEngineChanged: switchEngine,
              child: NetworkBannerHost(
                monitor: widget.networkMonitor,
                header: BannerRouteListener(
                  listenable: engine == RouterEngine.autoRoute
                      ? autoRouter!
                      : goRouter!.routerDelegate,
                  builder: (context) => AppControlBanner(
                    currentPath: path,
                    engine: engine == RouterEngine.autoRoute
                        ? 'auto_route'
                        : 'go_router',
                    network: widget.networkMonitor,
                    onNavigate: navigate,
                    onEngineChanged: (value) => switchEngine(
                      value == 'go_router'
                          ? RouterEngine.goRouter
                          : RouterEngine.autoRoute,
                    ),
                    backTooltip: backTooltip,
                    onBack: back,
                    onSettings: () {
                      final context = navigationContext;
                      if (context != null) showAppSettings(context);
                    },
                    onNewProject: () {
                      final context = navigationContext;
                      if (context != null)
                        showCreateProject(
                          context,
                          (id) => navigate('/projects/$id'),
                        );
                    },
                    onAddCustomer: () {
                      final context = navigationContext;
                      if (context != null) showCreateCustomer(context);
                    },
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ],
        onDidRemovePage: (_) {},
      ),
    ),
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: accent,
      scaffoldBackgroundColor: const Color(0xFFF4F6F3),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF6F7FB)),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
  );
}

void showAppSettings(BuildContext context) {
  final scope = context.dependOnInheritedWidgetOfExactType<RouterMode>();
  final network = NetworkScope.of(context);
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Ayarlar'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yerel çalışma alanı',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Müşteri, proje ve dosyalar bu cihazda saklanır. Başka cihazlarla otomatik eşitlenmez. Tarayıcı verilerini silmek arşivi de siler.',
              ),
              const SizedBox(height: 24),
              if (network != null) ...[
                NetworkSettingsTile(monitor: network),
                const SizedBox(height: 12),
              ],
              const Text('Yönlendirme motoru'),
              const SizedBox(height: 12),
              SegmentedButton<RouterEngine>(
                segments: const [
                  ButtonSegment(
                    value: RouterEngine.goRouter,
                    label: Text('go_router'),
                  ),
                  ButtonSegment(
                    value: RouterEngine.autoRoute,
                    label: Text('auto_route'),
                  ),
                ],
                selected: {scope?.engine ?? RouterEngine.autoRoute},
                onSelectionChanged: (values) {
                  Navigator.pop(dialogContext);
                  scope?.onEngineChanged?.call(values.single);
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<int>(
                valueListenable: AppStorage.changes,
                builder: (context, _, __) => DropdownButtonFormField<String>(
                  key: ValueKey(AppMotion.style),
                  initialValue: AppMotion.style,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Sayfa geçiş efekti',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'slide',
                      child: Text('Kayma + solma'),
                    ),
                    DropdownMenuItem(value: 'fade', child: Text('Solma')),
                    DropdownMenuItem(
                      value: 'flip3d',
                      child: Text('3B kart dönüşü'),
                    ),
                    DropdownMenuItem(
                      value: 'cube3d',
                      child: Text('3B küp geçişi'),
                    ),
                    DropdownMenuItem(
                      value: 'depth3d',
                      child: Text('3B derinlik'),
                    ),
                    DropdownMenuItem(value: 'none', child: Text('Efekt yok')),
                  ],
                  onChanged: (value) async {
                    if (value == null) return;
                    try {
                      await AppMotion.setStyle(value);
                    } catch (_) {
                      if (dialogContext.mounted)
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text('Efekt tercihi kaydedilemedi.'),
                          ),
                        );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  DemoNavigation.animationLab(context);
                },
                icon: const Icon(Icons.animation),
                label: const Text('Animasyon stüdyosunu aç'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  DemoNavigation.openLink(context, '/demo');
                },
                icon: const Icon(Icons.science_outlined),
                label: const Text('Yönlendirme örneklerini aç'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Kapat'),
        ),
      ],
    ),
  );
}

@RoutePage()
class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});
  @override
  Widget build(BuildContext context) => WorkspaceScreen(
    onOpenProject: (id) => DemoNavigation.project(context, id),
    onPagination: () => DemoNavigation.pagination(context, const PageRequest()),
    onAnimations: () => DemoNavigation.animationLab(context),
    onSyncAsync: () => DemoNavigation.openLink(context, '/sync-async'),
    onStorageExample: (path) => DemoNavigation.openLink(context, path),
    onSettings: () => showAppSettings(context),
  );
}

@RoutePage()
class SyncAsyncPage extends StatelessWidget {
  const SyncAsyncPage({super.key});
  @override
  Widget build(BuildContext context) =>
      SyncAsyncScreen(onHome: () => DemoNavigation.home(context));
}

@RoutePage()
class AnimationLabPage extends StatelessWidget {
  const AnimationLabPage({super.key});
  @override
  Widget build(BuildContext context) => AnimationLabScreen(
    onHome: () => DemoNavigation.home(context),
    onSettings: () => showAppSettings(context),
    onPreview: (effect) => DemoNavigation.animationPreview(context, effect),
  );
}

@RoutePage()
class AnimationPreviewPage extends StatelessWidget {
  const AnimationPreviewPage({super.key});
  @override
  Widget build(BuildContext context) => AnimationPreviewScreen(
    onBack: () => DemoNavigation.animationBack(context),
  );
}

@RoutePage()
class PaginationPage extends StatelessWidget {
  final String page, size, search, demo, view, mode, loading;
  const PaginationPage({
    super.key,
    @QueryParam('page') this.page = '1',
    @QueryParam('size') this.size = '10',
    @QueryParam('q') this.search = '',
    @QueryParam('demo') this.demo = 'false',
    @QueryParam('view') this.view = 'list',
    @QueryParam('load') this.mode = 'pages',
    @QueryParam('loading') this.loading = 'standard',
  });
  @override
  Widget build(BuildContext context) => PaginatedProjectsScreen(
    request: PageRequest.fromRaw(
      page: page,
      size: size,
      search: search,
      demo: demo,
      view: view,
      mode: mode,
      loading: loading,
    ),
    onNavigate: (request) => DemoNavigation.pagination(context, request),
    onOpenProject: (id) => DemoNavigation.project(context, id),
    onHome: () => DemoNavigation.home(context),
    onSettings: () => showAppSettings(context),
  );
}

@RoutePage()
class ProjectPage extends StatelessWidget {
  final String projectId;
  const ProjectPage({
    super.key,
    @PathParam('projectId') required this.projectId,
  });
  @override
  Widget build(BuildContext context) => ProjectScreen(
    projectId: projectId,
    onOpenMedia: (media) => DemoNavigation.media(context, media),
    onHome: () => DemoNavigation.home(context),
    onSettings: () => showAppSettings(context),
  );
}

class Product {
  final String id, name, description, price;
  final IconData icon;
  const Product(this.id, this.name, this.description, this.price, this.icon);
}

const products = [
  Product(
    '42',
    'Studio kulaklık',
    'Müziğe odaklan. Kablosuz bağlantı ve gün boyu konfor.',
    '₺2.490',
    Icons.headphones_rounded,
  ),
  Product(
    '73',
    'Akıllı saat',
    'Günün ritmini takip et. Hareket, bildirimler ve sade tasarım.',
    '₺3.790',
    Icons.watch_rounded,
  ),
  Product(
    '108',
    'Fotoğraf makinesi',
    'Her anı keşfet. Yolculukların için kompakt bir yol arkadaşı.',
    '₺12.900',
    Icons.camera_alt_rounded,
  ),
];

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = TextEditingController(
    text: 'linkdemo://app/products/42?ref=kampanya',
  );
  final userController = TextEditingController(text: 'Ayşe Yılmaz');
  int quantity = 1;
  String? error;
  @override
  void dispose() {
    controller.dispose();
    userController.dispose();
    super.dispose();
  }

  void openLink() {
    final path = internalLocation(controller.text);
    setState(
      () => error = path == null
          ? 'linkdemo://app/... veya https://example.com/... kullanın.'
          : null,
    );
    if (path != null) DemoNavigation.openLink(context, path);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('LinkLab'),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF252B64),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.link_rounded, size: 36, color: Color(0xFFA8B4FF)),
                  SizedBox(height: 20),
                  Text(
                    'Bir bağlantı.\nDoğrudan doğru ekrana.',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Deep link ile ürün ve profil ekranlarını keşfet.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Bağlantıyı dene',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              onSubmitted: (_) => openLink(),
              decoration: InputDecoration(
                labelText: 'Deep link',
                errorText: error,
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: openLink,
              icon: const Icon(Icons.north_east),
              label: const Text('Bağlantıyı aç'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu alan yönlendirmeyi uygulama içinde dener. İşletim sistemi testi için README komutlarını kullanın.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 28),
            MediaPickerCard(
              onSelected: (media) => DemoNavigation.media(context, media),
            ),
            const SizedBox(height: 24),
            Text(
              'Sayfaya gönderilecek bilgiler',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: userController,
              decoration: const InputDecoration(labelText: 'Kullanıcı adı'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: quantity,
              decoration: const InputDecoration(labelText: 'Adet'),
              items: [
                for (var i = 1; i <= 10; i++)
                  DropdownMenuItem(value: i, child: Text('$i')),
              ],
              onChanged: (value) => setState(() => quantity = value ?? 1),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aşağıdan bir ürün seç. Bu bilgiler ürün detayına, oradan profile taşınır.',
            ),
            const SizedBox(height: 20),
            Text('Keşfet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final product in products)
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  leading: Icon(
                    product.icon,
                    color: const Color(0xFF4855D9),
                    size: 32,
                  ),
                  title: Text(product.name),
                  subtitle: Text(product.price),
                  trailing: const Icon(Icons.arrow_forward_rounded),
                  onTap: () => DemoNavigation.product(
                    context,
                    PageParameters(
                      user: userController.text.trim().isEmpty
                          ? 'ayse'
                          : userController.text.trim(),
                      quantity: quantity,
                      source: 'kesfet',
                    ),
                    product.id,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

@RoutePage()
class DetailPage extends StatelessWidget {
  final String id, user, quantity;
  final String? source;
  const DetailPage({
    super.key,
    @PathParam('id') required this.id,
    @QueryParam('user') this.user = 'ayse',
    @QueryParam('quantity') this.quantity = '1',
    @QueryParam('ref') this.source,
  });
  PageParameters get parameters => PageParameters.fromUri(
    Uri(
      queryParameters: {
        'user': user,
        'quantity': quantity,
        if (source != null) 'ref': source!,
      },
    ),
  );
  @override
  Widget build(BuildContext context) {
    final product = products.where((p) => p.id == id).firstOrNull;
    if (product == null) return const MissingPage();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ürün detayı'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E9FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  product.icon,
                  size: 100,
                  color: const Color(0xFF4855D9),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                product.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(product.description),
              const SizedBox(height: 20),
              Text(
                product.price,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bağlantıdan gelen veriler',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Ürün ID: ${product.id}'),
                      Text(
                        'Kaynak (ref): ${parameters.source ?? "belirtilmedi"}',
                      ),
                      Text('Kullanıcı: ${parameters.user}'),
                      Text('Adet: ${parameters.quantity}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => DemoNavigation.profile(
                  context,
                  parameters: parameters,
                  productId: product.id,
                ),
                icon: const Icon(Icons.person_outline),
                label: const Text('Bilgileri profile taşı'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text:
                          'linkdemo://app${parameters.productLocation(product.id)}',
                    ),
                  );
                  if (context.mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deep link kopyalandı')),
                    );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Deep link kopyala'),
              ),
              TextButton(
                onPressed: () => DemoNavigation.home(context),
                child: const Text('Ana sayfaya dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@RoutePage()
class ProfilePage extends StatelessWidget {
  final String name, user, quantity;
  final String? productId, source;
  const ProfilePage({
    super.key,
    @PathParam('name') required this.name,
    @QueryParam('user') this.user = 'ayse',
    @QueryParam('quantity') this.quantity = '1',
    @QueryParam('ref') this.source,
    @QueryParam('product') this.productId,
  });
  PageParameters get parameters => PageParameters.fromUri(
    Uri(
      queryParameters: {
        'user': user,
        'quantity': quantity,
        if (source != null) 'ref': source!,
      },
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Profil'),
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 48,
            child: Icon(Icons.person_rounded, size: 52),
          ),
          const SizedBox(height: 20),
          Text(name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          const Text('Bu profil URL içindeki isimle açıldı.'),
          if (productId != null) ...[
            const SizedBox(height: 20),
            Text('Taşınan ürün ID: $productId'),
            Text('Adet: ${parameters.quantity}'),
            Text('Kaynak (ref): ${parameters.source ?? "belirtilmedi"}'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => DemoNavigation.product(
                context,
                parameters,
                productId!,
                returning: true,
              ),
              child: const Text('Parametrelerle ürüne dön'),
            ),
          ],
          TextButton(
            onPressed: () => DemoNavigation.home(context),
            child: const Text('Ana sayfaya dön'),
          ),
        ],
      ),
    ),
  );
}

@RoutePage()
class MediaPage extends StatelessWidget {
  final String id;
  final MediaAttachment? media;
  const MediaPage({super.key, @PathParam('id') required this.id, this.media});
  Future<void> deleteFile(
    BuildContext context,
    MediaAttachment attachment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dosya silinsin mi?'),
        content: Text('${attachment.name} bu cihazdaki arşivden silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await MediaStore.remove(id);
      if (!context.mounted) return;
      if (attachment.projectId != null)
        DemoNavigation.project(context, attachment.projectId!);
      else
        DemoNavigation.home(context);
    } catch (_) {
      if (context.mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Dosya silinemedi.')));
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: AppStorage.changes,
    builder: (context, _, __) {
      final attachment = MediaStore.find(id);
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Dosya'),
          actions: [
            if (attachment != null) ...[
              IconButton(
                tooltip: 'Favori',
                icon: Icon(
                  attachment.favorite ? Icons.star_rounded : Icons.star_outline,
                  color: attachment.favorite ? Colors.amber.shade700 : null,
                ),
                onPressed: () async {
                  try {
                    await MediaStore.add(
                      attachment.copyWith(favorite: !attachment.favorite),
                    );
                  } catch (_) {
                    if (context.mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Favori kaydedilemedi.')),
                      );
                  }
                },
              ),
              IconButton(
                tooltip: 'Dosya bilgileri',
                icon: const Icon(Icons.edit_note),
                onPressed: () => editFile(context, attachment),
              ),
            ],
            PopupMenuButton<String>(
              onSelected: (action) async {
                if (attachment == null) return;
                if (action == 'delete') {
                  await deleteFile(context, attachment);
                  return;
                }
                await Clipboard.setData(
                  ClipboardData(text: 'linkdemo://app/media/$id'),
                );
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Bağlantı kopyalandı. Dosya bu cihazdaki arşivde açılır.',
                      ),
                    ),
                  );
              },
              itemBuilder: (_) => [
                if (attachment != null)
                  const PopupMenuItem(
                    value: 'copy',
                    child: Text('Bağlantıyı kopyala'),
                  ),
                if (attachment != null)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Dosyayı sil'),
                  ),
              ],
            ),
          ],
        ),
        body: attachment == null
            ? ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Dosya bu cihazın arşivinde bulunamadı. Silinmiş veya başka bir cihazda saklanmış olabilir.',
                  ),
                  const SizedBox(height: 16),
                  MediaPickerCard(
                    onSelected: (selected) =>
                        DemoNavigation.media(context, selected),
                  ),
                ],
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          attachment.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (attachment.projectId != null)
                          Text(
                            WorkspaceStore.project(attachment.projectId!)
                                    ?.name ??
                                '',
                          ),
                        if (attachment.note.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              attachment.note,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Text(
                          '${attachment.label} · ${(attachment.bytes.length / 1024).toStringAsFixed(1)} KB',
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: MediaViewer(media: attachment)),
                ],
              ),
      );
    },
  );
}

@RoutePage()
class MissingPage extends StatelessWidget {
  const MissingPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link_off, size: 64),
          const SizedBox(height: 16),
          const Text('Bu bağlantının hedefi bulunamadı.'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => DemoNavigation.home(context),
            child: const Text('Ana sayfaya dön'),
          ),
        ],
      ),
    ),
  );
}

@RoutePage()
class HiveExamplePage extends StatelessWidget {
  const HiveExamplePage({super.key});
  @override
  Widget build(BuildContext context) =>
      HiveExampleScreen(onHome: () => DemoNavigation.home(context));
}

@RoutePage()
class PreferencesExamplePage extends StatelessWidget {
  const PreferencesExamplePage({super.key});
  @override
  Widget build(BuildContext context) =>
      PreferencesExampleScreen(onHome: () => DemoNavigation.home(context));
}

@RoutePage()
class SqliteExamplePage extends StatelessWidget {
  const SqliteExamplePage({super.key});
  @override
  Widget build(BuildContext context) =>
      SqliteExampleScreen(onHome: () => DemoNavigation.home(context));
}

@RoutePage()
class StreamExamplePage extends StatelessWidget {
  const StreamExamplePage({super.key});
  @override
  Widget build(BuildContext context) => const StreamExampleScreen();
}

// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'main.dart';

/// generated route for
/// [AnimationLabPage]
class AnimationLabRoute extends PageRouteInfo<void> {
  const AnimationLabRoute({List<PageRouteInfo>? children})
    : super(AnimationLabRoute.name, initialChildren: children);

  static const String name = 'AnimationLabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AnimationLabPage();
    },
  );
}

/// generated route for
/// [AnimationPreviewPage]
class AnimationPreviewRoute extends PageRouteInfo<void> {
  const AnimationPreviewRoute({List<PageRouteInfo>? children})
    : super(AnimationPreviewRoute.name, initialChildren: children);

  static const String name = 'AnimationPreviewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AnimationPreviewPage();
    },
  );
}

/// generated route for
/// [DetailPage]
class DetailRoute extends PageRouteInfo<DetailRouteArgs> {
  DetailRoute({
    Key? key,
    required String id,
    String user = 'ayse',
    String quantity = '1',
    String? source,
    List<PageRouteInfo>? children,
  }) : super(
         DetailRoute.name,
         args: DetailRouteArgs(
           key: key,
           id: id,
           user: user,
           quantity: quantity,
           source: source,
         ),
         rawPathParams: {'id': id},
         rawQueryParams: {'user': user, 'quantity': quantity, 'ref': source},
         initialChildren: children,
       );

  static const String name = 'DetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<DetailRouteArgs>(
        orElse: () => DetailRouteArgs(
          id: pathParams.getString('id'),
          user: queryParams.getString('user', 'ayse'),
          quantity: queryParams.getString('quantity', '1'),
          source: queryParams.optString('ref'),
        ),
      );
      return DetailPage(
        key: args.key,
        id: args.id,
        user: args.user,
        quantity: args.quantity,
        source: args.source,
      );
    },
  );
}

class DetailRouteArgs {
  const DetailRouteArgs({
    this.key,
    required this.id,
    this.user = 'ayse',
    this.quantity = '1',
    this.source,
  });

  final Key? key;

  final String id;

  final String user;

  final String quantity;

  final String? source;

  @override
  String toString() {
    return 'DetailRouteArgs{key: $key, id: $id, user: $user, quantity: $quantity, source: $source}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DetailRouteArgs) return false;
    return key == other.key &&
        id == other.id &&
        user == other.user &&
        quantity == other.quantity &&
        source == other.source;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      id.hashCode ^
      user.hashCode ^
      quantity.hashCode ^
      source.hashCode;
}

/// generated route for
/// [HiveExamplePage]
class HiveExampleRoute extends PageRouteInfo<void> {
  const HiveExampleRoute({List<PageRouteInfo>? children})
    : super(HiveExampleRoute.name, initialChildren: children);

  static const String name = 'HiveExampleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HiveExamplePage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [MediaPage]
class MediaRoute extends PageRouteInfo<MediaRouteArgs> {
  MediaRoute({
    Key? key,
    required String id,
    MediaAttachment? media,
    List<PageRouteInfo>? children,
  }) : super(
         MediaRoute.name,
         args: MediaRouteArgs(key: key, id: id, media: media),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'MediaRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MediaRouteArgs>(
        orElse: () => MediaRouteArgs(id: pathParams.getString('id')),
      );
      return MediaPage(key: args.key, id: args.id, media: args.media);
    },
  );
}

class MediaRouteArgs {
  const MediaRouteArgs({this.key, required this.id, this.media});

  final Key? key;

  final String id;

  final MediaAttachment? media;

  @override
  String toString() {
    return 'MediaRouteArgs{key: $key, id: $id, media: $media}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MediaRouteArgs) return false;
    return key == other.key && id == other.id && media == other.media;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode ^ media.hashCode;
}

/// generated route for
/// [MissingPage]
class MissingRoute extends PageRouteInfo<void> {
  const MissingRoute({List<PageRouteInfo>? children})
    : super(MissingRoute.name, initialChildren: children);

  static const String name = 'MissingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MissingPage();
    },
  );
}

/// generated route for
/// [PaginationPage]
class PaginationRoute extends PageRouteInfo<PaginationRouteArgs> {
  PaginationRoute({
    Key? key,
    String page = '1',
    String size = '10',
    String search = '',
    String demo = 'false',
    String view = 'list',
    String mode = 'pages',
    String loading = 'standard',
    List<PageRouteInfo>? children,
  }) : super(
         PaginationRoute.name,
         args: PaginationRouteArgs(
           key: key,
           page: page,
           size: size,
           search: search,
           demo: demo,
           view: view,
           mode: mode,
           loading: loading,
         ),
         rawQueryParams: {
           'page': page,
           'size': size,
           'q': search,
           'demo': demo,
           'view': view,
           'load': mode,
           'loading': loading,
         },
         initialChildren: children,
       );

  static const String name = 'PaginationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<PaginationRouteArgs>(
        orElse: () => PaginationRouteArgs(
          page: queryParams.getString('page', '1'),
          size: queryParams.getString('size', '10'),
          search: queryParams.getString('q', ''),
          demo: queryParams.getString('demo', 'false'),
          view: queryParams.getString('view', 'list'),
          mode: queryParams.getString('load', 'pages'),
          loading: queryParams.getString('loading', 'standard'),
        ),
      );
      return PaginationPage(
        key: args.key,
        page: args.page,
        size: args.size,
        search: args.search,
        demo: args.demo,
        view: args.view,
        mode: args.mode,
        loading: args.loading,
      );
    },
  );
}

class PaginationRouteArgs {
  const PaginationRouteArgs({
    this.key,
    this.page = '1',
    this.size = '10',
    this.search = '',
    this.demo = 'false',
    this.view = 'list',
    this.mode = 'pages',
    this.loading = 'standard',
  });

  final Key? key;

  final String page;

  final String size;

  final String search;

  final String demo;

  final String view;

  final String mode;

  final String loading;

  @override
  String toString() {
    return 'PaginationRouteArgs{key: $key, page: $page, size: $size, search: $search, demo: $demo, view: $view, mode: $mode, loading: $loading}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaginationRouteArgs) return false;
    return key == other.key &&
        page == other.page &&
        size == other.size &&
        search == other.search &&
        demo == other.demo &&
        view == other.view &&
        mode == other.mode &&
        loading == other.loading;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      page.hashCode ^
      size.hashCode ^
      search.hashCode ^
      demo.hashCode ^
      view.hashCode ^
      mode.hashCode ^
      loading.hashCode;
}

/// generated route for
/// [PreferencesExamplePage]
class PreferencesExampleRoute extends PageRouteInfo<void> {
  const PreferencesExampleRoute({List<PageRouteInfo>? children})
    : super(PreferencesExampleRoute.name, initialChildren: children);

  static const String name = 'PreferencesExampleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PreferencesExamplePage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({
    Key? key,
    required String name,
    String user = 'ayse',
    String quantity = '1',
    String? source,
    String? productId,
    List<PageRouteInfo>? children,
  }) : super(
         ProfileRoute.name,
         args: ProfileRouteArgs(
           key: key,
           name: name,
           user: user,
           quantity: quantity,
           source: source,
           productId: productId,
         ),
         rawPathParams: {'name': name},
         rawQueryParams: {
           'user': user,
           'quantity': quantity,
           'ref': source,
           'product': productId,
         },
         initialChildren: children,
       );

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<ProfileRouteArgs>(
        orElse: () => ProfileRouteArgs(
          name: pathParams.getString('name'),
          user: queryParams.getString('user', 'ayse'),
          quantity: queryParams.getString('quantity', '1'),
          source: queryParams.optString('ref'),
          productId: queryParams.optString('product'),
        ),
      );
      return ProfilePage(
        key: args.key,
        name: args.name,
        user: args.user,
        quantity: args.quantity,
        source: args.source,
        productId: args.productId,
      );
    },
  );
}

class ProfileRouteArgs {
  const ProfileRouteArgs({
    this.key,
    required this.name,
    this.user = 'ayse',
    this.quantity = '1',
    this.source,
    this.productId,
  });

  final Key? key;

  final String name;

  final String user;

  final String quantity;

  final String? source;

  final String? productId;

  @override
  String toString() {
    return 'ProfileRouteArgs{key: $key, name: $name, user: $user, quantity: $quantity, source: $source, productId: $productId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProfileRouteArgs) return false;
    return key == other.key &&
        name == other.name &&
        user == other.user &&
        quantity == other.quantity &&
        source == other.source &&
        productId == other.productId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      name.hashCode ^
      user.hashCode ^
      quantity.hashCode ^
      source.hashCode ^
      productId.hashCode;
}

/// generated route for
/// [ProjectPage]
class ProjectRoute extends PageRouteInfo<ProjectRouteArgs> {
  ProjectRoute({
    Key? key,
    required String projectId,
    List<PageRouteInfo>? children,
  }) : super(
         ProjectRoute.name,
         args: ProjectRouteArgs(key: key, projectId: projectId),
         rawPathParams: {'projectId': projectId},
         initialChildren: children,
       );

  static const String name = 'ProjectRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ProjectRouteArgs>(
        orElse: () =>
            ProjectRouteArgs(projectId: pathParams.getString('projectId')),
      );
      return ProjectPage(key: args.key, projectId: args.projectId);
    },
  );
}

class ProjectRouteArgs {
  const ProjectRouteArgs({this.key, required this.projectId});

  final Key? key;

  final String projectId;

  @override
  String toString() {
    return 'ProjectRouteArgs{key: $key, projectId: $projectId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProjectRouteArgs) return false;
    return key == other.key && projectId == other.projectId;
  }

  @override
  int get hashCode => key.hashCode ^ projectId.hashCode;
}

/// generated route for
/// [SqliteExamplePage]
class SqliteExampleRoute extends PageRouteInfo<void> {
  const SqliteExampleRoute({List<PageRouteInfo>? children})
    : super(SqliteExampleRoute.name, initialChildren: children);

  static const String name = 'SqliteExampleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SqliteExamplePage();
    },
  );
}

/// generated route for
/// [StreamExamplePage]
class StreamExampleRoute extends PageRouteInfo<void> {
  const StreamExampleRoute({List<PageRouteInfo>? children})
    : super(StreamExampleRoute.name, initialChildren: children);

  static const String name = 'StreamExampleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StreamExamplePage();
    },
  );
}

/// generated route for
/// [SyncAsyncPage]
class SyncAsyncRoute extends PageRouteInfo<void> {
  const SyncAsyncRoute({List<PageRouteInfo>? children})
    : super(SyncAsyncRoute.name, initialChildren: children);

  static const String name = 'SyncAsyncRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SyncAsyncPage();
    },
  );
}

/// generated route for
/// [WorkspacePage]
class WorkspaceRoute extends PageRouteInfo<void> {
  const WorkspaceRoute({List<PageRouteInfo>? children})
    : super(WorkspaceRoute.name, initialChildren: children);

  static const String name = 'WorkspaceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WorkspacePage();
    },
  );
}

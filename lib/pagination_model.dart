class PageRequest {
  final int page, size;
  final String search, view, mode, loading;
  final bool demo;
  const PageRequest({
    this.page = 1,
    this.size = 10,
    this.search = '',
    this.demo = false,
    this.view = 'list',
    this.mode = 'pages',
    this.loading = 'standard',
  });
  factory PageRequest.fromRaw({
    String page = '1',
    String size = '10',
    String search = '',
    String demo = 'false',
    String view = 'list',
    String mode = 'pages',
    String loading = 'standard',
  }) => PageRequest(
    page: (int.tryParse(page) ?? 1).clamp(1, 1000000),
    size: [5, 10, 20].contains(int.tryParse(size)) ? int.parse(size) : 10,
    search: search,
    demo: demo == 'true',
    view: view == 'grid' ? 'grid' : 'list',
    mode: mode == 'lazy' ? 'lazy' : 'pages',
    loading: loading == 'skeleton' ? 'skeleton' : 'standard',
  );
  PageRequest copyWith({
    int? page,
    int? size,
    String? search,
    bool? demo,
    String? view,
    String? mode,
    String? loading,
  }) => PageRequest(
    page: page ?? this.page,
    size: size ?? this.size,
    search: search ?? this.search,
    demo: demo ?? this.demo,
    view: view ?? this.view,
    mode: mode ?? this.mode,
    loading: loading ?? this.loading,
  );
  String get location => Uri(
    path: '/project-list',
    queryParameters: {
      'page': '$page',
      'size': '$size',
      'view': view,
      'load': mode,
      'loading': loading,
      if (search.isNotEmpty) 'q': search,
      if (demo) 'demo': 'true',
    },
  ).toString();
}

class PageSlice<T> {
  final List<T> items;
  final int page, pages, total, start, end;
  PageSlice(List<T> all, PageRequest request)
    : total = all.length,
      pages = all.isEmpty ? 1 : (all.length / request.size).ceil(),
      page = request.page.clamp(
        1,
        all.isEmpty ? 1 : (all.length / request.size).ceil(),
      ),
      start = all.isEmpty
          ? 0
          : ((request.page.clamp(1, (all.length / request.size).ceil()) - 1) *
                    request.size) +
                1,
      end = all.isEmpty
          ? 0
          : (request.page.clamp(1, (all.length / request.size).ceil()) *
                    request.size)
                .clamp(0, all.length),
      items = all.isEmpty
          ? []
          : all
                .skip(
                  (request.page.clamp(1, (all.length / request.size).ceil()) -
                          1) *
                      request.size,
                )
                .take(request.size)
                .toList();
}

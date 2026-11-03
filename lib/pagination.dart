import 'package:flutter/material.dart';

import 'storage.dart';
import 'workspace.dart';
import 'motion.dart';
import 'pagination_model.dart';
export 'pagination_model.dart';

typedef ProjectPageLoader = Future<PageSlice<Project>> Function(
  PageRequest request,
);

Future<PageSlice<Project>> loadProjectPage(PageRequest request) async {
  // Yalnız örnek kayıtlar, yükleme durumlarını göstermek için geciktirilir.
  await Future<void>.delayed(
    request.demo ? const Duration(milliseconds: 650) : Duration.zero,
  );
  final source = request.demo
      ? List.generate(
          53,
          (index) => Project(
            id: 'sample-${index + 1}',
            customerId: 'sample-customer',
            name: 'Örnek Proje ${(index + 1).toString().padLeft(2, '0')}',
            description: 'Sayfalama denemesi için örnek kayıt',
            completed: index % 4 == 0,
          ),
        )
      : WorkspaceStore.projects.reversed.toList();
  final filtered = source
      .where(
        (p) =>
            '${p.name} ${p.description} ${request.demo ? 'Örnek müşteri' : WorkspaceStore.customer(p.customerId)?.name ?? ''}'
                .toLowerCase()
                .contains(request.search.toLowerCase()),
      )
      .toList();
  return PageSlice(filtered, request);
}

class PaginatedProjectsScreen extends StatefulWidget {
  final PageRequest request;
  final ValueChanged<PageRequest> onNavigate;
  final ValueChanged<String> onOpenProject;
  final VoidCallback onHome, onSettings;
  final ProjectPageLoader loader;
  const PaginatedProjectsScreen({
    super.key,
    required this.request,
    required this.onNavigate,
    required this.onOpenProject,
    required this.onHome,
    required this.onSettings,
    this.loader = loadProjectPage,
  });
  @override
  State<PaginatedProjectsScreen> createState() =>
      _PaginatedProjectsScreenState();
}

class _PaginatedProjectsScreenState extends State<PaginatedProjectsScreen> {
  late final search = TextEditingController(text: widget.request.search);
  final scroll = ScrollController();
  List<Project> items = [];
  int total = 0, page = 1, pages = 1, start = 0, end = 0, generation = 0;
  bool loading = true;
  String? error;
  bool get lazy => widget.request.mode == 'lazy';
  bool get hasMore => page < pages;
  @override
  void initState() {
    super.initState();
    scroll.addListener(maybeLoadMore);
    AppStorage.changes.addListener(storageChanged);
    fetch();
  }

  void storageChanged() => fetch();
  @override
  void dispose() {
    generation++;
    AppStorage.changes.removeListener(storageChanged);
    scroll.dispose();
    search.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PaginatedProjectsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.request;
    final next = widget.request;
    if (old.search != next.search) search.text = next.search;
    if (old.page != next.page ||
        old.size != next.size ||
        old.search != next.search ||
        old.demo != next.demo ||
        old.mode != next.mode ||
        old.loading != next.loading ||
        oldWidget.loader != widget.loader) {
      fetch();
    }
  }

  void maybeLoadMore() {
    if (lazy &&
        !loading &&
        error == null &&
        hasMore &&
        scroll.hasClients &&
        scroll.position.extentAfter < 250) {
      fetch(append: true);
    }
  }

  Future<void> fetch({bool append = false}) async {
    if (append && (loading || !hasMore)) return;
    final token = append ? generation : ++generation;
    final requested = widget.request.copyWith(
      page: append
          ? page + 1
          : lazy
          ? 1
          : widget.request.page,
    );
    setState(() {
      loading = true;
      error = null;
      if (!append) {
        items = [];
        start = 0;
        end = 0;
      }
    });
    try {
      final result = await widget.loader(requested);
      if (!mounted || token != generation) return;
      setState(() {
        final merged = append ? [...items, ...result.items] : result.items;
        final seen = <String>{};
        items = merged.where((item) => seen.add(item.id)).toList();
        total = result.total;
        page = result.page;
        pages = result.pages;
        start = lazy ? (items.isEmpty ? 0 : 1) : result.start;
        end = lazy ? items.length : result.end;
        loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) maybeLoadMore();
      });
    } catch (_) {
      if (mounted && token == generation)
        setState(() {
          loading = false;
          error = 'Kayıtlar yüklenemedi. Yeniden deneyin.';
        });
    }
  }

  void applySearch() => widget.onNavigate(
    widget.request.copyWith(page: 1, search: search.text.trim()),
  );
  Widget projectTile(BuildContext context, Project project, bool grid) {
    final demo = widget.request.demo;
    final customer = demo
        ? 'Örnek müşteri'
        : WorkspaceStore.customer(project.customerId)?.name ?? '';
    final status = demo
        ? 'Örnek'
        : project.completed
        ? 'Tamamlandı'
        : 'Aktif';
    final tap = demo ? null : () => widget.onOpenProject(project.id);
    final content = grid
        ? Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: tap,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.folder_outlined,
                          color: accent,
                          size: 32,
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      project.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      customer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        project.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
        : Card(
            child: ListTile(
              leading: const Icon(Icons.folder_outlined, color: accent),
              title: Text(
                project.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                customer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(status),
              onTap: tap,
            ),
          );
    if (AppMotion.style == 'none' || MediaQuery.disableAnimationsOf(context))
      return content;
    return TweenAnimationBuilder<double>(
      key: ValueKey('${widget.request.view}:${project.id}:$generation'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 8),
          child: child,
        ),
      ),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final numbers = <int>{
      1,
      pages,
      for (var i = page - 2; i <= page + 2; i++)
        if (i >= 1 && i <= pages) i,
    }.toList()..sort();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Sayfalı projeler'),
        actions: [
          IconButton(
            tooltip: 'Yeniden yükle',
            onPressed: loading ? null : () => fetch(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: CustomScrollView(
            controller: scroll,
            key: const Key('project-scroll'),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Projeler, sayfa sayfa.',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sayfalayın veya kaydırdıkça yükleyin. Görünümü ve yükleme stilini seçin.',
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: search,
                              onSubmitted: (_) => applySearch(),
                              decoration: const InputDecoration(
                                labelText: 'Proje veya müşteri ara',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: applySearch,
                            child: const Text('Ara'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            child: DropdownButtonFormField<int>(
                              key: ValueKey(request.size),
                              initialValue: request.size,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Kayıt / yükleme',
                              ),
                              items: [
                                for (final size in [5, 10, 20])
                                  DropdownMenuItem(
                                    value: size,
                                    child: Text('$size kayıt'),
                                  ),
                              ],
                              onChanged: (size) {
                                if (size != null)
                                  widget.onNavigate(
                                    request.copyWith(page: 1, size: size),
                                  );
                              },
                            ),
                          ),
                          FilterChip(
                            label: const Text('Örnek verilerle dene'),
                            selected: request.demo,
                            onSelected: (value) => widget.onNavigate(
                              request.copyWith(
                                page: 1,
                                demo: value,
                                search: '',
                              ),
                            ),
                          ),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'list',
                                icon: Icon(Icons.view_list_outlined),
                                label: Text('Liste'),
                              ),
                              ButtonSegment(
                                value: 'grid',
                                icon: Icon(Icons.grid_view_rounded),
                                label: Text('Grid'),
                              ),
                            ],
                            selected: {request.view},
                            onSelectionChanged: (values) => widget.onNavigate(
                              request.copyWith(view: values.single),
                            ),
                          ),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'pages',
                                label: Text('Sayfalı'),
                              ),
                              ButtonSegment(
                                value: 'lazy',
                                label: Text('Lazy loading'),
                              ),
                            ],
                            selected: {request.mode},
                            onSelectionChanged: (values) => widget.onNavigate(
                              request.copyWith(mode: values.single, page: 1),
                            ),
                          ),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'standard',
                                label: Text('Standart'),
                              ),
                              ButtonSegment(
                                value: 'skeleton',
                                label: Text('Skeleton'),
                              ),
                            ],
                            selected: {request.loading},
                            onSelectionChanged: (values) => widget.onNavigate(
                              request.copyWith(loading: values.single),
                            ),
                          ),
                        ],
                      ),
                      if (request.demo)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            '53 örnek kayıt · Yüklemeyi görmek için 650 ms demo gecikmesi. Arşive eklenmez.',
                            style: TextStyle(color: accent),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        loading && items.isEmpty
                            ? 'Kayıtlar hazırlanıyor…'
                            : '$start–$end / $total kayıt',
                        key: const Key('page-range'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (request.view == 'grid')
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;
                      final columns = width >= 900
                          ? 3
                          : width >= 600
                          ? 2
                          : 1;
                      return SliverGrid(
                        key: const Key('pagination-grid'),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 300,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              projectTile(context, items[index], true),
                          childCount: items.length,
                        ),
                      );
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    key: const Key('pagination-list'),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          projectTile(context, items[index], false),
                      childCount: items.length,
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (loading)
                        LoadingPlaceholder(
                          key: ValueKey('${request.loading}:${request.view}'),
                          style: request.loading,
                          view: request.view,
                          count: lazy && items.isNotEmpty
                              ? 3
                              : request.size.clamp(1, 6),
                        ),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(error!),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () =>
                                    fetch(append: lazy && items.isNotEmpty),
                                child: const Text('Yeniden dene'),
                              ),
                            ],
                          ),
                        ),
                      if (!loading && error == null && items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Kayıt bulunamadı. Aramayı değiştirin veya örnek verilerle deneyin.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (lazy &&
                          !loading &&
                          error == null &&
                          items.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        if (hasMore)
                          OutlinedButton.icon(
                            onPressed: () => fetch(append: true),
                            icon: const Icon(Icons.expand_more),
                            label: const Text('Daha fazla yükle'),
                          )
                        else
                          const Text('Tüm kayıtlar yüklendi'),
                        const SizedBox(height: 8),
                        const Text(
                          'Aşağı kaydırdıkça sıradaki kayıtlar yüklenir.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                      if (!lazy) ...[
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: !loading && page > 1
                                  ? () => widget.onNavigate(
                                      request.copyWith(page: page - 1),
                                    )
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                              label: const Text('Önceki'),
                            ),
                            for (
                              var index = 0;
                              index < numbers.length;
                              index++
                            ) ...[
                              if (index > 0 &&
                                  numbers[index] - numbers[index - 1] > 1)
                                const Text('…'),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: numbers[index] == page
                                      ? const Color(0xFFD8EEE8)
                                      : null,
                                ),
                                onPressed: loading || numbers[index] == page
                                    ? null
                                    : () => widget.onNavigate(
                                        request.copyWith(page: numbers[index]),
                                      ),
                                child: Text(
                                  '${numbers[index]}',
                                  semanticsLabel: 'Sayfa ${numbers[index]}',
                                ),
                              ),
                            ],
                            OutlinedButton.icon(
                              onPressed: !loading && page < pages
                                  ? () => widget.onNavigate(
                                      request.copyWith(page: page + 1),
                                    )
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                              label: const Text('Sonraki'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Sayfa $page / $pages'),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

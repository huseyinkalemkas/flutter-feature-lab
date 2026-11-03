/// Custom scheme: linkdemo://app/products/42?ref=kampanya
/// HTTPS: https://example.com/products/42?ref=kampanya
String? internalLocation(String input) {
  final uri = Uri.tryParse(input.trim());
  if (uri == null || uri.userInfo.isNotEmpty || uri.hasPort) return null;
  final internal =
      !uri.hasScheme && !uri.hasAuthority && uri.path.startsWith('/');
  final custom = uri.scheme == 'linkdemo' && uri.host == 'app';
  final https = uri.scheme == 'https' && uri.host == 'example.com';
  if (!internal && !custom && !https) return null;
  if (uri.hasFragment) return null;
  return uri.path + (uri.hasQuery ? '?${uri.query}' : '');
}

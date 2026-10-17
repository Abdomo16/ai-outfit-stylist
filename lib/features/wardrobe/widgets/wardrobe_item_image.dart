import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_colors.dart';

/// Wardrobe image loader: plain HTTP download + [Image.memory].
/// No cache-manager / CachedNetworkImage (those hung on spinner).
class WardrobeItemImage extends StatefulWidget {
  final String? imageUrl;
  final double? iconSize;
  final int? memCacheWidth;

  const WardrobeItemImage({
    super.key,
    required this.imageUrl,
    this.iconSize = 40,
    this.memCacheWidth,
  });

  @override
  State<WardrobeItemImage> createState() => _WardrobeItemImageState();
}

class _WardrobeItemImageState extends State<WardrobeItemImage> {
  static const Color _backdrop = Color(0xFFF5F5F5);
  static const _timeout = Duration(seconds: 30);

  /// Session memory cache so scroll / soft refresh does not re-download.
  static final Map<String, Uint8List> _sessionCache = {};

  Uint8List? _bytes;
  bool _loading = true;
  bool _failed = false;
  String? _requestedUrl;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant WardrobeItemImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _load();
    }
  }

  String? _normalizeUrl(String? raw) {
    if (raw == null) return null;
    var url = raw.trim();
    if (url.isEmpty) return null;
    // Supabase get_public_url sometimes appends a trailing "?".
    while (url.endsWith('?')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  Future<void> _load() async {
    final url = _normalizeUrl(widget.imageUrl);
    _requestedUrl = url;

    if (url == null || url.isEmpty) {
      setState(() {
        _bytes = null;
        _loading = false;
        _failed = true;
      });
      return;
    }

    if (!url.startsWith('http')) {
      setState(() {
        _bytes = null;
        _loading = false;
        _failed = false;
      });
      return;
    }

    final cached = _sessionCache[url];
    if (cached != null) {
      setState(() {
        _bytes = cached;
        _loading = false;
        _failed = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _failed = false;
      _bytes = null;
    });

    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (!mounted || _requestedUrl != url) return;

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        setState(() {
          _loading = false;
          _failed = true;
        });
        return;
      }

      _sessionCache[url] = response.bodyBytes;
      setState(() {
        _bytes = response.bodyBytes;
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted || _requestedUrl != url) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Widget _fallback(ColorScheme colors) {
    return ColoredBox(
      color: _backdrop,
      child: Center(
        child: Icon(
          Icons.checkroom,
          size: widget.iconSize,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _loadingWidget() {
    return const ColoredBox(
      color: _backdrop,
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  int _resolveMemCacheWidth(BuildContext context) {
    if (widget.memCacheWidth != null) return widget.memCacheWidth!;
    final mq = MediaQuery.of(context);
    return (mq.size.width * mq.devicePixelRatio / 2).round().clamp(200, 800);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final url = _normalizeUrl(widget.imageUrl);

    if (_loading) return _loadingWidget();
    if (_failed) return _fallback(colors);

    if (_bytes != null) {
      return ColoredBox(
        color: _backdrop,
        child: SizedBox.expand(
          child: Image.memory(
            _bytes!,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            cacheWidth: _resolveMemCacheWidth(context),
            errorBuilder: (_, _, _) => _fallback(colors),
          ),
        ),
      );
    }

    if (url != null && url.isNotEmpty && !url.startsWith('http')) {
      if (File(url).existsSync()) {
        return ColoredBox(
          color: _backdrop,
          child: SizedBox.expand(
            child: Image.file(
              File(url),
              fit: BoxFit.contain,
              cacheWidth: _resolveMemCacheWidth(context),
              errorBuilder: (_, _, _) => _fallback(colors),
            ),
          ),
        );
      }
    }

    return _fallback(colors);
  }
}

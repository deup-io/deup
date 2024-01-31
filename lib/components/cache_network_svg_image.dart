import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachedNetworkSvgImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final String? cacheKey;
  final Widget? placeholder;
  final Map<String, String>? httpHeaders;
  final BaseCacheManager? cacheManager;

  const CachedNetworkSvgImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.cacheKey,
    this.cacheManager,
    this.httpHeaders,
    this.placeholder,
    this.fit,
  }) : super(key: key);

  BaseCacheManager get _cacheManager => cacheManager ?? DefaultCacheManager();

  @override
  _CachedNetworkSvgImageState createState() => _CachedNetworkSvgImageState();
}

class _CachedNetworkSvgImageState extends State<CachedNetworkSvgImage> {
  late Future<Widget> _future;

  @override
  void initState() {
    _future = _loadImage();
    super.initState();
  }

  Future<Widget> _loadImage() async {
    final file = await widget._cacheManager.getSingleFile(
      widget.imageUrl,
      headers: widget.httpHeaders ?? {},
      key: widget.cacheKey ?? widget.imageUrl,
    );

    return Future.value(SvgPicture.file(
      file,
      fit: widget.fit ?? BoxFit.contain,
      width: widget.width,
      height: widget.height,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _future,
      initialData: Container(
        width: widget.width,
        height: widget.height,
        child: widget.placeholder,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) return snapshot.data!;
        return SizedBox(width: widget.width, height: widget.height);
      },
    );
  }
}

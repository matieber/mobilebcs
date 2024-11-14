
import 'package:flutter/material.dart';

class MyImage extends StatefulWidget {
  final ImageProvider? imageProvider;

  const MyImage(this.imageProvider,{Key? key}):super(key: key);

  @override
  State<MyImage> createState() => _MyImageState();
}

class _MyImageState extends State<MyImage> {
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getImage();
  }

  @override
  void didUpdateWidget(MyImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) {
      _getImage();
    }
  }

  void _getImage() {
    final ImageStream? oldImageStream = _imageStream;
    if(widget.imageProvider!=null) {
      _imageStream =
          widget.imageProvider!.resolve(createLocalImageConfiguration(context));
      if (_imageStream!.key != oldImageStream?.key) {
        final ImageStreamListener listener = ImageStreamListener(_updateImage);
        oldImageStream?.removeListener(listener);
        _imageStream!.addListener(listener);
      }
    }else{
      _imageStream=null;
      _imageInfo=null;
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _imageInfo?.dispose();
      _imageInfo = imageInfo;
    });
  }

  @override
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(_updateImage));
    _imageInfo?.dispose();
    _imageInfo = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawImage(
      image: _imageInfo?.image,
      scale: _imageInfo?.scale ?? 1.0,
    );
  }
}
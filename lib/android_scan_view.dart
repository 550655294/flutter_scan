import 'package:flutter/material.dart';

class _ScanFramePainter extends CustomPainter {

  _ScanFramePainter({this.lineMoveValue,required this.frameSize}) : assert(lineMoveValue != null);

  // 百分比值，0 ~ 1，然后计算Y坐标
  final double? lineMoveValue;


  //默认定义扫描框为 260边长的正方形
  final Size frameSize ;

  @override
  void paint(Canvas canvas, Size size) {
    // 按扫描框居中来计算，全屏尺寸与扫描框尺寸的差集 除以 2 就是扫描框的位置
    Offset diff = (size - frameSize) as Offset;
    double leftTopX = diff.dx / 2;
    double leftTopY = diff.dy / 2;
    //根据左上角的坐标和扫描框的大小可得知扫描框矩形
    var rect =
    Rect.fromLTWH(leftTopX, leftTopY, frameSize.width, frameSize.height);
    // 4个点的坐标
    Offset leftTop = rect.topLeft;
    Offset leftBottom = rect.bottomLeft;
    Offset rightTop = rect.topRight;
    Offset rightBottom = rect.bottomRight;


    //绘制罩层
    //画笔
    Paint paint = Paint()
      ..color = Colors.black.withOpacity(0.25) //透明灰
      ..style = PaintingStyle.fill; // 画笔的模式，填充
    //左侧矩形
    canvas.drawRect(Rect.fromLTRB(0, 0, leftTopX, size.height), paint);
    //右侧矩形
    canvas.drawRect(
      Rect.fromLTRB(rightTop.dx, 0, size.width, size.height),
      paint,
    );
    //中上矩形
    canvas.drawRect(Rect.fromLTRB(leftTopX, 0, rightTop.dx, leftTopY), paint);
    //中下矩形
    canvas.drawRect(
      Rect.fromLTRB(leftBottom.dx, leftBottom.dy, rightBottom.dx, size.height),
      paint,
    );

    final double cornerLength = 20.0;


    // 重新设置画笔
    paint
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square  // 解决因为线宽导致交界处不是直角的问题
      ..style = PaintingStyle.stroke;

    // 横向线条的坐标偏移
    Offset horizontalOffset = Offset(cornerLength, 0);
    // 纵向线条的坐标偏移
    Offset verticalOffset = Offset(0, cornerLength);
    // 左上角
    canvas.drawLine(leftTop, leftTop + horizontalOffset, paint);
    canvas.drawLine(leftTop, leftTop + verticalOffset, paint);
    // 左下角
    canvas.drawLine(leftBottom, leftBottom + horizontalOffset, paint);
    canvas.drawLine(leftBottom, leftBottom - verticalOffset, paint);
    // 右上角
    canvas.drawLine(rightTop, rightTop - horizontalOffset, paint);
    canvas.drawLine(rightTop, rightTop + verticalOffset, paint);
    // 右下角
    canvas.drawLine(rightBottom, rightBottom - horizontalOffset, paint);
    canvas.drawLine(rightBottom, rightBottom - verticalOffset, paint);

    //修改画笔线条宽度
    paint.strokeWidth = 2;
    // 扫描线的移动值
    var lineY = leftTopY + frameSize.height * (lineMoveValue??0);
    // 10 为线条与方框之间的间距，绘制扫描线
    canvas.drawLine(
      Offset(leftTopX + 10.0, lineY),
      Offset(rightTop.dx - 10.0, lineY),
      paint,
    );

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


class ScanFrame extends StatefulWidget {
   ScanFrame();

  @override
  State<ScanFrame> createState() => _ScanFrameState();
}


class _ScanFrameState extends State<ScanFrame> with TickerProviderStateMixin {
  Animation<double>? _animation;
  AnimationController? _controller;

  //起始之间的线性插值器 从 0.05 到 0.95 百分比。
  final Tween<double> _rotationTween = Tween(begin: 0.05, end: 0.95);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this, //实现 TickerProviderStateMixin
      duration: Duration(seconds: 3), //动画时间 3s
    );
    if (_controller != null) {
      _animation = _rotationTween.animate(_controller!)
        ..addListener(() => setState(() {}))
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _controller!.repeat();
          } else if (status == AnimationStatus.dismissed) {
            _controller!.forward();
          }
        });

      _controller!.repeat();
    }
  }

  @override
  void dispose() {
    // 释放动画资源
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanFramePainter(lineMoveValue: _animation?.value,
      frameSize:  Size.square(MediaQuery.of(context).size.width*0.7)),
      child: Container(),
    );
  }
}

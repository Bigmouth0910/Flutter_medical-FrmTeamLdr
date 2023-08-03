import 'package:flutter/material.dart';
import 'package:rxphoto/screens/CPoint.dart';
import 'package:path_drawing/path_drawing.dart';

extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

class MyCustomPainter extends CustomPainter {
  Map<String, List<CPoint>> drawPoints;
  String toolType;
  double injectionRadius;
  MyCustomPainter(
      {required this.drawPoints,
      required this.toolType,
      required this.injectionRadius});

  @override
  void paint(Canvas canvas, Size size) {
    const double moredashSize = 3;
    const double moregapSize = 15;
    const double pendashSize = 2;
    // final paint = Paint()
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = pendashSize
    //   ..color = Colors.blue;
    // canvas.drawLine(Offset(0, 0), Offset(100, 100), paint);
    drawPoints['pencil']?.forEach((element) {
      if (element.pathPoints!.length != 0) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = pendashSize
          ..color = element.isSelected == true ? Colors.blue : Colors.black;
        var path = Path()
          ..moveTo(element.pathPoints![0].dx, element.pathPoints![0].dy);
        element.pathPoints!.forEach((element) {
          path.lineTo(element.dx, element.dy);
        });
        canvas.drawPath(path, paint);
      }
      // canvas.drawPath(path, paint);
    });
    drawPoints['text']?.forEach((element) {
      final textSpan = TextSpan(
        text: element.content,
        style: TextStyle(
            color: element.isSelected ? Colors.blue : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      final textOffset = element.start;
      textPainter.paint(canvas, textOffset);
    });
    drawPoints['oval']?.forEach((element) {
      Offset startPoint = element.start;
      Offset endPoint = element.end;
      canvas.drawOval(
          Rect.fromPoints(startPoint, endPoint),
          Paint()
            ..color = element.isSelected ? Colors.blue : Colors.black
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    });
    drawPoints['injection']?.forEach((element) {
      Offset startPoint = element.start;
      var typecolor;
      typecolor = element.injectionType!.toColor();
      // if (element.injectionType == "Botox")
      //   typecolor = Colors.blue.withOpacity(0.3);
      // else if (element.injectionType == "Belkyra")
      //   typecolor = Colors.black.withOpacity(0.3);
      // else if (element.injectionType == "Hyaluronan")
      //   typecolor = Colors.yellow.withOpacity(0.3);
      canvas.drawCircle(
          startPoint,
          injectionRadius,
          Paint()
            ..color = element.isSelected ? Colors.blue : typecolor
            ..strokeWidth = 2
            ..style = PaintingStyle.fill);

      final textSpan = TextSpan(
        text: element.content,
        style: TextStyle(
            color: element.isSelected ? Colors.black : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      final textOffset = Offset(element.start.dx - injectionRadius / 2,
          element.start.dy - injectionRadius / 2);
      // final textOffset = Offset(size.width / 2 - textPainter.width / 2,
      //     size.height / 2 - textPainter.height / 2);
      textPainter.paint(canvas, textOffset);
    });
    drawPoints['more']?.forEach((element) {
      if (element.pathPoints!.length != 0) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = moredashSize
          ..color = element.isSelected == true ? Colors.blue : Colors.black;

        var path = Path()
          ..moveTo(element.pathPoints![0].dx, element.pathPoints![0].dy);
        element.pathPoints!.forEach((element) {
          path.lineTo(element.dx, element.dy);
        });
        canvas.drawPath(
            dashPath(path,
                dashArray:
                    CircularIntervalList<double>([moredashSize, moregapSize]),
                dashOffset: DashOffset.percentage(0.005)),
            paint);
      }
      // canvas.drawPath(path, paint);
    });
  }

  // 4
  @override
  bool shouldRepaint(MyCustomPainter delegate) {
    return true;
  }

  // @override
  // bool? hitTest(Offset position) {
  //   // TODO: implement hitTest
  //   return super.hitTest(position);
  // }
}

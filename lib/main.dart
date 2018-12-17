import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Oscilloscope Display Example",
      home: Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  @override
  _ShellState createState() => _ShellState();
}

class _ShellState extends State<Shell> with TickerProviderStateMixin {
  //AnimationController animationController;
  List<List<double>> traceWaves = [
    [],
    [],
    [],
    // [],
  ]; // [], []];

  double radians = 0.0;
  Timer _timer;
  double padding = 20.0;
  List<Point> vals = [];
  int ticknum = 0;
  int measurerate = 70; //99 with .001

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(milliseconds: 60), _generateTrace);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  _generateTrace(Timer t) {
    // generate our  values
/*
    var ichord = .3 * sin((radians * pi)) +
        .3 * sin((1.5 * radians * pi)) +
        .3 * sin(((5 / 4) * radians * pi));
    var vchord = .3 * sin(((3 / 2) * radians * pi)) +
        .3 * sin(((15 / 8) * radians * pi)) +
        .3 * sin(((9 / 8) * radians * pi));
    var vichord = .3 * sin(((5 / 3) * radians * pi)) +
        .3 * sin(((5 / 4) * radians * pi)) +
        .3 * sin((radians * pi));
    var ivchord = .3 * sin(((4 / 3) * radians * pi)) +
        .3 * sin(((5 / 4) * radians * pi)) +
        .3 * sin((radians * pi));
        */
    var cv = 0.5 * sin(2 * (radians * pi)); //+ .5 * cos((2.0 * radians * pi));
    var s2 = .5 * sin((3.0 * radians * pi));
    var s3 = cv + s2;

    // Add to the growing dataset
    setState(() {
      traceWaves[0].add(cv);
      traceWaves[1].add(s2);
      traceWaves[2].add(s3);
      //  traceWaves[3].add(ivchord);
    });

    // adjust to recyle the radian value ( as 0 = 2Pi RADS)
    radians += 0.012;
    if (radians >= 16.0) {
      radians = 0.0;
    }
    ticknum += 1;
    if (ticknum > measurerate) {
      vals.add(Point(0.5 * ((cos(2 * pi * radians)) + (cos(3 * pi * radians))),
          ((-sin(3 * pi * radians)) + (-sin(2 * pi * radians)))));
      if (vals.length > 1) {
        vals[0].x = (vals[0].x * (vals.length - 1) + vals.last.x) / vals.length;
        vals[0].y = (vals[0].y * (vals.length - 1) + vals.last.y) / vals.length;
      }
      ticknum = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    double radius = (MediaQuery.of(context).size.width) / 5;
    // Create A Scope Display for Sine

    Oscilloscope scopeOne = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.orange,
      padding: padding,
      backgroundColor: Colors.black,
      traceColors: [
        Colors.yellow,
        Colors.red,
        Colors.green,
        Colors.blue,
      ],
      yAxisMax: 1.0,
      yAxisMin: -1.0,
      dataSets: traceWaves,
    );

    // Generate the Scaffold
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Container(
                          height: 5.0,
                          width: radius,
                          decoration: BoxDecoration(
                              color: Colors.blue, shape: BoxShape.circle
                              //shape: BoxShape.circle,
                              ),
                        ),
                      ),
                      Center(
                        child: Transform(
                          transform: Matrix4.translationValues(
                              radius * (cos(2 * pi * radians)),
                              radius * (-sin(2 * pi * radians)),
                              0.0)
                            ..rotateZ(
                              -(2 * pi * radians),
                            ),
                          child: FractionalTranslation(
                            translation: Offset(-0.5, -0.5),
                            child: Container(
                              height: 30.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                //shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Transform(
                          transform: Matrix4.translationValues(
                              radius * (cos(3 * pi * radians)),
                              radius * (-sin(3 * pi * radians)),
                              0.0)
                            ..rotateZ(
                              -(3 * pi * radians),
                            ),
                          child: FractionalTranslation(
                            translation: Offset(-0.5, -0.5),
                            child: Container(
                              height: 30.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                //shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Transform(
                          transform: Matrix4.translationValues(
                              0.5 *
                                  (radius * (cos(2 * pi * radians)) +
                                      radius * (cos(3 * pi * radians))),
                              (radius * (-sin(3 * pi * radians)) +
                                  radius * (-sin(2 * pi * radians))),
                              0.0)
                            ..rotateZ(
                              -0.5 * (2 * pi * radians + 3 * pi * radians),
                            ),
                          child: FractionalTranslation(
                            translation: Offset(-0.5, -0.5),
                            child: Container(
                              height: 30.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                //shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]..addAll(List.generate(vals.length, (ip) {
                        return Center(
                          child: Transform(
                            transform: Matrix4.translationValues(
                                radius * vals[ip].x, radius * vals[ip].y, 0.0),
                            child: Container(
                              height: 10.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                  color: ip == 0 ? Colors.purple : Colors.white,
                                  shape: BoxShape.circle),
                            ),
                          ),
                        );
                      })),
                  ),
                )),
            Expanded(
              flex: 1,
              child: scopeOne,
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that defines a customisable Oscilloscope type display that can be used to graph out data
///
/// The [dataSet] arguments MUST be a List<double> -  this is the data that is used by the display to generate a trace
///
/// All other arguments are optional as they have preset values
///
/// [showYAxis] this will display a line along the yAxisat 0 if the value is set to true (default is false)
/// [yAxisColor] determines the color of the displayed yAxis (default value is Colors.white)
///
/// [yAxisMin] and [yAxisMax] although optional should be set to reflect the data that is supplied in [dataSet]. These values
/// should be set to the min and max values in the supplied [dataSet].
///
/// For example if the max value in the data set is 2.5 and the min is -3.25  then you should set [yAxisMin] = -3.25 and [yAxisMax] = 2.5
/// This allows the oscilloscope display to scale the generated graph correctly.
///
/// You can modify the background color of the oscilloscope with the [backgroundColor] argument and the color of the trace with [traceColor]
///
/// The [padding] argument allows space to be set around the display (this defaults to 10.0 if not specified)
///
/// NB: This is not a Time Domain trace, the update frequency of the supplied [dataSet] determines the trace speed.
class Oscilloscope extends StatefulWidget {
  final List<List<double>> dataSets;
  final double yAxisMin;
  final double yAxisMax;
  final double padding;
  final Color backgroundColor;
  final List<Color> traceColors;
  final Color yAxisColor;
  final bool showYAxis;

  Oscilloscope(
      {@required this.traceColors,
      this.backgroundColor = Colors.black,
      this.yAxisColor = Colors.white,
      this.padding = 10.0,
      this.yAxisMax = 1.0,
      this.yAxisMin = 0.0,
      this.showYAxis = false,
      @required this.dataSets});

  @override
  _OscilloscopeState createState() => _OscilloscopeState();
}

class _OscilloscopeState extends State<Oscilloscope> {
  double yRange;
  double yScale;

  @override
  void initState() {
    super.initState();
    yRange = widget.yAxisMax - widget.yAxisMin;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: double.infinity,
          width: 200.0,
          color: Colors.grey,
        ),
      )
    ]..addAll(List.generate(widget.dataSets.length, (dataNum) {
            return Container(
              padding: EdgeInsets.all(widget.padding),
              width: double.infinity,
              height: double.infinity,
              // color: widget.backgroundColor,
              child: ClipRect(
                child: CustomPaint(
                  painter: _TracePainter(
                      showYAxis: widget.showYAxis,
                      yAxisColor: widget.yAxisColor,
                      dataSet: widget.dataSets[dataNum],
                      traceColor: widget.traceColors[dataNum],
                      yMin: widget.yAxisMin,
                      yRange: yRange),
                ),
              ),
            );
          })));
  }
}

/// A Custom Painter used to generate the trace line from the supplied dataset
class _TracePainter extends CustomPainter {
  final List dataSet;
  final double xScale;
  final double yMin;
  final Color traceColor;
  final Color yAxisColor;
  final bool showYAxis;
  final double yRange;

  _TracePainter(
      {this.showYAxis,
      this.yAxisColor,
      this.yRange,
      this.yMin,
      this.dataSet,
      this.xScale = 1.0,
      this.traceColor = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final tracePaint = Paint()
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0
      ..color = traceColor
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..strokeWidth = 1.0
      ..color = yAxisColor;

    double yScale = (size.height / yRange);

    // only start plot if dataset has data
    int length = dataSet.length;
    if (length > 0) {
      // transform data set to just what we need if bigger than the width(otherwise this would be a memory hog)
      if (length > size.width) {
        dataSet.removeAt(0);
        length = dataSet.length;
      }

      // Create Path and set Origin to first data point
      Path trace = Path();
      trace.moveTo(0.0, size.height - (dataSet[0].toDouble() - yMin) * yScale);

      // generate trace path
      for (int p = 0; p < length; p++) {
        double plotPoint =
            size.height - ((dataSet[p].toDouble() - yMin) * yScale);
        trace.lineTo(p.toDouble() * xScale, plotPoint);
      }

      // display the trace
      canvas.drawPath(trace, tracePaint);

      // if yAxis required draw it here
      if (showYAxis) {
        Offset yStart = Offset(0.0, size.height - (0.0 - yMin) * yScale);
        Offset yEnd = Offset(size.width, size.height - (0.0 - yMin) * yScale);
        canvas.drawLine(yStart, yEnd, axisPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_TracePainter old) => true;
}

class Point {
  double x;
  double y;

  Point(double x, double y) {
    this.x = x;
    this.y = y;
  }
}

class Wave {
  // Using my trig so a circle is 4 quadrants of 100% each, full rotation is 400 %

  double portionOfComboWave; // Amplitude
  double progressPerFrame; // Frequency,
  double currentProgress; //

  Wave({
    this.portionOfComboWave = 0.0,
    this.progressPerFrame = 1.0,
    this.currentProgress = 0.0,
  });

  //  is cosine
  double z() {
    return cos(currentProgress % 400 * (9 / 10));
  }

  double k() {
    return sin(currentProgress % 400 * (9 / 10));
  }
}

class ComboWave {
  List<Wave> waves;

  ComboWave({@required this.waves});
}

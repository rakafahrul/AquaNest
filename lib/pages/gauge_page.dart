import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter/material.dart';

class TurbidityGauge extends StatelessWidget {
  final double turbidityValue;

  const TurbidityGauge({super.key, required this.turbidityValue});

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 100, // nilai maksimum NTUnya kalo mau diubah
          startAngle: 180,
          endAngle: 0,
          showTicks: false,
          showLabels: true,
          axisLineStyle: const AxisLineStyle(
            thickness: 0.15,
            thicknessUnit: GaugeSizeUnit.factor,
            cornerStyle: CornerStyle.bothCurve,
            color: Color(0xFFE0E0E0),
          ),
          pointers: <GaugePointer>[
            RangePointer(
              value: turbidityValue,
              width: 0.15,
              sizeUnit: GaugeSizeUnit.factor,
              color: Colors.orange,
              cornerStyle: CornerStyle.bothCurve,
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Text(
                '${turbidityValue.toStringAsFixed(1)} NTU',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              positionFactor: 0.1,
              angle: 90,
            ),
          ],
        )
      ],
    );
  }
}

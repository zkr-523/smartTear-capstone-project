import '../entities/analyte_value.dart';

abstract class AnalyteModelPort {
  String get modelVersion;

  Future<List<AnalyteValue>> estimate(List<double> features);
}


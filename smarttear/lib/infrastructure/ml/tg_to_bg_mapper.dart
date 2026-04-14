class TGtoBGMapper {
  double? map(double tearGlucose, {double scale = 18.0, double offset = 0.0}) {
    return (tearGlucose * scale) + offset;
  }
}


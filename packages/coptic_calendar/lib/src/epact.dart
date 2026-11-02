/// Traditional Coptic epacts (الأبقطي), as stated by Roshdy Wasef Bahman,
/// «التقويم القبطي وحساب الأبقطي» (St-Takla.org), via the owner's research
/// package «Coptic_Research_v2» (2026-11-02):
///
///   solar cycle  (دور الشمس)   = (AM − 4) mod 28
///   solar epact  (أبقطي الشمس) = (cycle + ⌊cycle / 4⌋) mod 7
///   lunar cycle  (دور القمر)   = (AM − 1) mod 19
///   lunar epact  (أبقطي القمر) = (11 × cycle) mod 30
///
/// AM is the Coptic year current at Easter. Deriving Easter itself from these
/// epacts (the traditional step) is pending the full chapter text; Easter is
/// computed by the three independent methods in easter.dart.
library;

class Epacts {
  const Epacts(this.solarCycle, this.solarEpact, this.lunarCycle, this.lunarEpact);

  final int solarCycle;
  final int solarEpact;
  final int lunarCycle;
  final int lunarEpact;
}

Epacts epactsForCopticYear(int am) {
  final solar = (am - 4) % 28;
  final lunar = (am - 1) % 19;
  return Epacts(solar, (solar + solar ~/ 4) % 7, lunar, (11 * lunar) % 30);
}

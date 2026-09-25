/// Which payer value a highlighted field shows.
enum GimtelFieldValue {
  /// The receiving bank name.
  bank,

  /// The receiving phone number.
  phone,

  /// The exact amount to transfer.
  amount,
}

/// A field to fill, in percent of the screenshot.
class GimtelField {
  /// Creates a field highlight at [x], [y] with size [w] x [h] (all in
  /// percent of the screenshot), showing [value].
  const GimtelField(this.x, this.y, this.w, this.h, this.value);

  /// Left edge, in percent of the screenshot width.
  final double x;

  /// Top edge, in percent of the screenshot height.
  final double y;

  /// Width, in percent of the screenshot width.
  final double w;

  /// Height, in percent of the screenshot height.
  final double h;

  /// Which payer value this field shows.
  final GimtelFieldValue value;
}

/// One bank-app screen of the walkthrough.
class GimtelScreen {
  /// Creates a screen with its [asset], tap position ([tapX], [tapY], in
  /// percent of the screenshot), and any highlighted [fields].
  const GimtelScreen(this.asset, this.tapX, this.tapY,
      [this.fields = const []]);

  /// Asset path of the screenshot.
  final String asset;

  /// Horizontal tap position, in percent of the screenshot width.
  final double tapX;

  /// Vertical tap position, in percent of the screenshot height.
  final double tapY;

  /// Fields highlighted on this screen, in the order they should animate.
  final List<GimtelField> fields;
}

const _dir = 'assets/gimtel_guide';

/// Real screens of each bank's Gimtel flow (redacted), with where to tap and what to fill.
const Map<String, List<GimtelScreen>> gimtelWalkthroughs = {
  'bankily': [
    GimtelScreen('$_dir/bankily-v2-1.webp', 18.8, 59),
    GimtelScreen('$_dir/bankily-v2-2.webp', 50, 14.5),
    GimtelScreen('$_dir/bankily-v2-3.webp', 50, 93, [
      GimtelField(4, 11.4, 92, 4.6, GimtelFieldValue.bank),
      GimtelField(4, 21.3, 72, 4.6, GimtelFieldValue.phone),
      GimtelField(4, 30.7, 92, 4.6, GimtelFieldValue.amount),
    ]),
    GimtelScreen('$_dir/bankily-v2-4.webp', 50, 92.8, [
      GimtelField(4, 24.4, 44, 4.8, GimtelFieldValue.amount),
    ]),
  ],
  'bci_pay': [
    GimtelScreen('$_dir/bci_pay-v2-1.webp', 38.8, 41.5),
    GimtelScreen('$_dir/bci_pay-v2-2.webp', 72.5, 16.7),
    GimtelScreen('$_dir/bci_pay-v2-3.webp', 50, 51.5, [
      GimtelField(4.5, 31.7, 91, 6.1, GimtelFieldValue.bank),
      GimtelField(4.5, 39.3, 91, 5.9, GimtelFieldValue.phone),
    ]),
    GimtelScreen('$_dir/bci_pay-v2-4.webp', 50, 82, [
      GimtelField(25, 25, 50, 6.4, GimtelFieldValue.amount),
    ]),
  ],
};

/// How long a screen plays: a beat per highlighted field, then the tap.
int gimtelScreenDurationMs(GimtelScreen s) => 3000 + s.fields.length * 700;

/// Delay between two highlighted fields.
const int gimtelFieldStaggerMs = 450;

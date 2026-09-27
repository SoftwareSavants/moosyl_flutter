## 2.1.0

- Add Gimtel payments for Bankily (Gimtel integration), BCI Pay and Amanty: the payer enters the number they pay from, sees where to send the money with an animated walkthrough of their bank app, and the SDK polls for the payment's status while the sheet is open (pausing in the background). Success is reported only once the payment is completed. Sandbox methods show a "Simulate transfer" button. Localized in English, French and Arabic. See "Gimtel payments" in the README.
- Gimtel method rows show a "Via Gimtel" subtitle.
- Payment method types this SDK version does not know are now skipped instead of throwing.
- Fix native Bankily: a payment that is not completed now shows "Payment not completed" (it showed an unknown error) and never reports success; a response without a payment code no longer displays the text "null".
- The English `payUsing` string now includes the method name ("Pay using {method}"), matching French and Arabic.
- Add `PaymentMethodTypes.tryParse` and `isGimtelMethod`.
- Requires `moosyl` ^2.0.0.
- Fix Gimtel status polling: the client now uses a 15 s receive / 10 s connect timeout (was 3 s/5 s) so a status call that runs the backend's inline bank sync doesn't time out, and resuming from the background always sends an immediate poll even if a pre-background status request is still in flight.

## 2.0.4

-Fix MoosylView UI

## 2.0.3

-remove react props naming...etc

## 2.0.2

- Remove node.js Example
- update the returned payment model desc
- payment view return bool instead of model
- Add `MoosylPaymentMethods` for embedding Moosyl payment method selection inside custom checkout UIs.
- Add `MoosylPaymentMethodsController` to continue payment from host app buttons.
- Add custom payment method row rendering with `renderMethod`.
- Update README.md with all current payment view, embedded payment methods, and custom methods UI options.

## 2.0.1

- Remove Get Payment Method
- update package screenshot desc 

## 2.0.0

- Update Package UI
- Add `MoosylFlutter.show()` — async helper for full page or bottom sheet, returns `PaymentSuccess?`.
- Add Masrivi decline handling: show dialog when payment fails (e.g. insufficient balance).

## 1.0.12

- Fix an issue with payment request fetching in the latest version

## 1.0.11

- Add documentation for including Moosyl localization delegates before using `MoosylView` and remove ManualPay

## 1.0.10

- Fix phone number including the country code in the payment screen

## 1.0.9

- Add GitHub Actions workflow for publishing to pub.dev

## 1.0.8

- Fix "Sedad" hardcoded payment method string in the payment screen

## 1.0.3

- Add MoosylLocalization class to hide localization strings from the public API

## 1.0.2

- Update repository references and localization classes to moosyl instead of SoftwarePay

## 1.0.1

- Update GitHub issue link in README.md

## 1.0.0

- First stable release of the Moosyl Flutter SDK 🎉!
- Update README.md with installation and usage instructions.
- **Breaking Change**: Rename the `authorization` parameter to `publishableApiKey` in the `MoosylView` widget.

## 0.1.0

- Fixed a bug in the payment processing flow.

## 0.0.2

- **Export fix**: Made sure that only the `Moosyl` widget is exported and internal classes such as `Moosyl`, `MoosylBody`, `AvailableMethodPage`, and `_ModeOfPaymentInfo` remain private and inaccessible from outside the package.
- Resolved issue with incorrect import exposure of internal classes.

## 0.0.1

- Initial release of the Moosyl Flutter SDK.

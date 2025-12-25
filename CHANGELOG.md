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

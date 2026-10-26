# Gas Bill Viewer

An unofficial Flutter app to check your **SNGPL** (Sui Northern Gas Pipelines) gas bill in a clean, mobile-friendly layout. Save your consumer numbers, type the captcha, and see what to pay, the due date, the charges breakup and your last 12 months marked paid or unpaid.

> **Unofficial.** Not affiliated with, endorsed by or published by SNGPL or any government body. See [Disclaimer](#disclaimer).


## Features

- Save multiple consumer numbers with labels (Home, Shop, Rental)
- Captcha is shown in the app and **you type it yourself**
- Amount payable within and after the due date, with the surcharge and days left
- Meter readings, units consumed, tariff, meter number and address
- Line-by-line charges breakup
- 12-month bill history with a paid / unpaid mark for each month
- Last checked amount and due date shown on the home list
- Side drawer with notice, how-to and developer info
- Blue and white Material 3 design, animated splash screen

## How it works

The app talks to the public bill page on `sngpl.com.pk`, the same way a browser does:

1. `GET /login.jsp?mdids=85` starts a session (cookie)
2. `GET /captcha-image.jpg` loads the captcha for that session
3. `POST /viewbill` sends the consumer number and the captcha you typed
4. The returned HTML is parsed in `lib/services/bill_parser.dart` and shown in the UI

### Paid / unpaid logic

SNGPL does not mark the newest bill as paid on its website. A payment only appears in the history once the **next** bill is issued. So:

- Older months: paid if a payment amount is listed, otherwise unpaid
- The newest bill is shown as **Pending**

## Tech stack

Flutter, Dart, `dio` + `cookie_jar` (session handling), `html` (parsing), `shared_preferences` (saved numbers), `url_launcher`.

## Getting started

```bash
git clone https://github.com/xeecode/sngpl-gas-bill-viewer.git
cd sngpl-gas-bill-viewer
flutter pub get
flutter run
```

Release builds on Android need internet permission in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Project structure

```
lib/
  core/       theme, app info, url helper
  models/     BillData, SavedConsumer
  services/   SNGPL session + captcha + parser, local storage
  screens/    splash, home, bill
  widgets/    cards, drawer, dialogs
```

If SNGPL changes their website, only `lib/services/bill_parser.dart` (and possibly the paths in `sngpl_service.dart`) should need updating.

## Disclaimer

This is an independent project built using SNGPL's public billing page. It does **not** bypass, solve or automate the captcha; the user always types it. Saved consumer numbers stay on your device. Bill data always comes from SNGPL, and the app may stop working if their website changes. Confirm payments with SNGPL before relying on this app.

## License

MIT, see [LICENSE](LICENSE).

## Author

Made by [xeecode](https://github.com/xeecode).

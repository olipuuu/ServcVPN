# ServcVPN

Fast and secure VPN client based on VLESS + Reality protocol.

## Features

- VLESS + Reality protocol support
- Kill Switch — blocks internet if VPN disconnects
- SNI traffic masking
- DNS leak protection
- Cross-platform: Windows, Android

## Download

Go to [Releases](https://github.com/olipuuu/ServcVPN/releases) and download:
- **Windows**: `ServcVPN-Setup.exe` — one-click installer
- **Android**: `app-release.apk`

## Usage

1. Download and install ServcVPN
2. Get your VLESS config (purchase via our Telegram bot)
3. Paste the config URI in the app
4. Connect!

## Build from source

### Windows
```bash
cd core && go build -o ../build/vpncli.exe ./cmd/vpncli
cd app && flutter build windows --release
```

### Android
```bash
cd app && flutter build apk --release
```

## License

All rights reserved.

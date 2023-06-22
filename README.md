# my_app

Demo WebView to verify an individuals identity via GreenID web UI

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Usage

Enter the individual verification token and click the verification icon.

The verification token can be retrieved via the Rocket Remit API.
 - POST https://api.staging.rocketremit.com/v3/register/details (submitted customer KYC data)
 - GET https://api.staging.rocketremit.com/v3/register/verification/greenid/token (retrieve existing token after KYC details entered)

 
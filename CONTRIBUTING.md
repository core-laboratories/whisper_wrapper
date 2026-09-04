# Contributing

Thank you for improving Whisper Wrapper.

## Development

1. Install a supported Flutter stable release, CMake, and the native toolchain
   for the platform being tested.
2. Run `flutter pub get`.
3. Run `dart format --set-exit-if-changed lib test example/lib`.
4. Run `flutter analyze` and `flutter test`.
5. Build at least one native example target affected by the change.

## Updating whisper.cpp

Run `./tool/update_whisper_cpp.sh` to resolve the latest stable upstream tag,
or pass an explicit tag for a reproducible update. The script copies the
CPU-only source manifest into each platform tree. The native engine is
vendored intentionally: published Flutter packages must remain complete and
must not depend on Git submodule initialization.

Changes are committed only to this repository. Do not create commits or push
branches in an upstream third-party checkout.

## Security and privacy

Speech recognition must remain fully on-device. Pull requests that introduce
mandatory remote processing, weaken user privacy, or otherwise reduce the
security of consuming applications will be declined.

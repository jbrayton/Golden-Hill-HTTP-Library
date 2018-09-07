#!/bin/sh

sudo xcode-select -s /Applications/Xcode-beta.app/Contents/Developer
carthage update --no-use-binaries --platform iOS
carthage update --no-use-binaries --platform Mac

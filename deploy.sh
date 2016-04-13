#!/bin/bash

if [ ! -z "$TRAVIS_TAG" ]; then
  npm install electron-packager -g
  electron-packager ./ Cantik --platform=all --arch=all
  zip -q -r cantik-linux-x64 Cantik-linux-x64
  zip -q -r cantik-linux-ia32 Cantik-linux-ia32
  zip -q -r cantik-darwin-x64 Cantik-darwin-x64
  zip -q -r cantik-win32-x64 Cantik-win32-x64
  zip -q -r cantik-win32-ia32 Cantik-win32-ia32
fi

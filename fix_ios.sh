#!/bin/zsh
# سكريبت تنظيف وإصلاح مشاكل iOS وPods لمشاريع Flutter

rm -rf ios/Pods ios/Podfile.lock
flutter clean
flutter pub get
cd ios
pod install
cd ..

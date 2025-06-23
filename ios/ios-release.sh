#!/bin/bash

# Archive
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release -archivePath build/Runner.xcarchive archive

# Export IPA
xcodebuild -exportArchive -archivePath build/Runner.xcarchive -exportOptionsPlist ios/exportOptions.plist -exportPath build/RunnerExport

# Upload (اختياري)
# xcrun altool --upload-app --type ios --file build/RunnerExport/Runner.ipa --username YOUR_APPLE_ID --password YOUR_APP_SPECIFIC_PASSWORD

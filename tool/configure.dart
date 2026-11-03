import 'dart:io';

// flutter create işleminden sonra çalıştırılır. Tekrar çalıştırılabilir.
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  var android = manifest.readAsStringSync();
  if (!android.contains('android.permission.INTERNET')) {
    android = android.replaceFirst(
      '<application',
      '<uses-permission android:name="android.permission.INTERNET" />\n    <application',
    );
  }
  if (!android.contains('android:scheme="linkdemo"')) {
    android = android.replaceFirst('</activity>', '''
            <meta-data android:name="flutter_deeplinking_enabled" android:value="true" />
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="linkdemo" android:host="app" />
            </intent-filter>
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="https" android:host="example.com" />
            </intent-filter>
        </activity>''');
  }
  manifest.writeAsStringSync(android);
  final plist = File('ios/Runner/Info.plist');
  var ios = plist.readAsStringSync();
  if (!ios.contains('<key>CFBundleURLTypes</key>')) {
    ios = ios.replaceFirst('<dict>', '''<dict>
    <key>FlutterDeepLinkingEnabled</key>
    <true/>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>com.example.deepLinkDemo</string>
            <key>CFBundleURLSchemes</key>
            <array><string>linkdemo</string></array>
        </dict>
    </array>''');
    plist.writeAsStringSync(ios);
  }
  stdout.writeln('Android ve iOS custom scheme ayarları tamamlandı.');
}

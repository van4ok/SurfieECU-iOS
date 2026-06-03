# Surfie ECU APK Reverse Engineering Report

Source APK: `Surfie-ECU.apk`

## Tooling Used

- `apktool 3.0.2`: decoded manifest, resources, smali, assets, native libraries.
- `jadx 1.5.5`: decompiled Java/Kotlin-like sources. Result had 38 decompiler errors, but business JS/assets were recovered.
- `dex2jar 2.4`: generated `reverse/Surfie-ECU-dex2jar.jar` after rerunning with system Java.
- `aapt`: captured `reverse/aapt-badging.txt`, `reverse/aapt-permissions.txt`, `reverse/aapt-list.txt`.
- JADX GUI was downloaded as part of the JADX release package, but no GUI inspection was needed after CLI recovery.
- MobSF was not available locally.

## APK Identity

- Package: `com.miran.ecu`
- App label: `SURFIE ECU`
- Version: `1.0.0`, code `100`
- minSdk: `21`
- targetSdk: `28`
- compileSdk: `35`
- Native ABI: `arm64-v8a`
- Framework: DCloud/uni-app Vue 3 container.

## Manifest Components

Activities:
- `io.dcloud.PandoraEntry`: launcher.
- `io.dcloud.PandoraEntryActivity`
- `io.dcloud.feature.nativeObj.photoview.PhotoActivity`
- `io.dcloud.WebAppActivity`
- `io.dcloud.ProcessMediator`
- `io.dcloud.WebviewActivity`
- `com.dmcbig.mediapicker.PickerActivity`
- `com.dmcbig.mediapicker.PreviewActivity`
- `io.dcloud.feature.gallery.imageedit.IMGEditActivity`
- `io.dcloud.sdk.activity.WebViewActivity`

Service:
- `io.dcloud.sdk.base.service.DownloadService`

Receivers:
- `com.taobao.weex.WXGlobalEventReceiver`
- `androidx.profileinstaller.ProfileInstallReceiver`

Providers:
- `io.dcloud.common.util.DCloud_FileProvider`
- `io.dcloud.sdk.base.service.provider.DCloudAdFileProvider`
- `androidx.startup.InitializationProvider`

## Permissions

The APK requests storage/media, network, badge, Wi-Fi, package install, vibration, camera, account, wake lock, flashlight, settings, phone, location, and Bluetooth permissions. Relevant to recovered functionality:
- `android.permission.BLUETOOTH`
- `android.permission.BLUETOOTH_ADMIN`
- `android.permission.BLUETOOTH_SCAN`
- `android.permission.BLUETOOTH_CONNECT`
- `android.permission.ACCESS_COARSE_LOCATION`
- `android.permission.ACCESS_FINE_LOCATION`
- `android.permission.INTERNET`
- `android.permission.CALL_PHONE`

## Libraries

Found:
- DCloud / uni-app / Weex runtime.
- OkHttp / Okio in container code.
- Kotlin and kotlinx.coroutines `1.8.1`.
- AndroidX appcompat/core/webkit/recyclerview/startup/profileinstaller.
- qiun-data-charts in JS assets.
- CryptoJS/pako-like bundled JS utilities.
- Native DCloud/Weex/image libraries: `libweexjss.so`, `libweexcore.so`, `libuts-runtime.so`, `lib39285EFA.so`, image/gif/webp helpers.

Not found as business dependencies:
- Retrofit: not found.
- RxJava: not found.
- MQTT/Paho: not found.
- Firebase: not found.
- Business WebSocket: not found.
- Business JNI protocol: not found; native libraries are framework/runtime libraries.

## Screens

Recovered routes:
- `pages/index/index`: main live ECU telemetry screen.
- `pages/index/about`: about/contact screen.

Requested screens not present in recovered routes:
- Login
- Dashboard as separate route
- ECU Control
- Ride Statistics
- Firmware Update
- Settings

ASSUMPTION: The login/profile strings in `app-service.js` are template strings from the bundled framework/app scaffold, not active Surfie ECU screens, because no route or render function defines those pages.

## Business Logic

The actual app scans for BLE devices, connects to a selected peripheral, enumerates all services, subscribes to every notify/indicate characteristic, and parses incoming ECU telemetry packets. It renders:
- Runtime.
- Speed gauge, max 100 km/h.
- RPM gauge, max 12000 rpm.
- Oil consumption per 100 KM.
- Oil consumption per hour.
- `Y` value.
- Throttle valve voltage.
- Inlet temperature.
- Engine temperature.
- 16 fault/status indicators.

About screen:
- `MOTOR SURFIE ECU`
- `V1.0.0`
- `TEL:(+86)13861187887`
- `https://www.surfie.com`
- Copyright text.

## Secrets and Configuration

Recovered generic uniCloud config:
- Provider: `aliyun`
- Space ID: `mp-30f0d080-8681-43f6-9e86-e089525baf54`
- Client secret: `ZUtZ0M1oiqucYjQIAOtrag==`
- Endpoint: `https://api.next.bspapp.com`

No active Surfie business cloud function invocation was found on the recovered pages.

## Network Traffic

Recovered business REST endpoints: none.

Recovered MQTT/WebSocket/TCP/UDP business traffic: none.

The bundle contains generic uniCloud SDK code and framework network code, including default cloud endpoints, but the active Surfie telemetry screen does not call them.

## Unrecoverable From This APK

- Fixed BLE service UUID and characteristic UUID: Android discovers them dynamically at runtime.
- Firmware update protocol: no screen, endpoint, or BLE command sequence found.
- Authentication flow: no active route or request found.
- Ride statistics persistence/history: not found.
- ECU control commands beyond generic write-to-all-writable-characteristics helper: no UI or command strings found.

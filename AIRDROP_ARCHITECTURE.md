# Meerkat AirDrop-Everywhere Architecture

## 🎯 Vision
Create a universal, cross-platform file sharing experience that works like AirDrop but across **Android, iOS, macOS, Windows** - with automatic discovery when devices come close, even when the app isn't actively open.

---

## 📱 Platform Capabilities Matrix

| Platform | Background Discovery | Always-On Capability | Best APIs | NFC Support |
|----------|---------------------|----------------------|-----------|-------------|
| **Android** | ✅ Yes (Foreground Service) | High | Nearby Connections, BLE, Wi-Fi Direct | ✅ Full (HCE, NDEF) |
| **iOS** | ⚠️ Limited | Low | MultipeerConnectivity, CoreBluetooth (restricted) | ⚠️ Read-only NDEF |
| **macOS** | ✅ Yes (Launch Agent) | High | MultipeerConnectivity, mDNS, BLE | ❌ No |
| **Windows** | ✅ Yes (Background Service) | High | WinRT BLE, mDNS, TCP | ❌ No |

---

## 🏗️ System Architecture

### Phase 1: Discovery Layer (How devices find each other)

```
┌─────────────────────────────────────────────────────────────┐
│                    DISCOVERY LAYER                           │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ BLE Advertise│  │ mDNS/DNS-SD │  │  NFC/QR Tap  │      │
│  │              │  │              │  │              │      │
│  │ • Low power  │  │ • LAN only   │  │ • Bootstrap  │      │
│  │ • Cross-plat │  │ • Desktop++ │  │ • Fast pair  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  Broadcasts: Device ID + Capabilities + Ephemeral Token     │
└─────────────────────────────────────────────────────────────┘
```

**Implementation Priority:**
1. **BLE (Bluetooth Low Energy)** - Primary for mobile
2. **mDNS** - Primary for desktop/LAN
3. **NFC/QR** - Fast bootstrap option

### Phase 2: Handshake & Security

```
┌─────────────────────────────────────────────────────────────┐
│                    HANDSHAKE LAYER                           │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Device A ──────────────────────────────────────── Device B  │
│     │                                                   │     │
│     │  1. Exchange Public Keys (ECDH)                 │     │
│     │ ─────────────────────────────────────────────> │     │
│     │                                                   │     │
│     │  2. Derive Session Key + Generate Pairing Code  │     │
│     │ <────────────────────────────────────────────── │     │
│     │                                                   │     │
│     │  3. User Confirms 6-Digit Code on Both Screens  │     │
│     │    (Anti-MITM protection)                        │     │
│     │                                                   │     │
│     │  4. Establish Encrypted Channel                  │     │
│     │ <───────────────────────────────────────────────> │     │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**Security:**
- ECDH (Elliptic Curve Diffie-Hellman) for key exchange
- AES-256-GCM for transport encryption
- SHA-256 for integrity verification
- 6-digit pairing code for MITM prevention
- Optional: Save trusted devices for auto-accept

### Phase 3: Transport Layer (How files move)

```
┌─────────────────────────────────────────────────────────────┐
│                    TRANSPORT LAYER                           │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Priority Order (automatic fallback):                        │
│                                                               │
│  1. ⚡ Nearby Connections (Android-to-Android)               │
│     └─> Up to 1 Gbps, automatic Wi-Fi Direct               │
│                                                               │
│  2. ⚡ Wi-Fi Direct (Android, Windows)                       │
│     └─> 100-600 Mbps, direct P2P                           │
│                                                               │
│  3. 🌐 WebRTC DataChannel (Universal)                       │
│     └─> NAT traversal, cross-platform, 50-200 Mbps         │
│                                                               │
│  4. 🔵 BLE (Signaling/Tiny files only)                      │
│     └─> < 1 Mbps, for coordination only                    │
│                                                               │
│  5. ☁️ TURN Relay (Last resort)                            │
│     └─> Cloud relay when P2P fails                         │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Implementation Roadmap

### MVP Phase (2-3 weeks) - **Start Here**

**Goal:** Prove the concept with Android + Desktop

#### Week 1: Android Background Discovery + WebRTC
- [x] Add `local_auth` for biometric security
- [ ] Create Android foreground service for BLE advertising
- [ ] Implement BLE scanner to detect nearby Meerkat devices
- [ ] Add WebRTC peer connection with data channels
- [ ] Basic file transfer over WebRTC

**Tech Stack:**
```yaml
dependencies:
  flutter_webrtc: ^0.11.10  # WebRTC for Flutter
  flutter_blue_plus: ^1.32.12  # BLE
  permission_handler: ^11.3.1  # Already have
```

**Android Native Code Needed:**
```kotlin
// ForegroundService for always-on advertising
class MeerkatDiscoveryService : Service() {
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Show persistent notification
        // Start BLE advertising with service UUID
        // Listen for incoming connections
        return START_STICKY
    }
}
```

#### Week 2: macOS/Windows Desktop Agent
- [ ] Create macOS Launch Agent (runs at login)
- [ ] Create Windows Background Service/Autostart
- [ ] Implement mDNS advertising on LAN
- [ ] WebRTC signaling between mobile ↔ desktop

**macOS:**
```xml
<!-- ~/Library/LaunchAgents/com.meerkat.discovery.plist -->
<plist>
  <dict>
    <key>Label</key>
    <string>com.meerkat.discovery</string>
    <key>ProgramArguments</key>
    <array>
      <string>/Applications/Meerkat.app/Contents/MacOS/meerkat-agent</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
  </dict>
</plist>
```

#### Week 3: Security + UX
- [ ] Implement ECDH key exchange
- [ ] Add 6-digit pairing code display
- [ ] Trusted devices list
- [ ] System notifications for incoming transfers
- [ ] Accept/Reject UI

---

### Phase 2 (2-3 weeks) - **iOS Integration**

**Challenge:** iOS doesn't allow true background networking

**Solution:** Hybrid approach
1. **Foreground:** Full MultipeerConnectivity when app is open
2. **Background:** Limited CoreBluetooth advertising (low power)
3. **NFC Trigger:** Use NDEF tags to launch app when tapped

**iOS Specific:**
```swift
// MultipeerConnectivity for discovery
let peerID = MCPeerID(displayName: UIDevice.current.name)
let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
let advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: ["version": "1.0"], serviceType: "meerkat")
```

**Limitations:**
- User must open app or tap NFC to initiate
- Background CoreBluetooth is very limited (Apple may reject)
- No true "always-on" like AirDrop (AirDrop is system-level)

---

### Phase 3 (2 weeks) - **NFC Bootstrap**

**Android:**
```kotlin
// HCE (Host Card Emulation) for tap-to-pair
class MeerkatNfcService : HostApduService() {
    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        // Return session token + device ID
        return sessionToken.toByteArray()
    }
}
```

**iOS:**
```swift
// NDEF reading to launch app
let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
session.begin()
```

**Flow:**
1. User taps phones together
2. NFC exchanges ephemeral session token
3. App opens (or service activates) on both devices
4. WebRTC/Wi-Fi Direct establishes for file transfer

---

### Phase 4 (Ongoing) - **Polish & Scale**

- [ ] Nearby Connections API (Android fast path)
- [ ] Cloud signaling server (Firebase or custom WebSocket)
- [ ] Resume interrupted transfers
- [ ] Transfer history sync across devices
- [ ] Group transfers (1-to-many)
- [ ] File previews before accepting

---

## 🛠️ Technical Decisions

### Why WebRTC?
✅ Cross-platform (Flutter plugin available)  
✅ NAT traversal with STUN/TURN  
✅ Encrypted by default (DTLS)  
✅ Fast data channels (not just video)  
✅ Works on all platforms

### Why NOT Pure BLE for Transfer?
❌ Too slow (~1 Mbps)  
❌ Android requires location permissions  
❌ iOS background restrictions

### Why Foreground Service (Android)?
✅ Only way to keep advertising while "closed"  
✅ Required by Google (must show notification)  
✅ User can disable if battery concerned

---

## 📊 Performance Targets

| Scenario | Speed Target | Technology |
|----------|--------------|------------|
| Android → Android (close) | 500+ Mbps | Nearby Connections / Wi-Fi Direct |
| Android → macOS (same WiFi) | 200+ Mbps | WebRTC DataChannel |
| iOS → iOS | 100+ Mbps | MultipeerConnectivity |
| Cross-platform (NAT) | 50-100 Mbps | WebRTC + TURN |
| Fallback (mobile data) | 5-20 Mbps | TURN Relay |

---

## 🔒 Privacy & Permissions

### Android
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.NFC" />
```

### iOS
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>Meerkat needs local network access to discover nearby devices</string>
<key>NSBonjourServices</key>
<array>
    <string>_meerkat._tcp</string>
</array>
<key>NFCReaderUsageDescription</key>
<string>Tap to pair with nearby devices</string>
```

---

## 🎓 Learning Resources

- [WebRTC for Flutter](https://pub.dev/packages/flutter_webrtc)
- [Android Nearby Connections](https://developers.google.com/nearby/connections/overview)
- [iOS MultipeerConnectivity](https://developer.apple.com/documentation/multipeerconnectivity)
- [BLE Advertising Guide](https://punchthrough.com/android-ble-guide/)

---

## 📝 Next Steps

1. **Immediate (This Week):**
   - Complete biometric security UI in settings
   - Create Android BLE advertisement service
   - Test WebRTC peer connection between 2 Android devices

2. **Short Term (Next 2 Weeks):**
   - Build desktop agent for macOS/Windows
   - Implement mDNS discovery
   - Add encrypted handshake

3. **Medium Term (Month 2):**
   - iOS integration with limitations
   - NFC tap-to-pair
   - Production-ready security

4. **Long Term:**
   - Cloud signaling server
   - Group transfers
   - Transfer resume
   - Analytics & monitoring

---

## 💡 Key Insights

**What Works:**
- Android: Can achieve true "always-on" with foreground service
- Desktop: Launch agents provide excellent UX
- WebRTC: Universal transport that actually works cross-platform

**What Doesn't:**
- iOS: Apple restricts background networking heavily
- Pure BLE: Too slow for real file transfers
- NFC alone: Can't handle large files, use for bootstrap only

**Best UX Compromise:**
- Android/Desktop: Always-on background discovery ✅
- iOS: Require user to open app OR tap NFC to initiate ⚠️
- All platforms: Show clear pairing code for security ✅

---

**Ready to start?** Let's build the MVP Phase first - I'll help you create:
1. Biometric security settings (next)
2. Android BLE foreground service
3. WebRTC file transfer between 2 devices

Pick which one you want me to code next! 🚀

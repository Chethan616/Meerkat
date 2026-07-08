# 🦊 Meerkat — Project Roadmap

> **A fast, private, cross-platform file sharing app — AirDrop for everyone.**  
> Built on Flutter + Rust. Inspired by LocalSend. Designed for the next generation.

---

## 📌 Current State — v1.0.0

Meerkat v1.0.0 ships as a fully working fork of LocalSend with:

- ✅ LAN-based peer discovery via mDNS
- ✅ HTTPS file transfer (direct device-to-device, no server)
- ✅ Cross-platform: Android, iOS, macOS, Windows, Linux
- ✅ QR code sharing
- ✅ Biometric lock (local_auth) for send & receive
- ✅ Local notifications for incoming transfers
- ✅ Rust core library (`localsend` crate) with HTTP + WebRTC + Crypto modules
- ✅ Windows MSI installer (WiX)
- ✅ Custom Meerkat branding & icons
- ✅ WebRTC signaling infrastructure (core/src/webrtc)

---

## 🗺️ Roadmap Overview

```
v1.0.0  ──► v1.1.0 (Security & UX)
               └──► v1.2.0 (BLE Background Discovery)
                       └──► v1.3.0 (WebRTC P2P Transfer)
                               └──► v2.0.0 (Distributed Architecture)
                                       └──► v2.1.0 (NFC + Group Transfers)
                                               └──► v2.2.0 (Analytics & CLI)
```

---

## 🔜 v1.1.0 — Security & Settings Polish
**Target: 2–3 weeks**

### 🔐 Security
- [ ] **ECDH key exchange** — Replace static RSA test keys in `core/src/main.rs` with per-session ECDH key negotiation
- [ ] **6-digit pairing code** — Anti-MITM display on both devices during new device pairing
- [ ] **Trusted devices list** — Remember paired devices; optionally auto-accept future transfers
- [ ] **Transfer PIN protection** — Optional PIN required before receiver can accept (extends current biometric lock)
- [ ] **Certificate pinning** — Pin device fingerprints so MITM is detectable even on hostile networks
- [ ] Remove hardcoded test RSA private key from `core/src/main.rs` (security risk in production builds)

### 🎨 Settings & UX
- [ ] **Settings page overhaul** — `settings_tab.dart` needs splitting into focused sub-pages (Security, Network, Appearance, Advanced)
- [ ] **Dark/Light/System theme toggle** with Material You dynamic color support
- [ ] **Transfer speed display** — Real-time MB/s counter on `progress_page.dart`
- [ ] **File preview before accepting** — Show thumbnail/size/type on receive confirmation dialog
- [ ] **Language page improvements** — Show native language names, add search/filter

### 🐛 Bug Fixes
- [ ] Fix `in_app_purchase` FOSS_REMOVE stub — should be absent from FOSS variant at compile time
- [ ] Resolve `gal` stub on desktop — ensure gallery save is clearly disabled, not silently failing

---

## 🔜 v1.2.0 — BLE Background Discovery (AirDrop Phase 1)
**Target: 1 month**

Implement the Discovery Layer from `AIRDROP_ARCHITECTURE.md`.

### 📡 Android Foreground Service
- [ ] `MeerkatDiscoveryService` — Android foreground service with persistent notification
- [ ] BLE advertising: broadcast Meerkat UUID + device alias + ephemeral token
- [ ] BLE scanning: detect nearby Meerkat devices even when app is in background
- [ ] Auto-show transfer popup when a known trusted device is detected nearby

### 🖥️ Desktop Background Agent
- [ ] **macOS Launch Agent** — `com.meerkat.discovery.plist` runs at login, advertises via mDNS
- [ ] **Windows Startup Service** — Register via registry autorun, mDNS advertisement
- [ ] System tray icon with "Nearby devices" quick-send flyout

### 🔵 iOS (Limited Background)
- [ ] CoreBluetooth background advertising (restricted mode — beacon only)
- [ ] NDEF NFC tag read → open Meerkat app and initiate transfer
- [ ] Push notification fallback when a nearby device is detected via server relay

### 📦 New Dependencies
```yaml
flutter_webrtc: ^0.11.10
flutter_blue_plus: ^1.32.12
```

---

## 🔜 v1.3.0 — WebRTC P2P File Transfer
**Target: 6 weeks**

Activate the WebRTC transport layer already present in the Rust core (`core/src/webrtc`).

### ⚡ Transport Upgrade
- [ ] **Integrate `flutter_webrtc`** into Flutter app layer (Dart ↔ Rust via `flutter_rust_bridge`)
- [ ] **Wi-Fi Direct / Nearby Connections** on Android-to-Android (500+ Mbps)
- [ ] **NAT traversal** with STUN servers (`stun:stun.l.google.com:19302`)
- [ ] **TURN relay** as last resort when both devices are behind strict NAT
- [ ] Automatic transport negotiation: Nearby Connections → Wi-Fi Direct → WebRTC → TURN → HTTPS

### 📊 Performance Targets

| Scenario | Target Speed | Transport |
|---|---|---|
| Android → Android (same room) | 500+ Mbps | Nearby Connections |
| Android → Windows (same WiFi) | 200+ Mbps | WebRTC DataChannel |
| iOS → iOS | 100+ Mbps | MultipeerConnectivity |
| Cross-platform (NAT traversal) | 50–100 Mbps | WebRTC + STUN |
| Fallback | 5–20 Mbps | TURN Relay |

---

## 🔜 v2.0.0 — Distributed Architecture (Couchbase Integration)
**Target: 2–3 months**

Transform Meerkat into a truly distributed system with Couchbase as the coordination and sync layer.

### 🏗️ Why Couchbase?
Couchbase is a **distributed NoSQL database** designed for:
- **Edge + Mobile sync** via Couchbase Lite (Sync Gateway) — perfect for offline-first mobile apps
- **Eventual consistency** with conflict resolution — handles intermittent LAN connectivity
- **Horizontal scaling** of the signaling/relay server across regions
- **Full-text search** for transfer history and device discovery
- **Real-time eventing** for automatic session expiry and transfer triggers

### 🗄️ Distributed Components

#### 1. Couchbase Lite on Device (Mobile)
- [ ] Embed Couchbase Lite in the Flutter app
- [ ] Store transfer history, trusted devices, and preferences locally
- [ ] Sync history across user's own devices (phone ↔ laptop) via Sync Gateway

#### 2. Couchbase Server (Signaling & Relay)
- [ ] Replace WebSocket signaling with Couchbase-backed server
- [ ] Cluster: minimum 3 nodes for HA, auto-failover enabled
- [ ] Buckets: `devices`, `sessions`, `transfers`, `history`
- [ ] XDCR replication across geo-regions for low-latency signaling

#### 3. Sync Gateway
- [ ] Role-based access: each user syncs only their own transfer history
- [ ] Delta sync — only changed documents replicate (mobile bandwidth efficient)
- [ ] Conflict resolution: last-write-wins for settings, merge for history

#### 4. Distributed Transfer Sessions
```
Device A ──[BLE/mDNS]──► Device B
    │                         │
    └──────[Couchbase]─────────┘
         (session document)
         - session_id
         - participants[]
         - files[]
         - status: pending|active|done|failed
         - created_at / expires_at (TTL)
```

### 🔧 Server Upgrade (`server/` directory)
- [ ] Migrate `server/src/` (Rust) to use the `couchbase` crate
- [ ] Implement N1QL queries for session lookup and device discovery
- [ ] Add Couchbase Eventing function to expire stale sessions (TTL documents)
- [ ] Deploy with Docker Compose: `couchbase` + `sync-gateway` + `meerkat-server`

### 📋 Document Schema

```json
// devices bucket
{
  "type": "device",
  "id": "uuid-v4",
  "alias": "Chethan's Phone",
  "platform": "android",
  "fingerprint": "sha256-of-cert",
  "last_seen": "2026-07-08T14:00:00Z",
  "trusted_by": ["device-id-1", "device-id-2"]
}

// sessions bucket (TTL: 300s)
{
  "type": "session",
  "id": "uuid-v4",
  "sender": "device-id",
  "receiver": "device-id",
  "files": [{ "name": "video.mp4", "size": 10485760 }],
  "status": "pending",
  "sdp_offer": "...",
  "sdp_answer": "...",
  "ice_candidates": []
}

// history bucket
{
  "type": "transfer",
  "id": "uuid-v4",
  "from": "device-id",
  "to": "device-id",
  "files": [],
  "bytes_transferred": 10485760,
  "duration_ms": 1200,
  "completed_at": "2026-07-08T14:00:00Z",
  "status": "success"
}
```

### 🌍 Distributed Systems Properties

| Property | How Meerkat Achieves It |
|---|---|
| **Fault Tolerance** | Couchbase auto-failover, 3-node cluster minimum |
| **Horizontal Scaling** | Add Couchbase nodes + Sync Gateway replicas independently |
| **Partition Tolerance** | Local LAN transfer works fully offline; syncs on reconnect |
| **Eventual Consistency** | Sync Gateway delta sync with configurable conflict resolution |
| **Data Replication** | XDCR (Cross-Datacenter Replication) across geo-regions |
| **CAP Theorem** | Tunable: strong consistency for sessions, eventual for history |

---

## 🔜 v2.1.0 — NFC Tap-to-Send + Group Transfers
**Target: +1 month after v2.0.0**

### 📱 NFC Tap-to-Pair
- [ ] **Android HCE** — `MeerkatNfcService` extends `HostApduService`; tap phones → NFC exchanges ephemeral session token → WebRTC handshake auto-starts
- [ ] **iOS NDEF read** — launches app via universal link with session pre-filled

### 👥 Group Transfers (1-to-Many)
- [ ] Select multiple recipients from nearby devices list
- [ ] Couchbase session document supports `receivers[]` array
- [ ] Progress tracked per-recipient in parallel WebRTC connections
- [ ] Group send UI with individual per-device progress bars

### 📂 Resume Interrupted Transfers
- [ ] Chunk files into 4MB segments; store progress in Couchbase Lite
- [ ] On reconnect, resume from last acknowledged chunk
- [ ] Visual indicator: "Resuming from 67%…"

---

## 🔜 v2.2.0 — Analytics, Monitoring & CLI
**Target: Ongoing**

### 📊 Observability
- [ ] Self-hosted transfer analytics dashboard (no cloud telemetry)
- [ ] Prometheus metrics endpoint on `meerkat-server`
- [ ] Grafana dashboard: transfers/sec, avg speed, failure rate, active sessions

### 🖥️ CLI Tool (`cli/` directory)
- [ ] `meerkat send <file> --to <device>` — headless send from terminal
- [ ] `meerkat discover` — list nearby Meerkat devices on LAN
- [ ] `meerkat receive --dir ~/Downloads` — always-on receive mode for servers
- [ ] Unix pipe support: `cat file.txt | meerkat send --to phone`

### 🔌 Plugin API
- [ ] Public Dart API for embedding Meerkat transfer in other Flutter apps
- [ ] Rust FFI API for native desktop integration
- [ ] Webhook support: POST to a URL when a transfer completes

---

## 📦 Release History

| Version | Date | Highlights |
|---|---|---|
| v1.0.0 | July 2026 | Initial release — Meerkat branding, biometric auth, Windows MSI, local notifications |

---

## 🏆 Distributed Systems — Academic Highlights

For the **Couchbase submission**, key distributed systems concepts demonstrated:

1. **mDNS peer discovery** — zero-config LAN device discovery (like DNS-SD in distributed systems)
2. **HTTPS mutual TLS** — per-device certificates for auth without a central CA
3. **WebRTC with STUN/ICE** — NAT traversal, a core distributed networking challenge
4. **Couchbase Sync Gateway** — mobile-to-cloud sync with conflict resolution (AP-leaning CAP system)
5. **Tokio async runtime** (Rust) — concurrent file transfers via non-blocking I/O
6. **ECDH key exchange** — forward-secrecy cryptography for secure distributed comms
7. **Offline-first design** — transfers complete without internet; coordination syncs later

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

- Bug reports → open an issue 🐞
- Feature requests → open a discussion 💬
- Code contributions → submit a pull request ⚙️

---

*Built by students, for everyone — because sharing should be simple, fast, and private.* 🦊

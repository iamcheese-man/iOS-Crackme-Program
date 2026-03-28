# iOS Crackme

A multi-stage reverse engineering challenge for iOS (ARM64).  
No jailbreak required — sideload via AltStore / TrollStore / LiveContainer.

---
## Direct (OTA) Installation without Sideloading Tools

Open this link on Safari:

- [Install iOS Crackme](http://iamcheese-man.github.io/HTML/IGNORE/IGNORE01.html)

After installing, go to Settings > General > VPN and Device Management > Trust the enterprise developer and you're ready to launch the app.

! Certificate Status: `REVOKED` !


! `This app is signed using an Enterprise certificate. Certificate can be revoked anytime by Apple.` !

---
## Objective

Enter the correct key into the text field.  
The app will confirm success or failure.

---

## Validation stages

The key goes through **5 sequential checks**. Bypass or RE each one:

| Stage | What it checks |
|-------|----------------|
| 1 | Key length |
| 2 | Structural pattern (prefix, dashes) |
| 3 | Checksum of chars at even indices |
| 4 | XOR blob comparison against stored bytes |
| 5 | Rolling FNV-1a hash of the full key |

All five must pass. A single failure returns `NO` immediately.

---

## Anti-debug

The app uses the following techniques — bypass them to use a debugger:

- `ptrace(PT_DENY_ATTACH)` called at launch (release builds only)
- `sysctl` + `P_TRACED` flag inspection at launch
- Background watchdog re-checking every 2.5 seconds

`DEBUG` builds skip all anti-debug so you can run in the simulator.

---

## Hints

<details>
<summary>Hint 1 — Structure</summary>
The key follows a pattern like `XX-XXXX-XXXX-XXXX`.
</details>

<details>
<summary>Hint 2 — XOR blob</summary>
Look at `kTargetBlob` in `KeyValidator.m`.  
Each byte is `char ^ (0xAB + position)`.  
Work backwards.
</details>

<details>
<summary>Hint 3 — Hash</summary>
The rolling hash is a modified FNV-1a with a position-based XOR mix.  
The expected output is in the source — but is it the same in the binary?
</details>

---

## Building

Requires Xcode 15+ on macOS, or use the provided GitHub Actions workflow.

```bash
xcodebuild \
  -project iOSCrackme.xcodeproj \
  -scheme iOSCrackme \
  -configuration Release \
  -sdk iphoneos \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

---

## Recommended tools

- `radare2` / Cutter — disassembly
- `frida` — dynamic instrumentation
- `class-dump` / `dsdump` — ObjC class recovery
- `lldb` — debugger (bypass anti-debug first)
- `jtool2` — Mach-O inspection

---

## License

MIT — do whatever you want, just don't spoil it publicly.

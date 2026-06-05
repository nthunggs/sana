# home-hub — Gom điều khiển nhà thông minh vào MỘT app (Apple Home)

Mục tiêu: không phải mở nhiều app (Rạng Đông, SmartLife, Home của Apple) nữa — gom tất cả
thiết bị về **app Home của Apple** làm trung tâm điều khiển duy nhất, thông qua **Homebridge**.

## Kiến trúc
```
App Home (Apple)  ──HomeKit──►  HomeKit hub (Apple TV / HomePod)
                                      │
                                Homebridge (Docker trên Mac, chạy 24/7)
                                      ├── plugin Tuya ──► SmartLife Cloud ──► thiết bị Tuya
                                      └── Rạng Đông (RalliSmart) ──► xem rangdong/INVESTIGATION-vi.md
```

## Trạng thái từng nền tảng
| Nền tảng | Cách vào Apple Home | Trạng thái |
|----------|---------------------|-----------|
| 🟢 Apple Home | Native | Có sẵn |
| 🟢 SmartLife (Tuya) | plugin `@0x5e/homebridge-tuya-platform` | **Giai đoạn 1** — làm ngay |
| 🟠 Rạng Đông (RalliSmart) | BLE Mesh + hub HC, không có HomeKit/API công khai | **Giai đoạn 2** — điều tra `rangdong/` |

## 👉 BẮT ĐẦU TỪ ĐÂY
- **Nếu bạn là Claude Code chạy trên máy Mac của người dùng:** đọc và thực hiện
  **[HANDOFF-mac-vi.md](./HANDOFF-mac-vi.md)** — đó là danh sách việc giao cho bạn (quét mạng, dựng Homebridge).
- **Người dùng:** đọc **[SETUP-vi.md](./SETUP-vi.md)** (Giai đoạn 1 — SmartLife/Tuya) cho phần bạn cần tự làm
  (đăng nhập Tuya, quét QR). Phần Rạng Đông xem **[rangdong/INVESTIGATION-vi.md](./rangdong/INVESTIGATION-vi.md)**.

## Yêu cầu
- Máy Mac (hoặc thiết bị khác) **luôn bật, không sleep** để chạy Homebridge 24/7.
- Đã cài **Docker Desktop** trên Mac.
- Có **Apple TV hoặc HomePod** làm HomeKit hub (để điều khiển từ xa).
- Đã có tài khoản **SmartLife** với ít nhất 1 thiết bị.

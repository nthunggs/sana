# Hướng dẫn cài đặt — Giai đoạn 1: SmartLife/Tuya → Apple Home

Mục tiêu giai đoạn này: đưa **toàn bộ thiết bị SmartLife (Tuya)** vào **app Home của Apple**,
điều khiển + Siri + tự động hoá, chỉ trong một app duy nhất.

Thời gian dự kiến: ~30–45 phút.

---

## 0. Chuẩn bị
- [ ] Máy Mac đã cài **Docker Desktop** và đang chạy.
- [ ] Mac đặt **không tự sleep** (System Settings → Lock Screen / Energy → "Prevent automatic sleeping").
- [ ] iPhone/iPad đăng nhập iCloud, đã bật **Home** (app Nhà).
- [ ] **Apple TV** hoặc **HomePod** đang hoạt động (làm HomeKit hub cho điều khiển từ xa).
- [ ] App **SmartLife** có ít nhất **1 thiết bị** đã thêm và hoạt động.

---

## 1. Tạo tài khoản & Cloud Project trên Tuya IoT (miễn phí)
1. Vào **https://iot.tuya.com** → đăng ký tài khoản (Sign Up), chọn quốc gia.
2. Sau khi đăng nhập: **Cloud → Development → Create Cloud Project**.
   - Industry: *Smart Home* · Development Method: *Smart Home* (Custom Development cũng được).
   - **Data Center:** chọn khu vực khớp tài khoản SmartLife của bạn. Ở Việt Nam thường là
     **Central Europe** (cũng thử **India** nếu không thấy thiết bị). Ghi nhớ lựa chọn này — nó quyết định `endpoint` ở bước 4.
3. Project tạo xong sẽ hiện **Access ID / Client ID** và **Access Secret / Client Secret** → giữ lại.

## 2. Bật API quyền cần thiết
Trong project → tab **Service API** → **Authorize / Add**, đảm bảo có:
- *IoT Core*
- *Authorization*
- *Smart Home Scene Linkage*

(Nếu thiếu, thiết bị sẽ không hiện ở bước sau.)

## 3. Liên kết tài khoản SmartLife vào project
1. Trong project → tab **Devices → Link App Account → Add App Account**.
2. Màn hình hiện **mã QR**. Mở app **SmartLife** trên điện thoại →
   biểu tượng **Me (Tôi) → góc trên phải (icon quét QR)** → quét mã QR đó.
3. Quay lại trang web, kiểm tra tab **Devices → All Devices** → phải thấy danh sách thiết bị SmartLife của bạn.
   - Nếu danh sách trống: thường do **chọn sai Data Center** ở bước 1 → tạo project mới với DC khác (Central Europe ↔ India) rồi link lại.

## 4. Điền cấu hình Homebridge
Mở file `home-hub/homebridge/config.json`, sửa khối `platforms[0].options`:
- `accessId` ← Access ID (bước 1).
- `accessKey` ← Access Secret (bước 1).
- `countryCode` ← `84` (Việt Nam).
- `username` / `password` ← tài khoản & mật khẩu đăng nhập app **SmartLife**.
- `endpoint` ← theo Data Center đã chọn:
  - Central Europe → `https://openapi.tuyaeu.com`
  - India → `https://openapi.tuyain.com`
  - US → `https://openapi.tuyaus.com`
  - China → `https://openapi.tuyacn.com`

Xoá khối `"_huong_dan"` và `"description"` sau khi điền xong (không bắt buộc, chỉ cho gọn).

> Đổi `bridge.pin` (mã ghép nối, mặc định `031-45-154`) và `bridge.username` (địa chỉ MAC ảo)
> nếu muốn — nhưng để mặc định vẫn chạy được.

## 5. Khởi động Homebridge
Tại thư mục `home-hub`:
```bash
docker compose up -d
docker compose logs -f homebridge   # xem log, Ctrl+C để thoát
```
Mở trình duyệt: **http://localhost:8581** (hoặc `http://<IP-máy-Mac>:8581`).
- Đăng nhập (lần đầu tự tạo tài khoản admin của Homebridge UI).
- Cài plugin Tuya: vào tab **Plugins → Search** gõ `homebridge-tuya-platform` →
  cài **`@0x5e/homebridge-tuya-platform`** (bản cộng đồng, được bảo trì tốt).
  - *Phương án dự phòng:* plugin chính thức **`homebridge-tuya`** (`tuya/tuya-homebridge`) của Tuya.
- Vào tab **Status**, kiểm tra log thấy plugin nạp thiết bị Tuya thành công. Restart Homebridge nếu cần.

## 6. Ghép Homebridge vào app Home
1. Trên trang Homebridge UI tab **Status** có **mã QR HomeKit** + mã PIN.
2. iPhone → app **Home (Nhà) → +** (góc trên) → **Add Accessory** → quét mã QR đó.
   - Nếu báo "phụ kiện chưa được chứng nhận" → chọn **Add Anyway**.
3. Làm theo hướng dẫn gán phòng/tên. Sau đó **toàn bộ thiết bị SmartLife** xuất hiện trong app Home.

## 7. Kiểm thử
- [ ] Bật/tắt + chỉnh độ sáng 1 đèn SmartLife ngay trong **app Home**.
- [ ] Nói **"Hey Siri, tắt <tên đèn>"**.
- [ ] Tắt Wi-Fi iPhone (dùng 4G) → điều khiển vẫn được (qua Apple TV/HomePod hub).

✅ Xong Giai đoạn 1: SmartLife đã nằm trong app Home.

---

## Xử lý sự cố nhanh
- **app Home không tìm thấy cầu nối khi quét QR:** HomeKit cần mDNS/Bonjour qua `network_mode: host`.
  Trên **Docker Desktop cho Mac**, host networking đôi khi không phát mDNS ra LAN. Hai cách khắc phục:
  1. **Khuyến nghị:** cài Homebridge trực tiếp bằng installer macOS
     (xem https://github.com/homebridge/homebridge/wiki/Install-Homebridge-on-macOS) thay vì Docker — ổn định nhất trên Mac.
  2. Hoặc chuyển Homebridge sang chạy trên **Raspberry Pi / máy Linux** (host networking hoạt động chuẩn).
- **Thiết bị Tuya không hiện:** sai Data Center → đổi `endpoint` + tạo lại project ở DC khác.
- **Một số thiết bị hiện nhưng không điều khiển được:** loại thiết bị đó chưa được plugin hỗ trợ đầy đủ —
  ghi lại `category`/`product_id` (xem trong log) để xử lý riêng.

## Tiếp theo
→ Sang **[rangdong/INVESTIGATION-vi.md](./rangdong/INVESTIGATION-vi.md)** để xử lý thiết bị Rạng Đông.

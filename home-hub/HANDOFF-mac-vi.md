# Giao việc cho Claude Code chạy trên Mac (trong mạng nhà)

> File này dành cho **Claude Code chạy trên máy Mac của người dùng** — máy NẰM TRONG mạng LAN nhà,
> nên làm được các việc mà session cloud không làm được (quét mạng, Docker, ghép thiết bị).
> Trao đổi kết quả với session cloud **qua repo GitHub** (commit & push).

Branch làm việc: `claude/github-project-review-15zBY`. Trước khi bắt đầu: `git pull`.

---

## NHIỆM VỤ A — Quét mạng tìm hub Rạng Đông (làm trước)
1. Chạy script quét (read-only):
   ```bash
   cd home-hub/rangdong
   bash scan-lan.sh | tee scan-result.txt
   ```
2. Nếu nghi được IP hub HC, quét cổng để tìm local API:
   ```bash
   command -v nmap >/dev/null || brew install nmap
   sudo nmap -sV -p- <IP_HUB> | tee -a scan-result.txt
   ```
3. (Tùy chọn, hữu ích) Kiểm tra có local control không: bật chế độ **Smart Local** trong app
   RalliSmart, tắt Internet, thử bật/tắt 1 đèn → ghi lại kết quả vào cuối `scan-result.txt`.
4. Commit & push để session cloud phân tích:
   ```bash
   git add home-hub/rangdong/scan-result.txt
   git commit -m "Add Rang Dong LAN scan result"
   git push
   ```
   ⚠️ `scan-result.txt` chỉ chứa IP/MAC nội bộ — KHÔNG nhạy cảm, push thoải mái.

## NHIỆM VỤ B — Dựng Homebridge (Giai đoạn 1, SmartLife/Tuya)
Làm theo `home-hub/SETUP-vi.md`. Phần Claude Code Mac làm được:
- `docker compose up -d` trong `home-hub/`, kiểm tra log, mở UI cổng 8581.
- Cài plugin `@0x5e/homebridge-tuya-platform`.
- Sau khi người dùng tự liên kết tài khoản trên `iot.tuya.com` và điền credential vào
  `homebridge/config.json`, kiểm tra danh sách thiết bị Tuya nạp lên.
- Báo lại **danh sách thiết bị** (tên, category, product_id) — ghi vào
  `home-hub/rangdong/devices-found.txt` rồi push, để session cloud rà soát thiết bị nào chưa hỗ trợ.

> Bước người dùng PHẢI tự làm (Claude không thay được): đăng nhập web `iot.tuya.com`,
> quét QR liên kết app SmartLife, lấy Access ID/Secret.

## QUY TẮC AN TOÀN
- KHÔNG commit `homebridge/config.json` sau khi đã điền tài khoản/mật khẩu SmartLife + Access Secret.
  Nếu cần lưu, dùng `homebridge/config.local.json` (đã nằm trong `.gitignore`).
- KHÔNG commit thư mục `homebridge/persist/`, `auth.json` (đã ignore).

## SAU KHI XONG
Push kết quả lên branch rồi báo người dùng. Session cloud sẽ `git pull`, phân tích `scan-result.txt`
/ `devices-found.txt` và quyết hướng tích hợp Rạng Đông + viết plugin nếu cần.

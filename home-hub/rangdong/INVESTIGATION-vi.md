# Giai đoạn 2 — Đưa Rạng Đông (RalliSmart) vào Apple Home

## Tình hình (đã tìm hiểu)
Rạng Đông RalliSmart **không giống** SmartLife/Tuya:
- Đa số thiết bị kết nối bằng **Bluetooth Mesh**, qua **hub trung tâm HC** (một số thiết bị nối Wi-Fi trực tiếp).
- Có **Rạng Đông Cloud** riêng + chế độ **"Smart Local"** (điều khiển trong mạng LAN, không cần Internet).
- Tích hợp sẵn **Google Assistant / Alexa**, **NHƯNG KHÔNG có HomeKit**.
- **Không có** plugin Homebridge và **không có** API công khai/tài liệu chính thức.

→ Không có đường "cắm là chạy". Phải điều tra rồi chọn 1 trong 4 hướng dưới.

---

## Bước điều tra (làm trước khi quyết)
Mục tiêu: xác định hub HC có **API local (HTTP/MQTT)** trong mạng LAN hay không.

### A. Tìm IP của hub HC trong mạng
Trên máy Mac (cùng Wi-Fi với hub), chạy:
```bash
# Quét nhanh các thiết bị trong LAN (đổi dải IP cho đúng mạng của bạn, ví dụ 192.168.1.0/24)
brew install nmap   # nếu chưa có
sudo nmap -sn 192.168.1.0/24            # liệt kê thiết bị đang online
# Tìm dòng có nhà sản xuất lạ / tên Rang Dong / ESP / Espressif (chip hay dùng)
```
Ghi lại IP nghi là hub HC (ví dụ `192.168.1.50`).

### B. Dò cổng & dịch vụ mở trên hub
```bash
sudo nmap -sS -sV -p- 192.168.1.50      # quét toàn bộ cổng + nhận diện dịch vụ
```
Chú ý các cổng thường gặp của smart-home: `80/443` (HTTP/REST), `1883/8883` (MQTT), `6668` (Tuya-like), `5683` (CoAP).

### C. Xem app RalliSmart gọi gì (xác định có local API không)
1. Bật chế độ **Smart Local** trong app RalliSmart.
2. Tắt Internet (để app buộc phải nói chuyện local với hub), thử bật/tắt 1 đèn — nếu vẫn được → **chắc chắn có local control**.
3. (Nâng cao) Bắt gói tin để biết giao thức:
   - Dùng **Wireshark** lọc theo IP hub, hoặc một **mitm proxy** (Charles/mitmproxy) trên điện thoại
     để xem app gọi HTTP/MQTT gì tới hub hay tới `*.rangdong.com.vn`.

### D. Ghi kết quả vào bảng dưới rồi chọn hướng
| Câu hỏi | Kết quả |
|---------|---------|
| Hub HC có IP cố định trong LAN? | … |
| Có cổng HTTP/MQTT mở? | … |
| Điều khiển được khi tắt Internet (local)? | … |
| Giao thức quan sát được (REST/MQTT/BLE) | … |

---

## 4 hướng giải quyết (chọn theo kết quả điều tra)

### Hướng 1 — Viết Homebridge plugin custom cho hub HC  ⭐ (nếu có local API)
- Điều kiện: bước C/D cho thấy hub có **REST hoặc MQTT local** điều khiển được.
- Việc: viết một Homebridge plugin nhỏ trong `home-hub/rangdong-plugin/` map mỗi đèn/thiết bị
  thành accessory HomeKit, gọi xuống API local của hub.
- Ưu: sạch nhất, mọi thứ vẫn nằm trong app Home. Nhược: cần dò giao thức (mình sẽ làm cùng anh khi có dữ liệu bước C).

### Hướng 2 — Home Assistant làm lớp cầu phụ
- Cài **Home Assistant** (thêm service vào `docker-compose.yml`, chạy cùng máy).
- Nếu cộng đồng VN có **custom component cho Rạng Đông** (cần kiểm tra HACS/GitHub tại thời điểm làm) → đưa thiết bị vào HA.
- Bật **HA → HomeKit Bridge** để đẩy ngược các thiết bị đó vào **app Home**.
- Ưu: tận dụng hệ sinh thái HA mạnh. Nhược: thêm 1 thành phần để vận hành.

### Hướng 3 — Relay qua Google/Alexa  (KHÔNG khuyến nghị)
- RalliSmart có Google/Alexa, nhưng đẩy ngược về HomeKit rất chắp vá, trễ và dễ hỏng. Chỉ dùng khi bất khả kháng.

### Hướng 4 — Thay dần thiết bị quan trọng bằng loại HomeKit/Matter-native  ✅ (chắc chắn chạy)
- Với các đèn/ổ/công tắc **quan trọng nhất**, thay bằng thiết bị **Matter** hoặc **"Works with Apple Home"**
  (hoặc thiết bị Tuya — đã hỗ trợ ở Giai đoạn 1). Giữ RalliSmart cho phần phụ.
- Ưu: đơn giản, ổn định tuyệt đối. Nhược: tốn chi phí phần cứng.

---

## Khuyến nghị
1. Làm xong **Giai đoạn 1** trước (SmartLife đã gom được — giải quyết phần lớn nhu cầu).
2. Chạy **bước điều tra A–D** cho hub Rạng Đông, gửi kết quả.
3. Dựa kết quả: nếu có local API → **Hướng 1** (mình viết plugin cùng anh). Nếu không → cân nhắc **Hướng 2** hoặc **Hướng 4**.

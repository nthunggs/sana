#!/usr/bin/env bash
# Quét mạng LAN nhà bạn để tìm hub Rạng Đông / thiết bị smart-home.
# CHẠY TRÊN MÁY MAC CỦA BẠN (cùng Wi-Fi với các thiết bị), KHÔNG chạy trên cloud.
#
# Cách dùng:
#   bash scan-lan.sh
# Rồi copy toàn bộ output dán lại cho Claude.
#
# Script chỉ ĐỌC thông tin mạng (read-only), không thay đổi gì.

set -u
echo "=================== THÔNG TIN MẠNG MÁY MAC ==================="
echo "## IP + subnet của Mac:"
ipconfig getifaddr en0 2>/dev/null && echo "  (Wi-Fi en0)"
ipconfig getifaddr en1 2>/dev/null && echo "  (en1)"
route -n get default 2>/dev/null | grep -E 'gateway|interface'
echo

# Suy ra dải mạng /24 từ IP Wi-Fi
IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
SUBNET=$(echo "$IP" | sed 's/\.[0-9]*$//')
echo "## Dải mạng phát hiện: ${SUBNET}.0/24 (gateway thường là ${SUBNET}.1)"
echo

echo "=================== PING SWEEP (làm nóng bảng ARP) ==================="
for i in $(seq 1 254); do ping -c1 -W1 "${SUBNET}.$i" >/dev/null 2>&1 & done; wait
echo "Đã ping toàn dải, đọc bảng ARP..."
echo

echo "=================== THIẾT BỊ ĐANG ONLINE TRONG LAN ==================="
echo "IP                MAC                 (nhà sản xuất - đoán từ MAC)"
arp -a -n 2>/dev/null | awk '{print $2, $4}' | tr -d '()' | sort -t. -k4 -n
echo
echo ">> Gợi ý: hub Rạng Đông / thiết bị IoT thường dùng chip Espressif (ESP) hoặc"
echo "   nhà sản xuất lạ. Dán kết quả này cho Claude để khoanh vùng hub HC."
echo

echo "=================== (TÙY CHỌN) QUÉT CỔNG bằng nmap ==================="
if command -v nmap >/dev/null 2>&1; then
  echo "nmap có sẵn. Nếu đã biết IP hub, chạy:  sudo nmap -sV -p- <IP_hub>"
else
  echo "Chưa cài nmap. Cài bằng:  brew install nmap   (không bắt buộc ở bước này)"
fi
echo "=================== XONG ==================="

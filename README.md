# Bài 1: Thay đổi cổng kết nối SSH (SSH Port Hardening)

## 🎯 1. Mục Tiêu
- Thay đổi cổng dịch vụ SSH mặc định từ **22** sang **2222** trên máy chủ ảo nhằm hạn chế tối đa các cuộc quét cổng tự động của botnet trên mạng Internet.
- Thực hiện cấu hình tường lửa UFW trước khi khởi động lại dịch vụ SSH để tránh nguy cơ bị khóa quyền truy cập (Lockout).

---

## 📋 2. Yêu Cầu Chi Tiết (Requirements)
- **Bối cảnh**: Cổng 22 mặc định liên tục bị botnet quét và dò mật khẩu brute-force. Cần đổi cổng kết nối SSH sang **2222** để nâng cao an toàn bảo mật.
- **Ràng buộc**:
  1. Thay đổi chỉ thị kết nối sang `Port 2222` trong file cấu hình hệ thống `/etc/ssh/sshd_config` (hoặc `/etc/ssh/sshd_config.d/`).
  2. Sử dụng tường lửa UFW để mở cổng `2222/tcp` trước khi khởi động lại dịch vụ SSH daemon.
  3. Bắt buộc thao tác bằng tài khoản người dùng thường `devops` có quyền `sudo` (không dùng `root` trực tiếp).
  4. Khởi động lại dịch vụ SSH daemon (`sudo systemctl restart ssh`).

---

## 🛠️ 3. Hướng Dẫn Các Bước Thực Hiện (Step-by-Step Guide)

### Bước 1: Đăng nhập vào Máy chủ bằng User `devops`
```bash
ssh devops@<IP_ADDRESS_DROPLET>
```

### Bước 2: Mở Cổng 2222/tcp trên Tường Lửa UFW
*(Lưu ý: Luôn mở cổng 2222 trước khi khởi động lại dịch vụ SSH để không bị khóa kết nối).*
```bash
sudo ufw allow 2222/tcp comment 'Custom SSH Port'
sudo ufw status verbose
```

### Bước 3: Thay Đổi Cổng SSH trong Cấu Hình System
Mở file cấu hình SSH Daemon:
```bash
sudo nano /etc/ssh/sshd_config
```
Tìm dòng `#Port 22` hoặc `Port 22`, bỏ dấu `#` và sửa lại thành:
```text
Port 2222
```
*(Nếu hệ thống Ubuntu 22.04+ có thư mục `/etc/ssh/sshd_config.d/`, bạn có thể tạo file mới `/etc/ssh/sshd_config.d/port.conf` chứa dòng `Port 2222`).*

### Bước 4: Kiểm Tra Cú Pháp & Khởi Động Lại Dịch Vụ SSH
```bash
# Kiểm tra cú pháp file cấu hình sshd
sudo sshd -t

# Khởi động lại dịch vụ SSH daemon
sudo systemctl restart ssh
```

---

## ✅ 4. Lệnh Kiểm Tra & Kết Quả Mong Đợi (Verification)

> ⚠️ **LƯU Ý QUAN TRỌNG**: Giữ nguyên cửa sổ Terminal hiện tại. Mở một cửa sổ Terminal **MỚI** trên máy tính cá nhân để thử nghiệm kết nối.

### 1. Kiểm tra kết nối qua Cổng mới 2222:
```bash
ssh -p 2222 devops@<IP_ADDRESS_DROPLET>
```
**Kết quả mong đợi**: Kết nối thành công vào giao diện dòng lệnh của máy chủ qua SSH Key bằng user `devops`.

### 2. Kiểm tra kết nối qua Cổng cũ 22:
```bash
ssh -p 2 devops@<IP_ADDRESS_DROPLET>
```
**Kết quả mong đợi**: Kết nối thất bại (báo lỗi `ssh: connect to host <IP> port 22: Connection refused` hoặc `Operation timed out`).

---

## 💡 5. Script Tự Động Hóa (Automation Script)
File `change_ssh_port.sh` được cung cấp trong thư mục này giúp tự động hóa quá trình đổi port an toàn.

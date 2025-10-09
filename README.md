<p align="center">
<img src="https://img.bibica.net/LdQl82XW.png" alt="Fk9HGGgb">
</p>

# Cốc Cốc Portable Debloat 

Cốc Cốc Portable Debloat là phiên bản trình duyệt Cốc Cốc chạy trên Windows, đã được chuyển hoàn toàn sang di động, có thể chép dữ liệu sang thiết bị khác mà không mất dữ liệu, không cần cấu hình lại các plugin, history … kèm theo đó là debloat, tắt bớt các quảng cáo, giúp giao diện Cốc Cốc sạch như Chromium nguyên bản

### Các bước tối ưu bao gồm:
- Xóa tiện ích mặc định (`Từ Điển`, `Rủng Rỉnh`)
- Tắt `Side Panel`, `Split View`
- Thay thế tab mới (`New Tab`) bằng trang sạch không quảng cáo
- Tắt các tiến trình chạy ngầm và cập nhật tự động
- Tắt 1 phần thông tin người dùng gửi tới Google hay Cốc Cốc
- Thiết lập quyền riêng tư ở mức nghiêm ngặt, tắt cookie của bên thứ ba, tắt thông báo, tắt định vị, tắt cảm biến chuyển động
- Sử dụng `Cloudflare Gateway DNS` hỗ trợ `ECS` (chặn quảng cáo bởi bộ lọc `AdGuard` và `ABPVN`) từ `v14x`
- Bật tính năng tiết kiệm RAM (`Balanced memory savings`)
- Chặn hoàn toàn domain `coccoc.com`, `qccoccocmedia.vn`

### Khuyết điểm?
- Các video, auto chạy qua DRM sẽ gặp lỗi, tạm chưa có hướng xử lý, vì đã bypass Secure Preferences

### [Download Cốc Cốc Portable Debloat](https://coccoc.bibica.net/)

<p align="center">
<img src="https://img.bibica.net/AEPCJ6rI.png" alt="AEPCJ6rI">
</p>

Tùy thuộc bạn thích dùng bản mới nhất, hay các bản cũ hơn mà chọn phiên bản phù hợp (trang download sẽ hiện thị 5 nhánh gần nhất)

### Debloat

- Bật chạy `CocCoc_Portable\CocCoc\debloat.reg`
- Kiểm tra các tùy chỉnh `coccoc://policy/`

---

### Đặt làm trình duyệt mặc định

- Bật chạy `CocCoc_Portable\CocCoc\default-apps-multi-profile.bat`

---

### Cập nhập bản mới

- Chạy file `CocCoc_Portable\CocCoc\update.bat`
- Chỉ chép bản mới nhất vào (không ghi đè các file `chrome++.ini`, `debloat.reg`, `default-apps-multi-profile.bat` có sẵn, tránh làm mất cấu hình nếu bạn chỉnh sửa lại)
- Đôi lúc vài phiên bản, có chỉnh sửa lại các file  `chrome++.ini`, `debloat.reg`, `default-apps-multi-profile.bat`, cần xóa thủ công 3 file này trước khi cập nhập để lấy bản mới nhất

---

### Tên gọi phiên bản portable
<p align="center">
<img src="https://img.bibica.net/Koy2oGJn.png" alt="Koy2oGJn">
</p>

Không tìm thấy cách Cốc Cốc đặt tên phiên bản ở chỗ nào, nên dùng tên theo Chromium version (nó sẽ không chính xác so với con số thể hiện ra ở `coccoc://version/`)

### Fork dự án

Bạn nào muốn cài đặt, mà hơi rén, không rõ tác giả có chỉnh sửa, cài đặt gì thêm vào không, có thể [fork](https://github.com/bibicadotnet/coccoc-portable/fork) dự án, bật chạy `Actions`, nó sẽ tự chạy mọi quá trình, thời gian build tầm 2-10 phút là xong, tự download release từ trang cá nhân về dùng cho an tâm

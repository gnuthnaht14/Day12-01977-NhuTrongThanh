# Phiếu Phản Ánh — K3 Ngày 12

> **Bài làm cá nhân.** Trả lời bằng lời của chính bạn, dựa trên những gì bạn
> quan sát được khi chạy code — không sao chép đáp án của người khác.
>
> Cách trả lời: thay dòng `> *Câu ttrả lời của bạn*` bằng câu trả lời.
> `grade.py` đếm số câu đã trả lời (15 điểm cho 10 câu).
>
> Họ và tên: Nhữ Trọng Thành  Mã học viên: 2A202601977

---

### Câu 1 — Fail fast (CP1)

Trong `Settings`, `agent_api_key` không có giá trị mặc định nên app chết ngay
khi khởi động nếu thiếu biến môi trường. Hãy mô tả một tình huống cụ thể mà
việc "chết sớm" này cứu bạn, so với việc để mặc định `"changeme"`.

> Nếu deploy lên railway mà quên đặt agent api key thì app sẽ dừng ngay khi khởi động và báo lỗi thiéu cấu hình. Nhờ vậy service chưa nhận traffic khi service chưa sẵn sàng bảo mật.

---

### Câu 2 — Log cho máy đọc (CP1)

Chạy service và gọi `/ask` vài lần. Dán một dòng log JSON bạn thu được, rồi
nêu **hai** việc bạn làm được với dòng log đó mà `print("đã trả lời xong")`
không làm được.

> {"event":"ask_completed","level":"info","timestamp":"2026-08-10T05:10:00+00:00","user_id":"sv-cp5","tokens_in":2,"tokens_out":34,"cost_usd":2.07e-05}
Dòng log này có thể lọc tất cả request của một user và tính tổng chi phí và phố token đã dùng. Cũng có thể dùng để thống kê số lỗi, số request và loại event -> tạo cảnh cáo

---

### Câu 3 — Kích thước image (CP2)

Build cả hai phiên bản và ghi lại số đo thật:

```bash
docker build -f <Dockerfile-1-stage> -t agent:single .
docker build -t agent:multi .
docker images | grep agent
```

| Bản | Dung lượng |
|-----|-----------|
| 1 stage (bản đầu) | 400 MB |
| Multi-stage | 183 MB |

Giải thích: phần dung lượng chênh lệch đó là những gì?

> multi-stage chỉ chứa các python. package cần thiết và source. Các file cache, pip cach, dependancy build bị loại bỏ nên nhỏ hơn rất nhiều.

---

### Câu 4 — Thứ tự lệnh trong Dockerfile (CP2)

Sửa một ký tự trong `app/main.py` rồi build lại. Với Dockerfile của bạn, những
layer nào được dùng lại từ cache, layer nào phải chạy lại? Nếu bạn đặt
`COPY . .` lên trước `RUN pip install` thì kết quả khác thế nào?

> Dockerfile hiện copy requirements.txt và chạy pip íntall trước khi copy app/ và untils.. Khi sửa app/main.py, layer cài dependency vẫn được lấy lại từ cache, chỉ các layer copy source đằng sau phải chạy lại.
Nếu đặt COPY .. trước RUN pip install mọi thay đổi trong source sẽ làm layer COPY thay đổi và khiến docker chạy lại pip install dù dependency không đổi -> chậm

---

### Câu 5 — Vì sao không chạy bằng root (CP2)

Container mặc định chạy bằng root. Mô tả chuỗi sự kiện dẫn từ "một lỗ hổng
trong code Python của bạn" tới "kẻ tấn công có quyền cao trên máy host", và
lệnh `USER` cắt đứt chuỗi đó ở chỗ nào.

> Chạy bẳng root cho phép kẻ tấn công có thể có quyền root khi tấn công được vào container. Nếu tiếp tục khai thác lỗ hổng runtime thì có thể tìm cách leo thang truy cập hoặc nhiều thứ khác.
Lệnh USER khiến tiến trình chỉ chạy với quyền user. Nên khi bị tấn công thì kẻ tấn công sẽ khó mà loe thang đặc quyền hơn.

---

### Câu 6 — Cửa sổ trượt (CP3)

Rate limit của bạn dùng sliding window 60 giây. Nếu thay bằng cách đếm theo
phút đồng hồ (reset lúc giây 00), một người dùng có thể gửi tối đa bao nhiêu
request trong 2 giây liên tiếp khi hạn mức là 10/phút? Giải thích cách đạt được
con số đó.

> Một người có thể gửi tối đa 20, 10 cái ngay giây 59 và 10 cái giây 00. Sliding windows sẽ tránh được vì nó đếm 60s gần nhất.

---

### Câu 7 — Rate limit và cost guard (CP3)

Hai cơ chế này khác nhau ở điểm nào? Cho một tình huống mà rate limit cho qua
nhưng cost guard phải chặn, và một tình huống ngược lại.

> rate limit giới hạn số lượng request trong một khoảng thời gian. Cost thì giới hạn chi phí LLM mà mỗi user dùng. Vdu rate limti vẫn cho phép nhưng user đã hết tiền -> chặn. Ngược alij user có thể còn ngân sáhc nhưng sẽ bị rate limit chặn nếu spam request

---

### Câu 8 — /health khác /ready (CP4)

Nếu gộp hai endpoint làm một và cho nó kiểm tra Redis, chuyện gì xảy ra với cụm
3 container khi Redis mất kết nối 30 giây? Trả lời theo đúng thứ tự sự kiện.

> nếu gộp 2 endpoint thì khi redis mất kết nối -> 3 containter đều ktra redis thất bại -> cả 3 containter đều trả unhealthy -> orchestrator sẽ restart cả 3 containter -> load balancer mất toàn bộ backend đang phục vụ -> dù redis khôi phục sau đó -> cả cụm đều đang bị restart, không thể phục vụ user.

---

### Câu 9 — Stateless (CP4)

Chạy `docker compose up --scale agent=3` rồi gọi `/ask` nhiều lần với cùng một
`X-User-Id`. Quan sát `history_length` trong response. Nếu lịch sử được lưu
trong một dict Python thay vì Redis, bạn sẽ thấy con số đó thay đổi thế nào?

> redis dùng chung, lịch sử không phụ thuộc request rơi vào container nào. history_length sẽ tăng theo số 0, 2, 4, 6, 8. Mỗi request thêm một message user và một message assitant. Nếu dùng dict thì con số đó sẽ không tăng dần(vì 3 container khác nhau)

---

### Câu 10 — Deploy thật (CP5)

Ghi lại **một** lỗi bạn gặp khi deploy lên cloud (build fail, health check
timeout, sai REDIS_URL, app không đọc `$PORT`...): thông báo lỗi là gì, bạn
tìm ra nguyên nhân bằng cách nào, và sửa ra sao?

> Khi deploy Railway lần đầu, health check thất bại với lỗi:
Error: Invalid value for '--port': '$PORT' is not a valid integer.

Tôi xem deployment logs và thấy Railway truyền chuỗi $PORT nguyên dạng cho Uvicorn, không shell-expand biến môi trường như khi chạy qua sh -c. Nguyên nhân nằm ở railway.toml dùng:
startCommand = "uvicorn app.main:app --host 0.0.0.0 --port $PORT"

Sửa thành startCommand = "python -m app.main"

Và deploy thành công
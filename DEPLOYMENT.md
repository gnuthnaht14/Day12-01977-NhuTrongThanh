# Thông Tin Deploy — Checkpoint 5

> Điền file này sau khi deploy xong. `pytest tests/test_cp5.py` đọc file này
> để tìm địa chỉ service của bạn và gọi thử.
>
> **Chỉ ghi TÊN biến môi trường, tuyệt đối không dán giá trị API key vào đây.**
> Repo này công khai — dán khóa vào là mất khóa.

## Thông Tin Học Viên

| Mục | Nội dung |
|-----|----------|
| Họ và tên | Nhữ Trọng Thành |
| Mã học viên | 2A202601977 |
| Repo | https://github.com/gnuthnaht14/Day12-01977-NhuTrongThanh |

## Service

| Mục | Nội dung |
|-----|----------|
| Public URL | https://agent-production-59a6.up.railway.app |
| Platform | Railway |
| Ngày deploy | 2026-08-10 |

## Biến Môi Trường Đã Set Trên Cloud

Ghi tên biến và **nguồn giá trị**, không ghi giá trị:

| Biến | Đã set | Ghi chú |
|------|--------|---------|
| `PORT` | ✅ | platform tự gán |
| `AGENT_API_KEY` | ✅ | đặt trong dashboard, không nằm trong repo |
| `REDIS_URL` | ✅ | Railway Redis add-on, dùng reference variable |
| `RATE_LIMIT_PER_MINUTE` | ✅ | 10 |
| `MONTHLY_BUDGET_USD` | ✅ | 10.0 |
| `LOG_LEVEL` | ✅ | INFO |

## Lệnh Kiểm Tra

Các lệnh dưới đây dùng Public URL đã deploy:

```bash
# 1. Liveness — mong đợi 200 {"status":"ok"}
curl -i https://agent-production-59a6.up.railway.app/health

# 2. Readiness — mong đợi 200 {"status":"ready"} (đã nối được Redis)
curl -i https://agent-production-59a6.up.railway.app/ready

# 3. Không có API key — mong đợi 401
curl -i -X POST https://agent-production-59a6.up.railway.app/ask \
  -H "Content-Type: application/json" \
  -d '{"question":"Hello"}'

# 4. Có API key — mong đợi 200 kèm câu trả lời
curl -i -X POST https://agent-production-59a6.up.railway.app/ask \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $AGENT_API_KEY" \
  -H "X-User-Id: sv-test" \
  -d '{"question":"Deploy là gì?"}'

# 5. Rate limit — gọi 15 lần, những lần cuối phải trả 429
for i in $(seq 1 15); do
  curl -s -o /dev/null -w "%{http_code} " -X POST https://agent-production-59a6.up.railway.app/ask \
    -H "Content-Type: application/json" \
    -H "X-API-Key: $AGENT_API_KEY" \
    -H "X-User-Id: sv-test" \
    -d '{"question":"test"}'
done; echo
```

## Kết Quả Chạy Thật

Dán output của các lệnh trên vào đây:

```
PS D:\workSpace\VinAI\K3-Day12-Cloud-Services-And-Deployment-01977-NhuTrongThanh> bash ./run_test_after_deploy.sh
1. Liveness (expected 200)
HTTP/2 200 
content-type: application/json
date: Mon, 10 Aug 2026 07:06:50 GMT
server: railway-hikari
x-railway-request-id: 0_txniOBRzSe2ZImw9P4nw
content-length: 57
x-hikari-trace: sin1.98a6
x-railway-edge: sin1

{"status":"ok","service":"day12-agent","version":"1.0.0"}2. Readiness (expected 200)
HTTP/2 200 
content-type: application/json
date: Mon, 10 Aug 2026 07:06:51 GMT
server: railway-hikari
x-railway-request-id: kGRfatvDRvyP0uHSALIuDA
content-length: 31
x-hikari-trace: sin1.d1nj
x-railway-edge: sin1

{"status":"ready","redis":true}3. Missing API key (expected 401)
HTTP/2 401 
content-type: application/json
date: Mon, 10 Aug 2026 07:06:52 GMT
server: railway-hikari
x-railway-request-id: 8sscxyqNS8CM_i1Hw9P4nw
content-length: 39
x-hikari-trace: sin1.98a6
x-railway-edge: sin1

{"detail":"invalid or missing API key"}4. Valid API key (expected 200)
HTTP/2 200 
content-type: application/json
date: Mon, 10 Aug 2026 07:06:53 GMT
server: railway-hikari
x-railway-request-id: cty9bHxbRQOnS7mlYqdHTg
content-length: 340
x-hikari-trace: sin1.98a6
x-railway-edge: sin1
vary: accept-encoding

{"answer":"Câu hỏi hay. Deploy là gì thường được giải quyết bằng cách chuẩn hóa môi trường chạy: cùng một image chạy giống nhau ở laptop và trên cloud. (Mình đang nhớ 20 lượt trao đổi trước đó.)","user_id":"sv-test","history_length":20,"cost_usd":9.345e-05,"tokens":{"in":443,"out":45}}5. Rate limit (last requests expected 429)
200 200 200 200 200 200 200 200 429 429 429 429 429 429
```

## Ảnh Chụp Màn Hình

Đặt ảnh trong thư mục `screenshots/`:

- `screenshots/dashboard.png` — trang quản lý service trên platform
- `screenshots/health.png` — kết quả gọi `/health` từ trình duyệt hoặc curl

---

## Phương Án Dự Phòng

Không sử dụng. Service đã được deploy trực tiếp lên Railway.

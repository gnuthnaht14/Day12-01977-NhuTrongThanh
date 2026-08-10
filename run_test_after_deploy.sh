# 1. Liveness — mong đợi 200 {"status":"ok"}
curl.exe -i https://agent-production-59a6.up.railway.app/health

# 2. Readiness — mong đợi 200 {"status":"ready"} (đã nối được Redis)
curl.exe -i https://agent-production-59a6.up.railway.app/ready

# 3. Không có API key — mong đợi 401
curl.exe -i -X POST https://agent-production-59a6.up.railway.app/ask \
  -H "Content-Type: application/json" \
  -d '{"question":"Hello"}'

# 4. Có API key — mong đợi 200 kèm câu trả lời
curl.exe -i -X POST https://agent-production-59a6.up.railway.app/ask \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $AGENT_API_KEY" \
  -H "X-User-Id: sv-test" \
  -d '{"question":"Deploy là gì?"}'

# 5. Rate limit — gọi 15 lần, những lần cuối phải trả 429
for i in $(seq 1 15); do
  curl.exe -s -o /dev/null -w "%{http_code} " -X POST https://agent-production-59a6.up.railway.app/ask \
    -H "Content-Type: application/json" \
    -H "X-API-Key: $AGENT_API_KEY" \
    -H "X-User-Id: sv-test" \
    -d '{"question":"test"}'
done; echo
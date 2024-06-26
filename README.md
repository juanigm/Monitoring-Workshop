# template
Monitoring-Workshop

### My App
Add new devices
curl -d '{"id": 3, "mac": "96-40-D1-32-D7-1A", "firmware": "3.03.00"}' localhost:8080/devices

Upgrade devices
curl -X PUT -d '{"firmware": "2.3.0"}' localhost:8080/devices/1
hey -n 100000 -c 1 -q 2 -m PUT -d '{"firmware": "2.03.00"}' http://localhost:8080/devices/1

Generate Load (Latency Histogram)
hey -n 100000 -c 1 -q 2 http://<host>:8080/devices


Generate Load (Latency Summary)
hey -n 100000 -c 1 -q 2 http://<host>:8080/login

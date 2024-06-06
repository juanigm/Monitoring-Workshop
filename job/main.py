from prometheus_client import CollectorRegistry, Gauge, push_to_gateway, Counter
import os
import time
from urllib import error  


registry = CollectorRegistry()

# metrics initialization
g = Gauge('random_per_second', 'Random number to simulate gauge',["application"], registry=registry)
c = Counter("basic_count","Basic counter simulation",["application"], registry=registry)

url = os.environ["url"]
port = os.environ["port"]

for _ in range(5):
  try:
    random_per_second = int.from_bytes(os.urandom(3),"little")
    g.labels("MyCronJob").set(random_per_second)
    push_to_gateway(f'{url}:{port}', job='MyCronJob_Pushgateway', registry=registry)

    c.labels("MyCronJob").inc()
    push_to_gateway(f'{url}:{port}', job="MyCronJob_Pushgateway", registry=registry)
    time.sleep(10)
  except error.URLError as err:
    print(f"Error en la conexión: {err}")
    time.sleep(10)
    pass
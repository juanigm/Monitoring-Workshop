FROM python:3.9.19-alpine3.20
WORKDIR /app

COPY . .
RUN chmod +x ./main.py && pip install -r ./requirements.txt

# CMD ["python3", "-u", "main.py"]
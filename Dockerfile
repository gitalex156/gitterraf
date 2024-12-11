FROM python:3.10.12
WORKDIR /app

# Копируем requirements.txt в контейнер
COPY requirements.txt .

# Устанавливаем зависимости
RUN pip install -r /app/requirements.txt

# Копируем исходный код приложения в контейнер
COPY . .
# Команда для запуска бота
CMD ["python3", "botinfoakz.py"]

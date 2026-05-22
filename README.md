# Telegram Bot

Проект уже подготовлен для Python-бота в Telegram.

## Что установлено

- Локальная среда Python: `.venv`
- Библиотека для Telegram: `python-telegram-bot`
- Загрузка токена из `.env`: `python-dotenv`
- Файл зависимостей: `requirements.txt`
- Стартовый файл без бизнес-логики: `bot.py`

## Как запустить

1. Активировать среду:

```bash
source .venv/bin/activate
```

2. Создать файл `.env` рядом с `bot.py` и вставить токен от BotFather:

```bash
TELEGRAM_BOT_TOKEN=your_real_token_here
```

3. Запустить бота:

```bash
python bot.py
```

Если среду не активировать, можно запускать так:

```bash
.venv/bin/python bot.py
```

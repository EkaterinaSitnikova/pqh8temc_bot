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

## VPS

Бот развернут на VPS `186.246.45.66` и запускается через `systemd`.

Подключение с этого Mac:

```bash
ssh pqh8temc-vps
```

Проверить сервис:

```bash
ssh pqh8temc-vps "systemctl status pqh8temc-bot --no-pager"
```

Опубликовать изменения в GitHub и выложить их на VPS:

```bash
scripts/publish_and_deploy.sh "Короткое описание изменения"
```

Выложить на VPS уже опубликованную в GitHub версию:

```bash
scripts/deploy_to_vps.sh
```

Подробно процесс описан в `docs/deployment.md`.

# Резюме проекта Telegram-бота

Дата создания: 2026-05-21

## Что сделали

Создали и запустили Telegram-бота `@Pqh8temc_bot` на Python. Бот принимает голосовые сообщения и аудио, отправляет их в Deepgram и возвращает текстовую расшифровку в Telegram.

Рабочая папка проекта:

```text
/Users/206726535@BWT3.COM/TelegramBots/pqh8temc_bot
```

Код также отправлен в приватный GitHub-репозиторий:

```text
https://github.com/EkaterinaSitnikova/pqh8temc_bot
```

## Почему проект перенесли из OneDrive

Изначально проект создавался в папке OneDrive:

```text
/Users/206726535@BWT3.COM/Library/CloudStorage/OneDrive-VERSANT/Vibe Coding Projects/4 - Bot
```

macOS не давала стабильно запускать `launchd`-сервис из OneDrive/CloudStorage. Поэтому рабочую версию перенесли в локальную папку:

```text
/Users/206726535@BWT3.COM/TelegramBots/pqh8temc_bot
```

Именно эта локальная папка сейчас является основной.

## Что установлено

- Python virtual environment: `.venv`
- Telegram library: `python-telegram-bot`
- Deepgram transcription через HTTP API
- Загрузка секретов из `.env`: `python-dotenv`
- HTTP-клиент: `httpx`
- Git repository
- GitHub CLI: `gh`
- macOS автозапуск через `launchd`

## Основные файлы

- `bot.py` - основной код Telegram-бота.
- `.env` - локальные секреты, не отправляется в GitHub.
- `.env.example` - пример нужных переменных без секретов.
- `requirements.txt` - список Python-зависимостей.
- `.gitignore` - исключает секреты, виртуальную среду, логи и локальные служебные файлы.
- `README.md` - короткая инструкция по запуску.
- `com.pqh8temc.bot.plist` - локальный шаблон launchd-сервиса.

## Переменные окружения

В `.env` нужны:

```text
TELEGRAM_BOT_TOKEN=...
DEEPGRAM_API_KEY=...
```

Секреты не должны попадать в GitHub. Файл `.env` добавлен в `.gitignore`.

## Что умеет бот сейчас

- Команда `/start` отвечает короткой инструкцией.
- Принимает Telegram voice messages.
- Принимает обычные аудио-сообщения.
- Отправляет аудио в Deepgram.
- Использует `nova-3-general`.
- Включено автоопределение языка через `detect_language=true`, поэтому можно говорить, например, по-русски или по-английски.
- Если расшифровка длинная, бот отправляет ее частями.
- Если Deepgram не распознал речь, бот просит попробовать записать громче и дольше.

## Что временно добавляли и потом убрали

Во время диагностики добавляли:

- принудительный русский язык `DEEPGRAM_LANGUAGE=ru`;
- диагностическое сообщение с размером аудио и длительностью;
- проверку почти пустых голосовых записей.

После того как выяснилось, что проблема была в настройках микрофона Telegram, диагностику убрали, а язык вернули на автоопределение.

## Автозапуск

Бот запущен через `launchd` как пользовательский LaunchAgent:

```text
~/Library/LaunchAgents/com.pqh8temc.bot.plist
```

Рабочая директория сервиса:

```text
/Users/206726535@BWT3.COM/TelegramBots/pqh8temc_bot
```

Проверить статус:

```bash
launchctl print gui/$(id -u)/com.pqh8temc.bot
```

Перезапустить:

```bash
launchctl kickstart -k gui/$(id -u)/com.pqh8temc.bot
```

Логи:

```text
bot.err.log
bot.log
```

## Git и GitHub

Локальный Git-репозиторий создан в папке проекта. Основная ветка:

```text
main
```

Remote:

```text
origin  https://github.com/EkaterinaSitnikova/pqh8temc_bot.git
```

GitHub CLI установлен и авторизован для аккаунта:

```text
EkaterinaSitnikova
```

Обычный рабочий процесс:

```bash
git status
git add .
git commit -m "Описание изменения"
git push
```

Перед `git add .` важно помнить, что `.env` игнорируется и не должен попадать в репозиторий.

## Важное про безопасность

Токены Telegram и Deepgram были переданы в чат во время настройки. Перед реальным продакшен-использованием лучше перевыпустить оба ключа:

- Telegram token - через BotFather.
- Deepgram API key - в консоли Deepgram.

После перевыпуска нужно обновить локальный файл `.env` и перезапустить бота.

## Текущий статус

На момент последнего обновления:

- бот работает локально на Mac;
- автозапуск активен;
- код синхронизирован с GitHub;
- голосовые сообщения распознаются через Deepgram;
- язык распознавания определяется автоматически.

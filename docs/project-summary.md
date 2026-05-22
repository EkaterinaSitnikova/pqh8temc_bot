# Резюме проекта Telegram-бота

Дата создания: 2026-05-21

## Короткий handoff для новой сессии

Это главный файл для быстрого продолжения работы.

Рабочая папка проекта:

```text
/Users/206726535@BWT3.COM/TelegramBots/pqh8temc_bot
```

Важно: рабочая папка именно локальная, не OneDrive. Папка OneDrive была стартовой, но из нее macOS не давала стабильно запускать бота через `launchd`.

GitHub:

```text
https://github.com/EkaterinaSitnikova/pqh8temc_bot
```

Бот:

```text
@Pqh8temc_bot
```

Текущий функционал:

- бот работает локально на Mac через `launchd`;
- принимает voice/audio в Telegram;
- отправляет аудио в Deepgram;
- возвращает текстовую расшифровку;
- язык распознавания определяется автоматически, можно говорить по-русски и по-английски;
- диагностика размера аудио убрана из пользовательских сообщений;
- `.env` с токенами существует только локально и не попадает в GitHub.

Команды, которые чаще всего нужны:

```bash
cd "/Users/206726535@BWT3.COM/TelegramBots/pqh8temc_bot"
launchctl print gui/$(id -u)/com.pqh8temc.bot
launchctl kickstart -k gui/$(id -u)/com.pqh8temc.bot
git status
git push
```

Если новая сессия начинается с нуля, сначала открыть этот файл и `bot.py`, затем проверить:

```bash
git status --short --branch
launchctl print gui/$(id -u)/com.pqh8temc.bot | sed -n '1,80p'
```

Следующий смысловой этап: пользователь планирует дать бизнес-логику бота. Сейчас реализован только базовый прием голосовых и расшифровка.

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

После того как выяснилось, что проблема была в настройках микрофона Telegram, диагностику убрали, а язык вернули на автоопределение. Пользователь подтвердил, что после исправления Telegram начал записывать звук нормально.

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
- язык распознавания определяется автоматически;
- рабочая папка проекта: `/Users/206726535@BWT3.COM/TelegramBots/pqh8temc_bot`;
- проект готов к следующему этапу: добавлению основной бизнес-логики бота.

## Что сказать Codex в новой сессии

Можно начать новую сессию примерно так:

```text
Открой проект /Users/206726535@BWT3.COM/TelegramBots/pqh8temc_bot.
Прочитай docs/project-summary.md.
Бот уже запущен через launchd, код на GitHub, .env локальный.
Нужно продолжить разработку Telegram-бота и добавить новую логику.
```

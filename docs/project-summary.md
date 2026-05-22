# Резюме проекта Telegram-бота

Дата создания: 2026-05-21
Обновлено: 2026-05-22

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

Текущий статус:

- бот работает на VPS `186.246.45.66` через `systemd`;
- процесс деплоя теперь GitHub-first: локальные изменения коммитятся и пушатся в GitHub, а VPS забирает код из GitHub;
- деплой-скрипт: `scripts/publish_and_deploy.sh "Сообщение коммита"`;
- только перезапуск VPS из уже опубликованного GitHub-кода: `scripts/deploy_to_vps.sh`;
- подробная документация деплоя: `docs/deployment.md`;
- локальный `launchd`-сервис на Mac остановлен и disabled, чтобы не было двух polling-процессов на один Telegram token;
- подключение с Mac настроено по SSH-ключу через alias `pqh8temc-vps`;
- SSH-вход по паролю отключен;
- SSH-вход root отключен;
- рабочий пользователь для администрирования VPS: `deploy`;
- сервис бота на VPS: `pqh8temc-bot`;
- приложение на VPS лежит в `/opt/pqh8temc_bot`;
- секреты на VPS лежат в `/etc/pqh8temc_bot/pqh8temc_bot.env`;
- принимает voice/audio в Telegram;
- отправляет аудио в Deepgram;
- возвращает текстовую расшифровку;
- язык распознавания определяется автоматически, можно говорить по-русски и по-английски;
- диагностика размера аудио убрана из пользовательских сообщений;
- `.env` с токенами существует локально, секреты на VPS лежат отдельно, в GitHub не попадают.

Команды, которые чаще всего нужны:

```bash
cd "/Users/206726535@BWT3.COM/TelegramBots/pqh8temc_bot"
ssh pqh8temc-vps
ssh pqh8temc-vps "systemctl status pqh8temc-bot --no-pager"
ssh pqh8temc-vps "sudo journalctl -u pqh8temc-bot -n 80 --no-pager"
scripts/publish_and_deploy.sh "Описание изменения"
git status
git push
```

Если новая сессия начинается с нуля, сначала открыть этот файл и `bot.py`, затем проверить:

```bash
git status --short --branch
ssh pqh8temc-vps "systemctl is-active pqh8temc-bot && systemctl is-enabled pqh8temc-bot"
```

Следующий смысловой этап: пользователь планирует дать бизнес-логику бота. Сейчас реализован только базовый прием голосовых и расшифровка.

## Что сделали

Создали и запустили Telegram-бота `@Pqh8temc_bot` на Python. Бот принимает голосовые сообщения и аудио, отправляет их в Deepgram и возвращает текстовую расшифровку в Telegram.

Изначально бот работал локально на Mac через `launchd`. 2026-05-22 бот перенесли на VPS `186.246.45.66` и запустили через `systemd`.

Рабочая папка проекта:

```text
/Users/206726535@BWT3.COM/TelegramBots/pqh8temc_bot
```

Код хранится в GitHub-репозитории:

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
- macOS автозапуск через `launchd` был настроен раньше, сейчас локальный сервис остановлен
- VPS автозапуск через `systemd`
- VPS hardening: SSH key auth, password login disabled, root SSH disabled, UFW, fail2ban

## Основные файлы

- `bot.py` - основной код Telegram-бота.
- `.env` - локальные секреты, не отправляется в GitHub.
- `.env.example` - пример нужных переменных без секретов.
- `requirements.txt` - список Python-зависимостей.
- `.gitignore` - исключает секреты, виртуальную среду, логи и локальные служебные файлы.
- `README.md` - короткая инструкция по запуску.
- `com.pqh8temc.bot.plist` - локальный шаблон launchd-сервиса.
- `scripts/bootstrap_vps_security.sh` - первичная настройка VPS, SSH-ключей и hardening.
- `scripts/deploy_to_vps.sh` - деплой бота на VPS из GitHub и перезапуск systemd-сервиса.
- `scripts/publish_and_deploy.sh` - commit, push в GitHub и деплой на VPS одной командой.
- `docs/deployment.md` - подробная схема GitHub-first деплоя.

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

Раньше бот был запущен через `launchd` как пользовательский LaunchAgent:

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

Сейчас рабочий автозапуск находится на VPS через `systemd`:

```bash
ssh pqh8temc-vps "systemctl status pqh8temc-bot --no-pager"
ssh pqh8temc-vps "sudo systemctl restart pqh8temc-bot"
ssh pqh8temc-vps "sudo journalctl -u pqh8temc-bot -n 80 --no-pager"
```

На VPS:

```text
App directory: /opt/pqh8temc_bot
Environment file: /etc/pqh8temc_bot/pqh8temc_bot.env
Service user: pqhbot
Admin user: deploy
```

Локальный LaunchAgent на Mac остановлен и disabled, чтобы не было двух одновременно работающих polling-процессов.

## VPS SSH и безопасность

Подключение с этого Mac:

```bash
ssh pqh8temc-vps
```

Настроено:

- отдельный SSH-ключ `~/.ssh/pqh8temc_vps_ed25519`;
- пользователь `deploy` с sudo без пароля для автоматизации;
- `PasswordAuthentication no`;
- `PermitRootLogin no`;
- UFW активен, разрешен только OpenSSH;
- fail2ban активен для sshd.

Root-пароль был заменен на случайный длинный пароль и сохранен в macOS Keychain как аварийный console password. По SSH root больше не входит.

Проверка:

```bash
ssh pqh8temc-vps "sudo sshd -T | egrep '^(passwordauthentication|permitrootlogin|pubkeyauthentication|kbdinteractiveauthentication) '"
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
scripts/publish_and_deploy.sh "Описание изменения"
```

Скрипт сам делает commit, push и деплой на VPS из GitHub. Перед любым ручным `git add .` важно помнить, что `.env` игнорируется и не должен попадать в репозиторий.

## Важное про безопасность

Токены Telegram и Deepgram были переданы в чат во время настройки. Перед реальным продакшен-использованием лучше перевыпустить оба ключа:

- Telegram token - через BotFather.
- Deepgram API key - в консоли Deepgram.

После перевыпуска нужно обновить локальный файл `.env`, файл на VPS `/etc/pqh8temc_bot/pqh8temc_bot.env` и перезапустить бота.

## Текущий статус

На момент последнего обновления:

- бот работает локально на Mac;
- бот работает на VPS через `systemd`;
- локальный macOS `launchd` остановлен и disabled;
- код деплоится по схеме GitHub-first;
- голосовые сообщения распознаются через Deepgram;
- язык распознавания определяется автоматически;
- рабочая папка проекта: `/Users/206726535@BWT3.COM/TelegramBots/pqh8temc_bot`;
- проект готов к следующему этапу: добавлению основной бизнес-логики бота.

## Что сказать Codex в новой сессии

Можно начать новую сессию примерно так:

```text
Открой проект /Users/206726535@BWT3.COM/TelegramBots/pqh8temc_bot.
Прочитай docs/project-summary.md.
Бот уже запущен на VPS через systemd, деплой идет через GitHub, .env локальный и отдельно на VPS.
Нужно продолжить разработку Telegram-бота и добавить новую логику.
```

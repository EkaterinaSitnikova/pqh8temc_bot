# Деплой через GitHub

Код проекта сначала попадает в GitHub, а VPS потом забирает код именно оттуда.

## Репозиторий

GitHub:

```text
https://github.com/EkaterinaSitnikova/pqh8temc_bot
```

Репозиторий публичный. Секреты в него не попадают:

- `.env` игнорируется через `.gitignore`;
- токены Telegram и Deepgram хранятся локально и на VPS отдельно;
- на VPS файл секретов: `/etc/pqh8temc_bot/pqh8temc_bot.env`.

## Обычный деплой

Из рабочей папки проекта на Mac:

```bash
cd "/Users/206726535@BWT3.COM/TelegramBots/pqh8temc_bot"
scripts/publish_and_deploy.sh "Короткое описание изменения"
```

Скрипт делает:

1. Проверяет, что `.env` игнорируется Git.
2. Проверяет shell-скрипты на синтаксис.
3. Делает `git add -A`.
4. Делает commit, если есть изменения.
5. Делает `git push origin main`.
6. Подключается к VPS по `ssh pqh8temc-vps`.
7. На VPS делает `git fetch`/`checkout` из GitHub.
8. Обновляет Python-зависимости.
9. Перезапускает `systemd`-сервис `pqh8temc-bot`.

Если коммит уже сделан и нужен только деплой текущего GitHub-кода:

```bash
scripts/deploy_to_vps.sh
```

## Проверки

Статус сервиса:

```bash
ssh pqh8temc-vps "systemctl status pqh8temc-bot --no-pager"
```

Логи:

```bash
ssh pqh8temc-vps "sudo journalctl -u pqh8temc-bot -n 80 --no-pager"
```

Проверить, какой commit сейчас на VPS:

```bash
ssh pqh8temc-vps "git -C /opt/pqh8temc_bot rev-parse --short HEAD"
```

Если Git когда-нибудь ругнется на ownership репозитория, проверка через service user:

```bash
ssh pqh8temc-vps "sudo -u pqhbot git -C /opt/pqh8temc_bot rev-parse --short HEAD"
```

## Где что лежит на VPS

```text
Код:      /opt/pqh8temc_bot
Секреты:  /etc/pqh8temc_bot/pqh8temc_bot.env
Сервис:   pqh8temc-bot
User:     pqhbot
Admin:    deploy
```

## Что важно для следующих сессий

Не копировать код на VPS через `rsync` вручную. Правильный путь:

```text
local files -> git commit -> git push -> VPS git pull/fetch -> restart service
```

Пароли GitHub не нужны. На Mac уже настроен GitHub CLI, а VPS берет код из публичного репозитория.

## Последняя проверка

2026-05-22 проверен полный цикл:

```text
local commit -> GitHub push -> VPS fetch/reset -> systemd restart
```

После проверки:

- GitHub-репозиторий публичный;
- локальная ветка `main`, `origin/main` и checkout на VPS совпадают;
- сервис `pqh8temc-bot` активен;
- реальные значения из локального `.env` не найдены в Git history.

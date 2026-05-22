import logging
import os

import httpx
from dotenv import load_dotenv
from telegram import Update
from telegram.ext import Application, CommandHandler, ContextTypes, MessageHandler, filters


load_dotenv()

logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO,
)
logging.getLogger("httpx").setLevel(logging.WARNING)
logging.getLogger("httpcore").setLevel(logging.WARNING)
logger = logging.getLogger(__name__)

DEEPGRAM_LISTEN_URL = "https://api.deepgram.com/v1/listen"
DEEPGRAM_TIMEOUT = httpx.Timeout(120.0, connect=15.0)


async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if update.message:
        await update.message.reply_text(
            "Бот запущен. Пришлите голосовое сообщение, и я переведу его в текст."
        )


def extract_transcript(payload: dict) -> str:
    channels = payload.get("results", {}).get("channels", [])
    if not channels:
        return ""

    alternatives = channels[0].get("alternatives", [])
    if not alternatives:
        return ""

    return alternatives[0].get("transcript", "").strip()


def split_text(text: str, chunk_size: int = 3900) -> list[str]:
    return [text[index : index + chunk_size] for index in range(0, len(text), chunk_size)]


async def send_transcript(status_message, transcript: str) -> None:
    chunks = split_text(transcript)
    if len(chunks) == 1:
        await status_message.edit_text(chunks[0])
        return

    await status_message.edit_text("Готово. Расшифровка получилась длинной, отправляю частями:")
    for chunk in chunks:
        await status_message.reply_text(chunk)


async def transcribe_with_deepgram(audio: bytes, content_type: str) -> str:
    api_key = os.getenv("DEEPGRAM_API_KEY")
    if not api_key:
        raise RuntimeError("Добавьте DEEPGRAM_API_KEY в файл .env")

    params = {
        "model": "nova-3-general",
        "detect_language": "true",
        "smart_format": "true",
    }
    headers = {
        "Authorization": f"Token {api_key}",
        "Content-Type": content_type,
    }

    async with httpx.AsyncClient(timeout=DEEPGRAM_TIMEOUT) as client:
        response = await client.post(
            DEEPGRAM_LISTEN_URL,
            params=params,
            headers=headers,
            content=audio,
        )
        response.raise_for_status()

    return extract_transcript(response.json())


async def handle_audio(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not update.message:
        return

    media = update.message.voice or update.message.audio
    if not media:
        return

    status_message = await update.message.reply_text("Слушаю и перевожу в текст...")
    content_type = getattr(media, "mime_type", None) or "audio/ogg"
    duration = getattr(media, "duration", None)
    file_size = getattr(media, "file_size", None)

    try:
        file = await context.bot.get_file(media.file_id)
        audio_bytes = await file.download_as_bytearray()
        logger.info(
            "Received audio: duration=%s seconds, telegram_size=%s bytes, downloaded=%s bytes, content_type=%s",
            duration,
            file_size,
            len(audio_bytes),
            content_type,
        )
        transcript = await transcribe_with_deepgram(bytes(audio_bytes), content_type)
    except httpx.HTTPStatusError as exc:
        logger.exception("Deepgram returned an error")
        await status_message.edit_text(
            f"Deepgram вернул ошибку: {exc.response.status_code}. Попробуйте еще раз."
        )
        return
    except Exception:
        logger.exception("Failed to transcribe audio")
        await status_message.edit_text(
            "Не получилось распознать голосовое. Попробуйте отправить запись еще раз."
        )
        return

    if not transcript:
        logger.info(
            "Deepgram returned an empty transcript: duration=%s seconds, downloaded=%s bytes",
            duration,
            len(audio_bytes),
        )
        await status_message.edit_text(
            "Я получил голосовое, но не разобрал речь. Попробуйте записать чуть громче и дольше."
        )
        return

    await send_transcript(status_message, transcript)


def main() -> None:
    token = os.getenv("TELEGRAM_BOT_TOKEN")
    if not token:
        raise RuntimeError("Добавьте TELEGRAM_BOT_TOKEN в файл .env")

    application = Application.builder().token(token).build()
    application.add_handler(CommandHandler("start", start))
    application.add_handler(MessageHandler(filters.VOICE | filters.AUDIO, handle_audio))

    logger.info("Bot is running")
    application.run_polling()


if __name__ == "__main__":
    main()

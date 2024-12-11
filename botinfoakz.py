import yfinance as yf
from aiogram import Bot, Dispatcher, types
from aiogram.types import InlineKeyboardButton, InlineKeyboardMarkup
from aiogram.utils import executor

import config2 as cfg

bot = Bot(token=cfg.TOKEN)
dp = Dispatcher(bot)

# Список символов акций
symbols = ["AAPL", "MSFT"]

# Создаем инлайн клавиатуру для выбора акций
keyboard_start = types.InlineKeyboardMarkup()
for symbol in symbols:
    keyboard_start.add(types.InlineKeyboardButton(text=f"Информация о {symbol} ❓", callback_data=f"get_stock_info_{symbol}"))

# Обработчик команды /start
@dp.message_handler(commands=['start'])
async def send_welcome(message: types.Message):
    user_name = message.from_user.full_name
    if not user_name:
        user_name = message.from_user.username
    
    # URL изображения
    image_url = 'https://s.rbk.ru/v1_companies_s3/resized/960xH/media/company_press_release_image/e01f81e9-a2a4-475d-ae45-ec6140822bfe.jpg'
    
    # Отправка сообщения с изображением и кнопками для каждой акции
    await bot.send_photo(
        message.from_user.id,
        photo=image_url,
        caption=f"Привет, <b>{user_name}</b>! Выберите акцию, чтобы узнать информацию о ней за последний месяц по объемам торгов! 🚀",
        reply_markup=keyboard_start,
        parse_mode='HTML'  # Указываем парсеру HTML для форматирования текста
    )

# Функция, которая отправляет данные о ценах закрытия и объемах торгов пользователю
async def send_stock_info(message: types.Message, symbol: str):
    data = yf.download(symbol, period="1mo")
    if not data.empty:
        close_prices = data["Close"]
        volumes = data["Volume"]
        
        info_message = f"Цены закрытия за последний месяц ({symbol}):\n{close_prices}\n\nОбъемы торгов за последний месяц ({symbol}):\n{volumes}"
        await message.answer(info_message)

        # Отправляем ту же самую клавиатуру, что и после команды /start
        await message.answer("Выберите еще раз акцию:", reply_markup=keyboard_start)
    else:
        await message.answer(f"Данные по акции {symbol} недоступны.")

# Обработчик нажатия на кнопки
@dp.callback_query_handler(lambda c: c.data.startswith('get_stock_info_'))
async def process_callback_stock(callback_query: types.CallbackQuery):
    symbol = callback_query.data.replace('get_stock_info_', '')  # Получаем символ акции из callback_data
    await send_stock_info(callback_query.message, symbol)

# Запуск бота
if __name__ == '__main__':
    executor.start_polling(dp, skip_updates=True)
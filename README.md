# fx-project

**Language**
- MQL4
- AutoHotkey

This is my personal project that test the effectiveness of some proprietary indicators  
Because of the lack of these indicators, you can only use "Place Order.mq4" that assist you to set forex order via Telegram

**Funtions of Place Order.mq4:**
- Support placing orders with equal volume (equal [risk]% of total Balance), and at a fixed TP, SL
- Change config (risk, TP, SL, balance) via Telegram chat

## How to complile "Place Order.mq4
### 1. Prepare the environment - Windows only
- Set up [MT4](https://www.metatrader4.com/en/download)
- Copy all file in lib.rar to './MQL4/Include/'
- Copy mq4 file to './MQL4/Experts/' and open with Meta Editor 4 (press F4)
- Check with your broker about symbol's suffix and put into suffix (line 13). Leave it as a blank string "" if there is no suffix

### 2. Get Telegram bot token, user_id
- [Get token](https://www.siteguarding.com/en/how-to-get-telegram-bot-api-token)
- [Get user_id](https://stackoverflow.com/questions/32683992/find-out-my-own-user-id-for-sending-a-message-with-telegram-api)
- Paste token into InpToken (line 14)
- Paste user_id into owner_id (line 15)

### 3. Compile to ex4
[Compile EA and run it](https://www.nordman-algorithms.com/how-to-install-and-run-expert-advisor-ea-in-metatrader-4/)

**Note:** you need to allow EA to connect to telegram API  
- On MT4, select Tools -> Options -> Expert Advisors
- Check "Allow WebRequest for listed ULR" and type in 'https://api.telegram.org/'

Have fun!

## Screenshot

**Telegram bot**
![screenshot-ea](https://user-images.githubusercontent.com/55086588/184531655-012d75dc-737d-4f18-ba5e-4260ae57fb72.png)

**Winrate matrix at each TP-SL**  
<img src="https://user-images.githubusercontent.com/55086588/189494554-3d22a198-1e2d-4ba0-abc7-e1d5284ed092.png" width="600" height="600">

**Trade result matrix**  

<img src="https://user-images.githubusercontent.com/55086588/189494536-87d7d742-d11d-4885-abde-79a73c3f26a3.png" width="600" height="600">

## About Telegram API
https://core.telegram.org/bots/api

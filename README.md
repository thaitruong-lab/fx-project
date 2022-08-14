# fx-project

### Language
MQL4
AutoHotkey

This is my personal project that test the effectiveness of some proprietary indicators

Because of the lack of these indicators, you can only use "Place Order.mq4" that assist you to set forex order via Telegram chat at a controled risk, TP, SL...

## How to complile "Place Order.mq4
### 1. Prepare the environment
Copy all file in lib.rar to './MQL4/Include/'

Copy mq4 file to './MQL4/Experts/' and open with Meta Editor 4 (press F4)

Check with your broker about symbol's suffix and put into suffix (line 13). Leave it as a blank string "" if there is no suffix

### 2. Get Telegram bot token, user_id
[Get token](https://www.siteguarding.com/en/how-to-get-telegram-bot-api-token)

[Get user_id](https://stackoverflow.com/questions/32683992/find-out-my-own-user-id-for-sending-a-message-with-telegram-api)

Paste token into InpToken (line 14)

Paste user_id into owner_id (line 15)

### 3. Compile to ex4
[Compile EA and run it](https://www.nordman-algorithms.com/how-to-install-and-run-expert-advisor-ea-in-metatrader-4/)

**Note:** you need to allow EA to connect to telegram API

On MT4, select Tools -> Options -> Expert Advisors

Check "Allow WebRequest for listed ULR" and type in 'https://api.telegram.org/'

Have fun!

## Screenshot

![screenshot-ea](https://user-images.githubusercontent.com/55086588/184531655-012d75dc-737d-4f18-ba5e-4260ae57fb72.png)


## About Telegram API
https://core.telegram.org/bots/api

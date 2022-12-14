//+------------------------------------------------------------------+
//|                                             Get Trend Signal.mq4 |
//|                                                 Truong Hong Thai |
//|                                                   truonghongthai |
//+------------------------------------------------------------------+

#property version   "1.02"
#property strict

string symbolsArray[24] = {"AUDCAD", "AUDCHF", "AUDJPY", "AUDUSD",
                           "EURAUD", "EURCAD", "EURCHF", "EURJPY", "EURNZD", "EURUSD",
                           "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
                           "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD",
                           "USDCAD", "USDJPY", "USDCHF", "XAUUSD"
                          };


string mainMsg = "";
//+------------------------------------------------------------------+

//--- khung thời gian phân tích, mỗi khung lấy bao nhiêu cây nến
int timeFrame[1] = {240};
int barInFrame[1] = {60};  // Muốn tìm Lead Period thì barInFame[0] phải lớn mới bao quát hết được

datetime timeOfZeroBar;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int analyzePeriod = timeFrame[ArraySize(timeFrame)-1];

bool letOrder = false, trendExist;

string trendStatus_strTrend[];
int trendStatus_TrendLength[];

int periodValue[7] = {1440, 240, 60, 30, 15, 5, 1};
string periodName[7] = {"D1", "H4", "H1", "M30", "M15", "M5", "M1"};
string strLeadPeriod="", strAnalyzePeriod="";

//--- kiểm tra sự hình thành của cây nến mới
bool newBarAppeared = FALSE;
bool runThisTick = FALSE;

string fileName = StringConcatenate("Test\\", Symbol(), "-", Period(), ".csv");
int fileHandle;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
//--- convert and check Period
   for(int i = 0; i < ArraySize(periodValue); i++)
   {
      if(timeFrame[0] == periodValue[i])
         strLeadPeriod = periodName[i];

      if(analyzePeriod == periodValue[i])
         strAnalyzePeriod = periodName[i];
   }

   if(strLeadPeriod == "" || strAnalyzePeriod == "")
   {
      Alert("Invalid Period - timeFrame declare");
      return(INIT_FAILED);
   }

   Print("-----Lead period: ", strLeadPeriod);
   Print("Analyze period: ", strAnalyzePeriod);

   if(ArraySize(timeFrame) != ArraySize(barInFrame))
   {
      Print("Check number and values of timeFrame and barInFrame");
      Alert("Check number and values of timeFrame and barInFrame");
      return(INIT_FAILED);
   }

//--- Resize
   ArrayResize(trendStatus_strTrend, ArraySize(symbolsArray), 100);
   ArrayResize(trendStatus_TrendLength, ArraySize(symbolsArray), 100);

//--- OpenFile
   Print("Open file ", fileName);
   fileHandle = FileOpen(fileName, FILE_WRITE|FILE_CSV|FILE_ANSI);
   if(fileHandle<0) return(INIT_FAILED);
//--- write header
   FileWriteString(fileHandle, "Time,Symbol,Current Trend,Bar H4, Bar H4\r\n");
//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   Print("Close file ", fileName);
   FileClose(fileHandle);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()   // void OnTick()    void OnTimer()
{
   if(OrdersTotal()>0)
      return;

   checkFormationOfNewBar();
   if(!runThisTick)
      return;
   runThisTick = false;

   trendExist = False;

   Print(timeOfZeroBar);
//--- main fuction
   for(int i = 0; i < ArraySize(symbolsArray); i++)
   {
      trendStatus_TrendLength[i] +=1; //sau mỗi lần chạy thì làm tăng bar lên
      checkTrend(symbolsArray[i]);
   }

   if(!trendExist)
      return;

   FileWriteString(fileHandle, mainMsg);
   mainMsg = "";
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void checkFormationOfNewBar()
{
//--- dong lenh vao dau cay nen moi
   if(iTime(Symbol(), analyzePeriod, 0) == timeOfZeroBar)
   {
      newBarAppeared = FALSE;
      return;
   }
   else
   {
      timeOfZeroBar =iTime(Symbol(), analyzePeriod, 0);
      //Sleep(sleepBfRun*1000);
      RefreshRates();
      newBarAppeared = TRUE;
      runThisTick = TRUE;
      return;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void                checkTrend(string symbol)
{
//--- gán giá trị *** trend vào mảng, mỗi dòng là 1 khung giờ, số lượng giá trị giống như barInFrame

   double trendArray[100][100];
   ArrayFill(trendArray, 0, 0, 0);

   for(int i = 0; i<ArraySize(timeFrame); i++)
   {
      for(int j = 0; j < barInFrame[i]; j++)
      {
         trendArray[i, j] = iCustom(symbol, timeFrame[i], "CHNtrend", 0, j);
      }
   }

//--- xét xem các khung có đồng bộ xu hướng không, xét 3 đoạn gần nhất
   string currentTrend = ""; //check current trend is up or down
   
   if(trendArray[0, 1] < trendArray[0, 0])
   {
      currentTrend = "Up";
      for(int i = 0; i<ArraySize(timeFrame); i++)
      {
         for(int j = 0; j < 3; j++)
         {
            if(trendArray[i, j+1] > trendArray[i, j])
            {
               currentTrend = "";
               return;
            }
         }
      }
   }

   else if(trendArray[0, 1] > trendArray[0, 0])
   {
      currentTrend = "Down";
      for(int i = 0; i<ArraySize(timeFrame); i++)
      {
         for(int j = 0; j < 3; j++)
         {
            if(trendArray[i, j+1] < trendArray[i, j])
            {
               currentTrend = "";
               return;
            }
         }
      }
   }

//--- tìm xem tại khung bé nhất thì trend đã tô được bao nhiêu cây
   int maxBarInAnalyzeTrend = getTrendLength(trendArray, ArraySize(timeFrame)-1);
//--- tìm xem trong khung giờ đầu tiên (to nhất) thì trend đã tô được bao nhiêu cây
   int maxBarInLeadTrend    = getTrendLength(trendArray, 0);

   trendExist = TRUE;

   string trendIcon = getTrendIcon(currentTrend);

   string status = "";
   string statusIcon = "";
   checkStatus(symbol, maxBarInAnalyzeTrend, currentTrend, status, statusIcon);

   if(status != "New") return;
   string openTime = TimeToStr(timeOfZeroBar, TIME_DATE|TIME_MINUTES);
   mainMsg += StringConcatenate(openTime,              ",",
                                symbol,                ",",
                                currentTrend,          ",",
                                maxBarInAnalyzeTrend,  ",",
                                maxBarInLeadTrend,     ",",
                                "\r\n"
                               );

   return;
}

//+------------------------------------------------------------------+
//|                       Check Status                               |
//+------------------------------------------------------------------+
void checkStatus(const string symbol, const int analyzeTrendLength, const string trend,
                 string &status, string &statusIcon)
{
   int symbolNo = -1;
   for(int i=0; i<ArraySize(symbolsArray); i++)
      if(symbol == symbolsArray[i])
      {
         symbolNo=i;
         break;
      }

   if(symbolNo == -1)
   {
      status = "Error";
      Print("Check status error, can not get Symbol No");
      return;
   }

   if(trendStatus_strTrend[symbolNo] != trend)
   {
      status = "New";
      if(trendStatus_strTrend[symbolNo]=="")
         statusIcon = "\xF500\xF7E2"; //lần đầu chạy k có xoáy báo đổi trend
      else statusIcon = "\xF7E2";

      trendStatus_strTrend[symbolNo]    = trend;
      trendStatus_TrendLength[symbolNo] = analyzeTrendLength;
      return;
   }

   if(trendStatus_strTrend[symbolNo] == trend)
   {
      if(trendStatus_TrendLength[symbolNo] > analyzeTrendLength + 1)
      {
         trendStatus_TrendLength[symbolNo] = analyzeTrendLength;
         status = "New";
         statusIcon = "\xF7E2";
         return;
      }
      else
      {
         status = "Old";
         statusIcon = "\xF7E1";
         return;
      }
   }

   status = "Check status Error";
   statusIcon = "Check status Error";
   return;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getTrendIcon(string trend)
{
   if(trend == "Up")
      return("\xF332"); //cây thông xanh
   else if(trend == "Down")
      return("\xF53B"); //tam giác đỏ quay xuống
   else
      return("Trend not valid");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getTrendLength(double  &trendArray[][], const int trendNo)
{
   int trendLength = 0;

   if(trendArray[trendNo, 1] < trendArray[trendNo, 0]) //Up Trend
   {
      for(int j = 0; j < 96; j++)
      {
         if(trendArray[trendNo, j+1] >= trendArray[trendNo, j])
            break;
         trendLength++;
      }
   }
   else if(trendArray[trendNo, 1] > trendArray[trendNo, 0]) //Down Trend
   {
      for(int j = 0; j < 96; j++)
      {
         if(trendArray[trendNo, j+1] <= trendArray[trendNo, j])
            break;
         trendLength++;
      }
   }

   return(trendLength);
}
//+------------------------------------------------------------------+

extern double TakeProfit = 50;
extern double StopLoss = 0;
extern double Lots = 0.01;
static double MACDOpenLevel=3;
static double MACDCloseLevel=2;
static double MATrendPeriod=26;
extern double MinAbsMACD = 0.00010;
extern double MinMACDDeviation = 0.08;
extern double MinMACDRejectDeviation = 0.1;
extern int TTL = 1800;

static int TimeFrameArray[] = {0,
                               PERIOD_M1,    //1
                               PERIOD_M5,    //2
                               PERIOD_M15,   //3
                               PERIOD_M30,   //4
                               PERIOD_H1,    //5
                               PERIOD_H4,    //6
                               PERIOD_D1,    //7
                               PERIOD_W1,    //8
                               PERIOD_MN1,   //9
                              };
extern int TimeFrameIndex = 0;

static datetime preOrderTime = 0;

static int countRejectSignal = 0;
static int currentTicket = 0;

static bool StochasticsEnabledBUY = false;
static bool MACDEnabledBUY = false;
static bool AlligatorEnabledBUY = false;
static datetime StochasticsEnabledBUYTime = 0;
static datetime MACDEnabledBUYTime = 0;
static datetime AlligatorEnabledBUYTime = 0;

static bool StochasticsEnabledSELL = false;
static bool MACDEnabledSELL = false;
static bool AlligatorEnabledSELL = false;
static datetime StochasticsEnabledSELLTime = 0;
static datetime MACDEnabledSELLTime = 0;
static datetime AlligatorEnabledSELLTime = 0;

static int SignalTTL = 180; // каждый из сигналов ожидает сигнала по второму индикатору не более трех минут

static datetime sleepTime = 0;
static bool sleepTimeEnabled = false;

static int countAllOrder = 0;
static datetime timeAllOrder = 0;

extern int StochasticsSignalParettoLimit = 0;
extern int CheckSharpnessMACDEnabled = 0;
extern int StochasticsMainLimitEnabled = 0;

int start()
{
  OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
  
  if (OrderType() == OP_SELL && Ask <= OpenBid - 0.00005)
  {
    OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet);
  }
  
  if (OrderType() == OP_BUY && Bid >= OpenAsk + 0.00005)
  {
    OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);
  }
  
  bool b;
  
  // Проверяем, существует ли еще наша сделка  
  bool allowTrade = true;
  if (currentTicket != 0) {
    for (int i = 0; i < OrdersTotal(); i++) {
      OrderSelect (i, SELECT_BY_POS, MODE_TRADES);
      int t = OrderTicket();
      if (t == currentTicket) {
          allowTrade = false;
      }
    }
  }
  if (allowTrade) {
    currentTicket = 0;
  }
  
  // Проверяем стохастический индикатор
  if (!StochasticsEnabledBUY) { // если активного ожидающего сигнала нет, то определяем есть ли сейчас сигнал
    b = StochasticsConfirm(OP_BUY);
    if (b) {
        StochasticsEnabledBUY = true;
        StochasticsEnabledBUYTime = TimeCurrent();    
    }
  }
  if (!StochasticsEnabledSELL) { // если активного ожидающего сигнала нет, то определяем есть ли сейчас сигнал
    b = StochasticsConfirm(OP_SELL);
    if (b) {
        StochasticsEnabledSELL = true;
        StochasticsEnabledSELLTime = TimeCurrent();    
    }
  }
  
  // если мы на стохастическом индикаторе ожидаем сигнала от MACD, то проверяем не исчерпало ли себя движение по Stochastics
  if (StochasticsEnabledBUY)  {
    b = StochasticsCancel(OP_BUY);
    if (b) {
        Print("Отменили стохастический сигнал на покупку");
        StochasticsEnabledBUY = false;    
    }
  }
  if (StochasticsEnabledSELL)  {
    b = StochasticsCancel(OP_SELL);
    if (b) {
        Print("Отменили стохастический сигнал на продажу");
        StochasticsEnabledSELL = false;    
    }
  }
  
  // Проверяем индикатор MACD
  if (!MACDEnabledBUY) { // если активного ожидающего сигнала нет, то определяем есть ли сейчас сигнал
    b = MACDConfirm(OP_BUY);
    if (b) {
        MACDEnabledBUY = true;
        MACDEnabledBUYTime = TimeCurrent();    
    }
  }
  if (!MACDEnabledSELL) { // если активного ожидающего сигнала нет, то определяем есть ли сейчас сигнал
    b = MACDConfirm(OP_SELL);
    if (b) {
        MACDEnabledSELL = true;
        MACDEnabledSELLTime = TimeCurrent();    
    }
  }
  
  // Проверяем сигналы алигатора.
  AlligatorEnabledBUY = AlligatorConfirm(OP_BUY);
  AlligatorEnabledSELL = AlligatorConfirm(OP_SELL);
  
  // Сбрасываем сигналы на покупку, ожидающие более трех минут
  if (TimeCurrent()-StochasticsEnabledBUYTime > SignalTTL) {
    StochasticsEnabledBUY = false;
  }
  if (TimeCurrent()-MACDEnabledBUYTime > SignalTTL) {
    MACDEnabledBUY = false;
  }
  // Сбрасываем сигналы на продажу, ожидающие более трех минут
  if (TimeCurrent()-StochasticsEnabledSELLTime > SignalTTL) {
    StochasticsEnabledSELL = false;
  }
  if (TimeCurrent()-MACDEnabledSELLTime > SignalTTL) {
    MACDEnabledSELL = false;
  }
  
  //Блок управления открытием ордеров.   
  if (allowTrade) // если нет открытых сделок
  {
    //Блок проверки наличия свободной маржи.
    if (AccountFreeMargin() < (1000*Lots))
    {
      Print("Free Margin is absent. Account Free Margin: ", AccountFreeMargin());
      return(0);  
    }
    
    bool allow = true;
    if (sleepTimeEnabled) {
      allow = TimeCurrent()>sleepTime;
    }
    if (allow) {
      sleepTimeEnabled = false;
    }
      
    //Блок управления открытием ордеров на покупку.
    if (MACDEnabledBUY && StochasticsEnabledBUY && AlligatorEnabledBUY) {
      if (checkEvennessMACD()) {
        if (allow) {
            countRejectSignal++;
            Print("BUY отклонен. MACD горизонтален; countRejectSignal=", countRejectSignal);
            // заснуть до начала следующей минуты, чтобы не спамить в логи
            sleepTime = (TimeCurrent() / 60 + 1)*60;
            sleepTimeEnabled = true;
        }
      } else {
        Print("С момента сигнала MACD прошло = ", TimeCurrent()-MACDEnabledBUYTime);
        Print("С момента сигнала Stochastics прошло = ", TimeCurrent()-StochasticsEnabledBUYTime);
        createBuyOrder();
      }
    }
      
    //Блок управления открытием ордеров на продажу.  
    if (MACDEnabledSELL && StochasticsEnabledSELL && AlligatorEnabledSELL) {
      if (checkEvennessMACD()) {
        if (allow) {
            countRejectSignal++;
            Print("SELL отклонен. MACD горизонтальная; countRejectSignal=", countRejectSignal);
            // заснуть до начала следующей минуты, чтобы не спамить в логи
            sleepTime = (TimeCurrent() / 60 + 1)*60;
            sleepTimeEnabled = true;
        }
      } else {
        Print("С момента сигнала MACD прошло = ", TimeCurrent()-MACDEnabledSELLTime);
        Print("С момента сигнала Stochastics прошло = ", TimeCurrent()-StochasticsEnabledSELLTime);
        createSellOrder();  
      }
    }  
  }  
  closeWrongOrders();
}

void createBuyOrder() {
    double absStopLoss = 0;
    if (StopLoss > 0) {
        absStopLoss = Bid-StopLoss*Point;
    }
         
    double absTakeProfit = 0;
    if (TakeProfit > 0) {
        absTakeProfit = Ask+TakeProfit*Point;
    }   
      
    //Блок открытия ордера на покупку.
    int ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, absStopLoss, absTakeProfit, "Buy Order Done!", 16384, 0, Green);
    if (ticket > 0) {
        currentTicket = ticket;
        if (OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
            preOrderTime = TimeCurrent();
        }
    } else {
        Print("Сделка не создана.");
    }    
}

void createSellOrder() {
    double absStopLoss = 0;
    if (StopLoss > 0) {
        absStopLoss = Ask+StopLoss*Point;
    } 
    
    double absTakeProfit = 0;
    if (TakeProfit > 0) {
        absTakeProfit = Bid-TakeProfit*Point;
    }
      
    //Блок открытия ордера на продажу.
    int ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,3, absStopLoss, absTakeProfit, "Sell Order Done!", 16384, 0, Red);
    if (ticket > 0) {
        currentTicket = ticket;
        if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
            preOrderTime = TimeCurrent();
        }
    } else {
        Print("Сделка не создана.");
    }   
}

bool MACDConfirm(int cmd) {
    int k1, k2;
    if (cmd == OP_BUY) {
        k1 = -1;
        k2 = 1;
    } else if (cmd == OP_SELL) {
        k1 = 1;
        k2 = -1;
    }
    double MACDCurrent=    iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,0);
    double MACDPrevious=   iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,1);
    double SignalCurrent=  iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
    double SignalPrevious= iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
    double macd2=    iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,2);
    // OP_BUY:  Индикатор MACD находится ниже нуля, идёт снизу вверх, а его сверху вниз пересекает сигнальная линия.
    // OP_SELL: Индикатор MACD находится выше нуля, идёт сверху вниз, а его снизу вверх пересекает сигнальная линия.
    bool a = true;
    if (CheckSharpnessMACDEnabled == 1) {
        a = CheckSharpnessMACD(macd2, MACDPrevious, MACDCurrent);
    }
    if (k1*MACDCurrent>0 && //<
        k2*(MACDCurrent-SignalCurrent)>0 && //>
        k1*(MACDPrevious-SignalPrevious)>0 && //<
        MathAbs(MACDCurrent) > (MACDOpenLevel*Point) &&
        MathAbs(MACDCurrent) > MinAbsMACD && a) {
        return (true);
    }
    return (false);
}

bool CheckSharpnessMACD(double macd2, double macd1, double macd0) {
    //return (true);
    double d21 = MathAbs(macd2-macd1);
    double d10 = MathAbs(macd1-macd0);
    return (d10/d21 < 3);
}

bool StochasticsConfirm(int cmd) {
    //return (true);

    // префикс v - главная линия, s - сигнальная линия, 1 - левый индекс, 2 - правый индекс
    double v1 = iStochastic(NULL, TimeFrameArray[TimeFrameIndex], 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 2);
    double v2 = iStochastic(NULL, TimeFrameArray[TimeFrameIndex], 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);    
    double s1 = iStochastic(NULL, TimeFrameArray[TimeFrameIndex], 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 2);
    double s2 = iStochastic(NULL, TimeFrameArray[TimeFrameIndex], 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);
    
    if (cmd == OP_BUY) {
        return (StochasticsConfirmBUY(v1, v2, s1, s2));
    } else if (cmd == OP_SELL) {
        return (StochasticsConfirmSELL(v1, v2, s1, s2));
    }
}

bool StochasticsCancel(int cmd) {
    //return (false);

    // префикс v - главная линия, s - сигнальная линия, 1 - левый индекс, 2 - правый индекс
    double v1 = iStochastic(NULL, TimeFrameArray[TimeFrameIndex], 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
    double v2 = iStochastic(NULL, TimeFrameArray[TimeFrameIndex], 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);    
    double s1 = iStochastic(NULL, TimeFrameArray[TimeFrameIndex], 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);
    double s2 = iStochastic(NULL, TimeFrameArray[TimeFrameIndex], 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
    
    if (cmd == OP_BUY) {
        if (v1>s1 && v2<s2) { // если главная линия пересекла сигнальную сверху вниз, отменяем предыдущий сигнал
            return (true);
        }
        if (StochasticsMainLimitEnabled == 1) {
            return (v2>70);
        }
    } else if (cmd == OP_SELL) {
        if (s1>v1 && s2<v2) { // если главная линия пересекла сигнальную снизу вверх, отменяем предыдущий сигнал
            return (true);
        }
        if (StochasticsMainLimitEnabled == 1) {
            return (v2<30);
        }
    }
    return (false);
}

bool StochasticsConfirmBUY(double v1, double v2, double s1, double s2) {
    bool a = true;
    if (StochasticsSignalParettoLimit == 1)  {
        a = MathMin(s1, s2) < 20;
    }
    if (MathMin(v1, v2) < 20 && v1<v2 && a) { // главная линия идет вверх и ее левый край меньше 20
        if (s1>v1 && s2<v2) { // если главная линия пересекла сигнальную снизу вверх
            return (true);
        }
    }
    return (false);    
}

bool StochasticsConfirmSELL(double v1, double v2, double s1, double s2) {
    bool a = true;
    if (StochasticsSignalParettoLimit == 1)  {
        a = MathMax(s1, s2) > 80;
    }
    if (MathMax(v1, v2) > 80 && v1>v2 && a) { // главная линия идет вниз и ее левый край больше 80
        if (v1>s1 && v2<s2) { // если главная линия пересекла сигнальную сверху вниз
            return (true);
        }
    }
    return (false);    
}

// Возвращает true, если MACD горизонтален.
bool checkEvennessMACD() {
    //return (false);
    double macd[3];
    macd[0] = iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,1);
    macd[1] = iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,2);
    macd[2] = iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,3);
    double maxMACD = max3(macd[0], macd[1], macd[2]);
    double deviations[3];
    for (int i = 0; i < 3; i++) {
        deviations[i] = MathAbs((macd[i]-maxMACD)/maxMACD);
        if (deviations[i] > MinMACDDeviation) {
            Print("deviation = ", deviations[i]);
            return (false);
        }
    }
    return (true);
}

double max3(double a1, double a2, double a3) {
    double a12Max = MathMax(a1, a2);
    return (MathMax(a12Max, a3));
}

bool AlligatorConfirm(int cmd) {
    //return (true);
    int k;
    if (cmd == OP_BUY) {
        k = -1;
    } else if (cmd == OP_SELL) {
        k = 1;
    }
    //double lips_prev;
    for (int i = 0; i < 5; i++) {
        double jaw =   iAlligator(NULL, TimeFrameArray[3], 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW, i);
        double teeth = iAlligator(NULL, TimeFrameArray[3], 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, i);
        double lips =  iAlligator(NULL, TimeFrameArray[3], 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, i);
        if (k*(lips-teeth)>0 || k*(lips-jaw)>0) {
            return (false);
        }
        //if (i > 1) {
        //    if (k*(lips-lips_prev)>0) {
        //        return (false);
        //    }
        //}
        //lips_prev = lips;
    }
    
    double lips1 =  iAlligator(NULL, TimeFrameArray[3], 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, 1);
    double lips2 =  iAlligator(NULL, TimeFrameArray[3], 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, 2);
    if (k*(lips1-lips2)>0) {
        return (false);  
    }
    
    return (true);
}

void closeWrongOrders() {
    
    double MACDCurrent=    iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,0);
    double MACDPrevious=   iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,1);
    double SignalCurrent=  iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
    double SignalPrevious= iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
    
    for (int i = 0; i < OrdersTotal(); i++) {
        OrderSelect (i, SELECT_BY_POS, MODE_TRADES);
        
        // которые открыты более чем TTL
        if (TimeCurrent()-OrderOpenTime()>TTL && OrderSymbol()==Symbol()) {
            if (OrderType()==OP_BUY) {
                //OrderClose(OrderTicket(), Lots, Bid, 3, Yellow);
            } else if (OrderType()==OP_SELL) {
                //OrderClose(OrderTicket(), Lots, Ask, 3, Yellow);
            }
        }
        
        // в которых сигнальная линия вошла в гистограмму, ОТКЛЮЧЕНО
        if (OrderType()==OP_BUY && OrderSymbol()==Symbol() && currentTicket == OrderTicket() && TimeCurrent()-OrderOpenTime()>60) {
            MACDPrevious=   iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,0);
            SignalPrevious= iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
            if (SignalPrevious > MACDPrevious && MathAbs((SignalPrevious-MACDPrevious)/MACDPrevious) > MinMACDRejectDeviation) {
                //OrderClose(OrderTicket(), Lots, Bid, 3, Yellow);
            }
        }
        else if (OrderType()==OP_SELL && OrderSymbol()==Symbol() && currentTicket == OrderTicket() && TimeCurrent()-OrderOpenTime()>60) {
            MACDPrevious=   iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,0);
            SignalPrevious= iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
            if (SignalPrevious < MACDPrevious && MathAbs((SignalPrevious-MACDPrevious)/MACDPrevious) > MinMACDRejectDeviation) {
                //OrderClose(OrderTicket(), Lots, Ask, 3, Yellow);
            }
        }
        
        AlligatorCancel();
    }
    
    
}

void AlligatorCancel() {
    int k;
    if (OrderType() == OP_BUY) {
        k = -1;
    } else if (OrderType() == OP_SELL) {
        k = 1;
    }
    double lips0 = iAlligator(NULL, TimeFrameArray[3], 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, 1);
    double teeth0 = iAlligator(NULL, TimeFrameArray[3], 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, 2);
    if (k*(lips0-teeth0)>0) {
        if (OrderType()==OP_BUY) {
            //OrderClose(currentTicket, Lots, Bid, 3, Yellow);
        } else if (OrderType()==OP_SELL) {
            //OrderClose(currentTicket, Lots, Ask, 3, Yellow);
        }
    }
    
    double lips1 =  iAlligator(NULL, TimeFrameArray[3], 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, 1);
    double lips2 =  iAlligator(NULL, TimeFrameArray[3], 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, 2);
    if (k*(lips1-lips2)>0) {
        if (OrderType()==OP_BUY) {
            //OrderClose(currentTicket, Lots, Bid, 3, Yellow);
        } else if (OrderType()==OP_SELL) {
            //OrderClose(currentTicket, Lots, Ask, 3, Yellow);
        }
    }
}


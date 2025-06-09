extern double TakeProfit = 1500;
extern double StopLoss = 200;
extern double Lots = 5;
extern double TrailingStop = 500;
extern double MACDOpenLevel = 3;
extern double MACDCloseLevel = 2;
extern double MATrendPeriod = 26;
extern int CountOrder = 4;

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

static datetime lastOrderTime = 0;

int start()
{
   //Print("START");
   
   // первичные проверки данных
   // важно удостовериться что эксперт работает на нормальном графике и
   // пользователь правильно выставил внешние переменные (Lots, StopLoss,
   // TakeProfit, TrailingStop)
   // в нашем случае проверяем только TakeProfit
   if (Bars < 100)
   {
      Print("bars less than 100");
      return(0);  
   }
   if(TakeProfit < 10)
   {
      //Print("TakeProfit less than 10");
      //return(0); // проверяем TakeProfit
   }

   int i, ticket, total;
   double realStopLoss, realTakeProfit;
   
   double MacdCurrent=   iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   double MacdPrevious=  iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double SignalCurrent= iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   double SignalPrevious=iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   double MaCurrent= iMA(NULL,TimeFrameArray[TimeFrameIndex],MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,0);
   double MaPrevious=iMA(NULL,TimeFrameArray[TimeFrameIndex],MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,1);
 
   // теперь надо определиться - в каком состоянии торговый терминал?
   // проверим, есть ли ранее открытые позиции или ордеры?
   total = OrdersTotal();
   
   int countProfitableOrders;
   
   for(i=0;i<total;i++)
   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      double profit=OrderProfit();
      //Print("Profit: ", profit);
      if (profit>0) {
         countProfitableOrders++;
      }
   }
   
      //Print(total);
   
   //if (AccountBalance() > 50000)
   //{
   //   Lots=5;
   //}
   
   if (countProfitableOrders < CountOrder && (TimeCurrent()-lastOrderTime>(1*3600)))
   {
      // нет ни одного открытого ордера
      // на всякий случай проверим, если у нас свободные деньги на счету?
      // значение 1000 взято для примера, обычно можно открыть 1 лот
      if (AccountFreeMargin() < (1000*Lots))
      {
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);  
      }
      
      // проверяем на возможность встать в длинную позицию (BUY)
      // Условие входа в длинную позицию:
      // MACD ниже нуля, идет снизу вверх, а его сверху вниз пересекает сигнальная линия.
      if(MacdCurrent < 0 && MacdCurrent > SignalCurrent && 
         MacdPrevious < SignalPrevious &&
         MathAbs(MacdCurrent) > (MACDOpenLevel*Point) && 
         MaCurrent > MaPrevious)
      {
         realStopLoss = 0;
         if (StopLoss > 0)
            realStopLoss = Ask-StopLoss*Point;
         
         realTakeProfit = 0;
         if (TakeProfit > 0)
            realTakeProfit = Ask+TakeProfit*Point;
            
         ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, 
                            realStopLoss,
                            realTakeProfit,
                            "macd sample",
                            16384, 0, Green);
         if(ticket>0)
         {
            if (OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
               Print("BUY order opened : ",OrderOpenPrice());
               lastOrderTime = TimeCurrent();
            }
         }
         else
            Print("Error opening BUY order : ",GetLastError()); 
         return(0); 
      }
            
      // проверяем на возможность встать в короткую позицию (SELL)
      //Условие входа в короткую позицию: MACD выше нуля, идет сверху вниз, а его снизу вверх пересекает сигнальная линия.
      if(MacdCurrent>0 && MacdCurrent < SignalCurrent &&
         MacdPrevious>SignalPrevious && 
         MacdCurrent>(MACDOpenLevel*Point) && 
         MaCurrent < MaPrevious)
      {
         realStopLoss = 0;
         if (StopLoss > 0)
            realStopLoss = Bid+StopLoss*Point;
         
         realTakeProfit = 0;
         if (TakeProfit > 0)
            realTakeProfit = Bid-TakeProfit*Point;
         
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,
                          realStopLoss,
                          realTakeProfit,
                          "macd sample",
                          16384,0,Red);
         if(ticket>0) {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
               Print("SELL order opened : ",OrderOpenPrice());
               lastOrderTime = TimeCurrent();
            }
         }
         else
            Print("Error opening SELL order : ",GetLastError()); 
         return(0); 
      }
   }   

   // переходим к важной части эксперта - контролю открытых позиций
   // 'важно правильно войти в рынок, но выйти - еще важнее...'
   for(i=0;i<total;i++)
   {
      //Print("Order Number: ", i);
      
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        
      if (OrderType()<=OP_SELL &&   // это открытая позиция? OP_BUY или OP_SELL 
          OrderSymbol()==Symbol())  // инструмент совпадает?
      {
         if(OrderType()==OP_BUY)   // открыта длинная позиция
         {
            //if(TimeCurrent()-OrderOpenTime()>24*3600) {
            //   OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // закрываем позицию   
            //}
            
            // проверим, может уже пора закрываться?
            if(MacdCurrent>0 && MacdCurrent<SignalCurrent &&
               MacdPrevious>SignalPrevious &&
               MacdCurrent>(MACDCloseLevel*Point) &&
               MaCurrent < MaPrevious)
            {
               //OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // закрываем позицию
               //return(0); // выходим
            }
               
            // проверим - может можно/нужно уже трейлинг стоп ставить?
            if(TrailingStop>0)  
            {                 
               if(Bid-OrderOpenPrice()>Point*TrailingStop)
               {
                  if(OrderStopLoss()<Bid-Point*TrailingStop)
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,
                                OrderTakeProfit(),0,Green);
                     return(0);
                  }
               }
            }
         }
         else if(OrderType()==OP_SELL) // иначе это короткая позиция
         {
            //if(TimeCurrent()-OrderOpenTime()>24*3600) {
            //   OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // закрываем позицию   
            //}
            
            // проверим, может уже пора закрываться?
            if(MacdCurrent<0 && MacdCurrent>SignalCurrent &&
               MacdPrevious<SignalPrevious &&
               MathAbs(MacdCurrent)>(MACDCloseLevel*Point) &&
               MaCurrent > MaPrevious)
            {
               //OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // закрываем позицию
               //return(0); // выходим
            }
               
            // проверим - может можно/нужно уже трейлинг стоп ставить?
            if(TrailingStop>0)  
            {                 
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
               {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,
                                OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
            }
         }           
      }
   }
   return(0);
}


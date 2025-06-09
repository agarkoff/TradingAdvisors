extern int CountOrder=4;

extern double TakeProfit = 100;
extern double StopLoss = 0;
extern double Lots = 0.01;
extern double TrailingStop = 50;
extern double MACDOpenLevel = 3;
extern double MACDCloseLevel = 2;
extern double MATrendPeriod = 26;

static datetime preOrderTime = 0;

int start()
{
  int i, ticket, total;
  
  double absStopLoss, absTakeProfit;
   
  double MACDCurrent =    iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
  double MACDPrevious =   iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
  double SignalCurrent =  iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
  double SignalPrevious = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
  double MACurrent =      iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,0);
  double MAPrevious =     iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,1);
 
  total = OrdersTotal();
   
  //Блок учёта количества прибыльных открытых ордеров.
   
  int countProfitableOrders;
   
  for(i=0; i<total; i++)
  {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    double profit=OrderProfit();
    if (profit>0)
    {
      countProfitableOrders++;
    }
  }
   
  //Блок управления увелечением лота.
   
  if (AccountFreeMargin() > (20000*Lots))
  {
    Lots = Lots + 0.01;
  }
   
  //Блок управления открытием ордеров.
   
  if (countProfitableOrders < CountOrder && (TimeCurrent()-preOrderTime>(60)))
  {
     
    //Блок проверки наличия свободной маржи.
     
    if (AccountFreeMargin() < (1000*Lots))
    {
      Print("Free Margin is absent. Account Free Margin: ", AccountFreeMargin());
      return(0);  
    }
      
    //Блок управления открытием ордеров на покупку.
    //Индикатор MACD находится ниже нуля, идёт снизу вверх, а его сверху вниз пересекает сигнальная линия.
      
    if (MACDCurrent < 0 &&
        MACDCurrent > SignalCurrent && 
        MACDPrevious < SignalPrevious &&
        MathAbs(MACDCurrent) > (MACDOpenLevel*Point))// && 
        //MACurrent > MAPrevious)
    {
      absStopLoss = 0;
      if (StopLoss > 0)
      {
        absStopLoss = Bid-StopLoss*Point;
      }
         
      absTakeProfit = 0;
      if (TakeProfit > 0)
      {
        absTakeProfit = Ask+TakeProfit*Point;
      }   
      
      //Блок открытия ордера на покупку.
         
      ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, absStopLoss, absTakeProfit, "Buy Order Done!", 16384, 0, Green);
      
      if (ticket>0)
      {
        if (OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
        {
          Print("Buy Order Done: ", OrderOpenPrice());
          preOrderTime = TimeCurrent();
        }
      }
    }
      
    //Блок управления открытием ордеров на продажу.  
    //Индикатор MACD находится выше нуля, идёт сверху вниз, а его снизу вверх пересекает сигнальная линия.
    
    if (MACDCurrent>0 &&
        MACDCurrent < SignalCurrent &&
        MACDPrevious > SignalPrevious && 
        MACDCurrent > (MACDOpenLevel*Point)) //&& 
        //MACurrent < MAPrevious)
    {
      absStopLoss = 0;
      if (StopLoss > 0)
      {
        absStopLoss = Ask+StopLoss*Point;
      } 
        
      absTakeProfit = 0;
      if (TakeProfit > 0)
      {
        absTakeProfit = Bid-TakeProfit*Point;
      }
      
      //Блок открытия ордера на продажу.
         
      ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3, absStopLoss, absTakeProfit, "Sell Order Done!", 16384, 0, Red);
      
      if(ticket>0)
      {
        if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
        {
          Print("Sell Order Done: ", OrderOpenPrice());
          preOrderTime = TimeCurrent();
        }
      }
    }   
  }
  
  //Блок активизации трейлинг-стопа для открытых ордеров.
  
  for (i=0; i<total; i++)
  {
    OrderSelect (i, SELECT_BY_POS, MODE_TRADES);
    if (OrderType()==OP_BUY && OrderSymbol()==Symbol())
    {
      if (TrailingStop>0)
      {                 
        if (Bid-OrderOpenPrice() > Point*TrailingStop)
        {
          if (OrderStopLoss() < Bid-Point*TrailingStop)
          {
            OrderModify(OrderTicket(), OrderOpenPrice(), Bid-Point*TrailingStop, OrderTakeProfit(), 0, Green);
            return(0);
          }
        }
      }
    }
    else if (OrderType()==OP_SELL && OrderSymbol()==Symbol())
    {
      if (TrailingStop>0)  
      {                 
        if ((OrderOpenPrice()-Ask) > (Point*TrailingStop))
        {
          if ((OrderStopLoss() > (Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
          {
            OrderModify(OrderTicket(), OrderOpenPrice(), Ask+Point*TrailingStop, OrderTakeProfit(), 0, Red);
            return(0);
          }
        }
      }
    }          
  }
}
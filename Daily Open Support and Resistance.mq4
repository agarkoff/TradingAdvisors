//+------------------------------------------------------------------+
//|                            Daily Open Support and Resistance.mq4 |
//|                                  Copyright © 2011, Nicky W. Lime |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nicky W. Lime"
#property link      ""

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
    bool UpBar = iOpen(Symbol(),PERIOD_D1,1) < iClose(Symbol(),PERIOD_D1,1);
    bool DownBar = iOpen(Symbol(),PERIOD_D1,1) > iClose(Symbol(),PERIOD_D1,1);
    bool Accept;
    
    static double Support;
    static double Resistance;
    
    if (UpBar && Support != iOpen(Symbol(),PERIOD_D1,1))
    {
      Print("Восходящая свеча и саппорт чист!");
      Support = iOpen(Symbol(),PERIOD_D1,1);
      Print("Саппорт: ", Support);
      Resistance = iHigh(Symbol(),PERIOD_D1,1);
      Print("Резистенс: ", Resistance);
      Accept = true;
    }
  
    else if (DownBar && Support != iLow(Symbol(),PERIOD_D1,1))
    {
      Print("Нисходящая свеча и саппорт чист!");
      Support = iLow(Symbol(),PERIOD_D1,1);
      Print("Саппорт: ", Support);
      Resistance = iOpen(Symbol(),PERIOD_D1,1);
      Print("Резистенс: ", Resistance);
      Accept = true;
    }
    
    if (OrdersTotal() == 0 && Accept)
    {
      if (iClose(Symbol(),PERIOD_M5,1) > Resistance)
      {
        Print("Цена закрытия 5-минутной свечи: ", iClose(Symbol(),PERIOD_M5,1));      
        OrderSend(Symbol(),OP_BUY,0.01,Ask,0,Support,Ask+0.005);
        Accept = false;
      }
      
      else if (iClose(Symbol(),PERIOD_M5,1) < Support)
      {
        Print("Цена закрытия 5-минутной свечи: ", iClose(Symbol(),PERIOD_M5,1));
        OrderSend(Symbol(),OP_SELL,0.01,Bid,0,Resistance,Bid-0.005);
        Accept = false;
      }
    }
//----
   return(0);
  }
//+------------------------------------------------------------------+
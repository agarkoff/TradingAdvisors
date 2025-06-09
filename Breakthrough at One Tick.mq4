//+------------------------------------------------------------------+
//|                                     Breakthrough at One Tick.mq4 |
//|                                  Copyright © 2011, Nicky W. Lime |
//|                                              http://nikbank.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nicky W. Lime"
#property link      "http://nikbank.com/"

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
extern int TakeProfit = 200;
extern int StopLoss = 100;
extern int BreakThrough = 50;

int start()
  {
//----
    static double ShiftAsk = 0;

    if (ShiftAsk != 0)
    {
      if (OrdersTotal() == 0 && Ask - ShiftAsk >= BreakThrough*Point)
      {
        OrderSend(Symbol(),OP_BUY,0.01,Ask,3,Ask-StopLoss*Point,Ask+TakeProfit*Point,"Hi!",0,0,Green);
      }

      if (OrdersTotal() == 0 && ShiftAsk - Ask >= BreakThrough*Point)
      {
        OrderSend(Symbol(),OP_SELL,0.01,Bid,3,Bid+StopLoss*Point,Bid-TakeProfit*Point,"Hi!",0,0,Green);
      }
    }

    ShiftAsk = Ask;
//----
    return(0);
  }
//+------------------------------------------------------------------+
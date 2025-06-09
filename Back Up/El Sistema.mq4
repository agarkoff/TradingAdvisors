//+------------------------------------------------------------------+
//|                                                   El Sistema.mq4 |
//|                                  Copyright © 2010, Nicky W. Lime |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nicky W. Lime"
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
static datetime Delay;

int start()
  {
//----
  double Jump = 0.001;
  double Lots = 0.01;
  double ProfitLevel = 0.0003;
    
  //Lots = MathFloor(AccountBalance()/2.8) / 100;
  
  if (iClose(Symbol(),0,0) - iOpen(Symbol(),0,0) >= Jump && OrdersTotal() <= 2 && TimeCurrent() - Delay >= 60)
  {
    OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"Я купил!",16384,0,Green);
  }
  
  if (iOpen(Symbol(),0,0) - iClose(Symbol(),0,0) >= Jump && OrdersTotal() <= 2 && TimeCurrent() - Delay >= 60)
  {
    OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"Я продал!",16384,0,Green);
  }
  
  if (OrderSelect(0, SELECT_BY_POS, MODE_TRADES))
  {
    if (OrderType() == OP_BUY && Bid >= OrderOpenPrice() + ProfitLevel)
    {
      OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);
      Delay = TimeCurrent();
    }
  
    if (OrderType() == OP_SELL && Ask <= OrderOpenPrice() - ProfitLevel)
    {
      OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet);
      Delay = TimeCurrent();
    }
  }
//----
   return(0);
  }
//+------------------------------------------------------------------+
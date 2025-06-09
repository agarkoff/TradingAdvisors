//+------------------------------------------------------------------+
//|                                                Micro Scalper.mq4 |
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
double OpenBid;
double OpenAsk;

int start()
  {
//----
  bool BarDownOne = iClose(Symbol(),0,1) < iOpen(Symbol(),0,1);
  bool BarDownTwo = iClose(Symbol(),0,2) < iOpen(Symbol(),0,2);
  bool BarUpOne = iClose(Symbol(),0,1) > iOpen(Symbol(),0,1);
  bool BarUpTwo = iClose(Symbol(),0,2) > iOpen(Symbol(),0,2);
  
  double BodyOne = MathAbs(iOpen(Symbol(),0,1) - iClose(Symbol(),0,1));
  double BodyCur = MathAbs(iOpen(Symbol(),0,0) - iClose(Symbol(),0,0));
  double Lots = 0.37;
  double ProfitLevel = 0.0003;
  
  Lots = MathFloor(AccountBalance()/2.7) / 100;
  
  if (OrdersTotal() == 0 && BarDownOne && BodyOne < BodyCur)
  {
    OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"Я продал!",16384,0,Green);
    OpenBid = Bid;
  }

  if (OrdersTotal() == 0 && BarUpOne && BodyOne < BodyCur)
  {
    OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"Я купил!",16384,0,Green);
    OpenAsk = Ask;
  }
  
  OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
  
  if (OrderType() == OP_SELL && Ask <= OpenBid - ProfitLevel)
  {
    OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet);
  }
  
  if (OrderType() == OP_BUY && Bid >= OpenAsk + ProfitLevel)
  {
    OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);
  }
//----
   return(0);
  }
//+------------------------------------------------------------------+
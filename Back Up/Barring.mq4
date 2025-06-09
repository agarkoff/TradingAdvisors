//+------------------------------------------------------------------+
//|                                                     Scalping.mq4 |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nciky W. Lime"
#property link      "http://www.nikbank.ru/"

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
static datetime OrderTime = 0;
bool BarUp = iClose(Symbol(),0,1) > iOpen(Symbol(),0,1);

int start()
  {
//----

  

  if (OrdersTotal() == 0)
  {
    if (BarUp && (TimeCurrent()-OrderTime>60))
    {
      OrderSend(Symbol(),OP_BUY,0.01,Ask,3,0,0,"Я купил!",16384,0,Green);
    }
    else if (iClose(Symbol(),0,1) < iOpen(Symbol(),0,1) && (TimeCurrent()-OrderTime>60))
    { 
      OrderSend(Symbol(),OP_SELL,0.01,Bid,3,0,0,"Я продал!",16384,0,Green);
    }
  }
  
  OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
  
  if (OrderType() == OP_BUY && iClose(Symbol(),0,1) < iOpen(Symbol(),0,1))
  {
    OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);
    OrderTime = TimeCurrent();
  }
  else if (OrderType() == OP_SELL && iClose(Symbol(),0,1) > iOpen(Symbol(),0,1))
  {
    OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet);
    OrderTime = TimeCurrent();
  }
//----
    return(0);
  }
//+------------------------------------------------------------------+
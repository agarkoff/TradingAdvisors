//+------------------------------------------------------------------+
//|                                                   Absorption.mq4 |
//|                                  Copyright © 2010, Nicky W. Lime |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nicky W. Lime"
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
int PreviousMinute;

int start()
{
//----
  Print("Minute: ", Minute());
  Print("Previous minute: ", PreviousMinute);
  
  if (Minute() != PreviousMinute)
  {
    if (OrdersTotal() == 0 && iClose(Symbol(),0,2) < iOpen(Symbol(),0,2) && iClose(Symbol(),0,1) > iOpen(Symbol(),0,2))
    {OrderSend(Symbol(),OP_BUY,0.01,Ask,3,Bid-30*Point,Ask+48*Point,"Bought!",16384,0,Green);}

    if (OrdersTotal() == 0 && iClose(Symbol(),0,2) > iOpen(Symbol(),0,2) && iClose(Symbol(),0,1) < iOpen(Symbol(),0,2))
    {OrderSend(Symbol(),OP_SELL,0.01,Bid,3,Ask+30*Point,Bid-48*Point,"Sold!",16384,0,Green);}
    
    PreviousMinute = Minute();
  }
//----
  return(0);
}
//+------------------------------------------------------------------+
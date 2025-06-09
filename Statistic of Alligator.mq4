//+------------------------------------------------------------------+
//|                                       Statistic of Alligator.mq4 |
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
int start()
  {
//----
  double Difference;
  
  static double Statistics;
  
  int TakeProfit = 50;
  int StopLoss = 50;
  
  if (Close[1] > iAlligator(Symbol(),0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1))
  {
    Difference = Close[1] - iAlligator(Symbol(),0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
  }
  
  if (Close[1] < iAlligator(Symbol(),0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1))
  {
    Difference = Close[1] - iAlligator(Symbol(),0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
  }
  
  if (MathAbs(Difference) > Statistics)
  {
    Statistics = MathAbs(Difference);
    Print("Biggest Difference: ", Statistics, ".");
  }
  
  if (OrdersTotal() > 0)
  {
    return(0);
  }
  
  if (Difference > 0.007)
  {
    OrderSend(Symbol(),OP_SELL,0.01,Bid,0,Bid+StopLoss*Point,Bid-TakeProfit*Point,0,0,0,0);
  }
  
  if (Difference < -0.007)
  {
    OrderSend(Symbol(),OP_BUY,0.01,Ask,0,Ask-StopLoss*Point,Ask+TakeProfit*Point,0,0,0,0);
  }
//----
    return(0);
  }
//+------------------------------------------------------------------+
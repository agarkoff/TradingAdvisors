//+------------------------------------------------------------------+
//|                                                   Martingale.mq4 |
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
  static double Lots = 0.01;
  static int Count;
  static int Ticket;
  static int n = 10;
  
  if (Minute() != 0 || OrdersTotal() != 0)
  {
    return(0);
  }
  
  OrderSelect(Ticket,SELECT_BY_TICKET);
  
  if (OrderCloseTime() > 0)
  {
    Print(Ticket);   
   
    if (OrderProfit() > 0)
    {
      Count = 0;
      Lots = 0.01;
    }
    
    else
    {
      Count++;
    }
  }
  
  if (Count >= n)
  {
    Lots = Lots * 40;
  }

  if (Minute() == 0 && OrdersTotal() == 0)
  {
    if (MathMod(MathRand(), 2) == 0)
    {
      Ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,0,Ask-200*Point,Ask+200*Point,"Bought!",0,0,Green);
    }
    
    else
    {
      Ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,0,Bid+200*Point,Bid-200*Point,"Sold!",0,0,Red);
    }
  }
//----
    return(0);
  }
//+------------------------------------------------------------------+
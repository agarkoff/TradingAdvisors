//+------------------------------------------------------------------+
//|                             Take-Profit and Stop-Loss Setter.mq4 |
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
int start()
  {
//----
    int TakeProfit = 200;
    int StopLoss = 200;

    for (int i = 0; i < OrdersTotal(); i++)
    {
      OrderSelect(i,SELECT_BY_POS, MODE_TRADES);

      if (OrderStopLoss() == 0 && OrderTakeProfit() == 0)
      {
        if (OrderType() == OP_BUY)
        {
          OrderModify(OrderTicket(), 0, OrderOpenPrice() - StopLoss*Point, OrderOpenPrice() + TakeProfit*Point, 0);
        }

        if (OrderType() == OP_SELL)
        {
          OrderModify(OrderTicket(), 0, OrderOpenPrice() + StopLoss*Point, OrderOpenPrice() - TakeProfit*Point, 0);
        }
      }
    }
//----
    return(0);
  }
//+------------------------------------------------------------------+
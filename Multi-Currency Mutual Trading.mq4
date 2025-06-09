//+------------------------------------------------------------------+
//|                                Multi-Currency Mutual Trading.mq4 |
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
extern double Lots = 0.01;

int start()
  {
//----
    double OpenPrice;
    double ClosePrice;

    static double Drawdown;

    static string Currencies[] = {"EURUSD", "GBPUSD", "USDCAD", "USDCHF", "USDJPY"};

    if (OrdersTotal() == 0)
    {
      for (int i = 0; i < ArraySize(Currencies); i++)
      {
        OpenPrice = MarketInfo(Currencies[i], MODE_ASK);
        OrderSend(Currencies[i], OP_BUY, Lots, OpenPrice, 0, 0, 0, "Bought!", 0, 0, Green);
      }
    }

    if (AccountProfit() >= 2)
    {
      while (OrdersTotal() > 0)
      {
        OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
        ClosePrice = MarketInfo(OrderSymbol(), MODE_BID);
        OrderClose(OrderTicket(), Lots, ClosePrice, 0, Blue);
        Print("Error of ", OrderSymbol(), ": №", GetLastError(), ".");
      }
    }

    if (AccountProfit() < Drawdown)
    {
      Drawdown = AccountProfit();
      Print("Просадка: ", Drawdown, " $.");
      //FileOpen("Drawdown.csv", FILE_READ|FILE_WRITE, ';');
      //FileRead()
    }
//----
    return(0);
  }
//+------------------------------------------------------------------+
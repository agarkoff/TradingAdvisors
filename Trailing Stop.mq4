//+------------------------------------------------------------------+
//|                                                Trailing Stop.mq4 |
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
    static bool StepOne;
    static bool StepTwo;

    int FirstStopLoss = 50;
    int BreakevenStopLoss = 10;
    int NextStopLoss = 20;
    
    if (OrdersTotal() == 1)
    {
      OrderSelect(0,SELECT_BY_POS, MODE_TRADES);

      // Блок задачи первоначального стоп-лосса. ----------------------------------------------------------------------------------------------------

      if (OrderStopLoss() == 0)
      {
        StepOne = False;
        StepTwo = False;
        
        Print("Hello! Is It a New Order?");
        
        if (OrderType() == OP_BUY)
        {
          if (OrderModify(OrderTicket(), 0, OrderOpenPrice() - FirstStopLoss*Point, 0, 0, Blue))
          {
            StepOne = True;
            Print("Step One is Done!");
          }
          
          else
          {
            Print("Step One Error: #", GetLastError(), ".");
          }
        }

        if (OrderType() == OP_SELL)
        {
          if (OrderModify(OrderTicket(), 0, OrderOpenPrice() + FirstStopLoss*Point, 0, 0, Blue))
          {
            StepOne = True;
            Print("Step One is Done!");
          }
          
          else
          {
            Print("Step One Error: #", GetLastError(), ".");
          }
        }
      }

      // Блок установления стоп-лосса на безубыточный уровень. --------------------------------------------------------------------------------------

      if (StepOne)
      {
        if (OrderType() == OP_BUY && Bid - OrderOpenPrice() >= BreakevenStopLoss*Point)
        {
          if (OrderModify(OrderTicket(), 0, OrderOpenPrice(), 0, 0, Blue))
          {
            StepOne = False;
            StepTwo = True;
            Print("Step Two is Done!");
          }
          
          else
          {
            Print("Step Two Error: #", GetLastError(), ".");
          }
        }

        if (OrderType() == OP_SELL && OrderOpenPrice() - Ask >= BreakevenStopLoss*Point)
        {
          if (OrderModify(OrderTicket(), 0, OrderOpenPrice(), 0, 0, Blue))
          {
            StepOne = False;
            StepTwo = True;
            Print("Step Two is Done!");
          }
          
          else
          {
            Print("Step Two Error: #", GetLastError(), ".");
          }
        }
      }

      // Блок последующей актуализации стоп-лосса. --------------------------------------------------------------------------------------------------

      OrderSelect(0,SELECT_BY_POS, MODE_TRADES);

      if (StepTwo)
      {
        if (OrderType() == OP_BUY && Bid - OrderStopLoss() >= NextStopLoss*Point)
        {
          Print("Bid Price: ", DoubleToStr(Bid, 5), ".");
          
          if (OrderModify(OrderTicket(), 0, Bid - (NextStopLoss - 5)*Point, 0, 0, Blue) == False)
          {
            Print("Step Three Error: #", GetLastError(), ".");
          }
        }

        if (OrderType() == OP_SELL && OrderStopLoss() - Ask >= NextStopLoss*Point)
        {
          Print("Ask Price: ", DoubleToStr(Ask, 5), ".");
          
          if (OrderModify(OrderTicket(), 0, Ask + (NextStopLoss - 5)*Point, 0, 0, Blue) == False)
          {
            Print("Step Three Error: #", GetLastError(), ".");
          }
        }
      }
    }
//----
    return(0);
  }
//+------------------------------------------------------------------+
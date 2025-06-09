//+-----------------------------------------------------------------------------------------------------------------------+
//|                                                                                                           Scalper.mq4 |
//|                                                                                       Copyright © 2010, Nicky W. Lime |
//|                                                                                                                       |
//+-----------------------------------------------------------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nicky W. Lime"
#property link      "http://www.nikbank.ru/"

extern bool BuyOrder = false;

extern double TakeProfit = 0;
extern double StopLoss = 0;

extern int OrdersMaxAmount = 0;
extern int ProfitOrdersMaxAmount = 0;

int start()
{
  double absTakeProfit = 0;
  double absStopLoss = 0;
  
  int i;
  int ProfitOrdersAmount = 0;
  
  static datetime PreOrderTime = 0;
  
  for(i=0; i < OrdersTotal(); i++)
  {
    OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    if (OrderProfit() > 0) {ProfitOrdersAmount++;}
  }
  
  if (OrdersTotal() < OrdersMaxAmount && BuyOrder == false && TimeCurrent()-PreOrderTime > 300)
  {
    if (TakeProfit != 0){absTakeProfit = Ask+TakeProfit*Point;}
    if (StopLoss != 0){absStopLoss = Bid-StopLoss*Point;}
  
    OrderSend(Symbol(),OP_BUY,0.01,Ask,0,absStopLoss,absTakeProfit,"Bought!",16384,0,Green);
    BuyOrder = true;
    PreOrderTime = TimeCurrent();
  }

  if (OrdersTotal() < OrdersMaxAmount && BuyOrder == true && TimeCurrent()-PreOrderTime > 300)
  {
    if (TakeProfit != 0){absTakeProfit = Bid-TakeProfit*Point;}
    if (StopLoss != 0){absStopLoss = Ask+StopLoss*Point;}

    OrderSend(Symbol(),OP_SELL,0.01,Bid,0,absStopLoss,absTakeProfit,"Sold!",16384,0,Green);
    BuyOrder = false;
    PreOrderTime = TimeCurrent();
  }
}
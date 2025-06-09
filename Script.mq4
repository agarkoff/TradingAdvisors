//+------------------------------------------------------------------+
//|                                                       Script.mq4 |
//|                                  Copyright © 2010, Nicky W. Lime |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nicky W. Lime"
#property link      "http://nikbank.com/"

int start()
    
  {
    int EURUSD = 1;
    int GBPUSD = 1;
    int USDCAD = 1;
    int USDCHF = 1;
    int USDJPY = 1;
    
    double Lots = 0.01;
    double BrkThrgh = 100;
    
    if (EURUSD == 1)
    {
      double AskEURUSD = MarketInfo("EURUSD",MODE_ASK);
      double BidEURUSD = MarketInfo("EURUSD",MODE_BID);
      double PntEURUSD = MarketInfo("EURUSD",MODE_POINT);
      
      OrderSend("EURUSD",OP_BUYSTOP,Lots,AskEURUSD+BrkThrgh*PntEURUSD,0,0,0,"Hi!",16384,0,Green);
      OrderSend("EURUSD",OP_SELLSTOP,Lots,BidEURUSD-BrkThrgh*PntEURUSD,0,0,0,"Hi!",16384,0,Green);
    }
    
    if (GBPUSD == 1)
    {
      double AskGBPUSD = MarketInfo("GBPUSD",MODE_ASK);
      double BidGBPUSD = MarketInfo("GBPUSD",MODE_BID);
      double PntGBPUSD = MarketInfo("GBPUSD",MODE_POINT);
      
      OrderSend("GBPUSD",OP_BUYSTOP,Lots,AskGBPUSD+BrkThrgh*PntGBPUSD,0,0,0,"Hi!",16384,0,Green);
      OrderSend("GBPUSD",OP_SELLSTOP,Lots,BidGBPUSD-BrkThrgh*PntGBPUSD,0,0,0,"Hi!",16384,0,Green);
    }
    
    if (USDCAD == 1)
    {
      double AskUSDCAD = MarketInfo("USDCAD",MODE_ASK);
      double BidUSDCAD = MarketInfo("USDCAD",MODE_BID);
      double PntUSDCAD = MarketInfo("USDCAD",MODE_POINT);
    
      OrderSend("USDCAD",OP_BUYSTOP,Lots,AskUSDCAD+BrkThrgh*PntUSDCAD,0,0,0,"Hi!",16384,0,Green);
      OrderSend("USDCAD",OP_SELLSTOP,Lots,BidUSDCAD-BrkThrgh*PntUSDCAD,0,0,0,"Hi!",16384,0,Green);
    }
    
    if (USDCHF == 1)
    {
      double AskUSDCHF = MarketInfo("USDCHF",MODE_ASK);
      double BidUSDCHF = MarketInfo("USDCHF",MODE_BID);
      double PntUSDCHF = MarketInfo("USDCHF",MODE_POINT);
    
      OrderSend("USDCHF",OP_BUYSTOP,Lots,AskUSDCHF+BrkThrgh*PntUSDCHF,0,0,0,"Hi!",16384,0,Green);
      OrderSend("USDCHF",OP_SELLSTOP,Lots,BidUSDCHF-BrkThrgh*PntUSDCHF,0,0,0,"Hi!",16384,0,Green);
    }
    
    if (USDJPY == 1)
    {
      double AskUSDJPY = MarketInfo("USDJPY",MODE_ASK);
      double BidUSDJPY = MarketInfo("USDJPY",MODE_BID);
      double PntUSDJPY = MarketInfo("USDJPY",MODE_POINT);
    
      OrderSend("USDJPY",OP_BUYSTOP,Lots,AskUSDJPY+BrkThrgh*PntUSDJPY,0,0,0,"Hi!",16384,0,Green);
      OrderSend("USDJPY",OP_SELLSTOP,Lots,BidUSDJPY-BrkThrgh*PntUSDJPY,0,0,0,"Hi!",16384,0,Green);
    }
    
    Print(GetLastError());
  }
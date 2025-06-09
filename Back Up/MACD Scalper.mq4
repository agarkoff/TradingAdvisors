extern double TakeProfit = 20;
extern double StopLoss = 0;
extern double Lots = 0.01;
extern double MACDOpenLevel=3;
extern double MACDCloseLevel=2;
extern double MATrendPeriod=26;
extern double MinAbsMACD = 0.00010;
extern double MinMACDDeviation = 0.08;
extern double MinMACDRejectDeviation = 0.1;

static int TimeFrameArray[] = {0,
                               PERIOD_M1,    //1
                               PERIOD_M5,    //2
                               PERIOD_M15,   //3
                               PERIOD_M30,   //4
                               PERIOD_H1,    //5
                               PERIOD_H4,    //6
                               PERIOD_D1,    //7
                               PERIOD_W1,    //8
                               PERIOD_MN1,   //9
                              };
extern int TimeFrameIndex = 0;

static datetime preOrderTime = 0;
static double preUpgradedDeposit;

static int countRejectSignal = 0;
static int currentTicket = 0;

int init() {
  preUpgradedDeposit = AccountBalance();
}

int start()
{
  int i, ticket, total;
  
  double absStopLoss, absTakeProfit;
   
  double MACDCurrent=    iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,0);
  double MACDPrevious=   iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,1);
  double SignalCurrent=  iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
  double SignalPrevious= iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
  double MACurrent=      iMA(NULL,TimeFrameArray[TimeFrameIndex],MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,0);
  double MAPrevious=     iMA(NULL,TimeFrameArray[TimeFrameIndex],MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,1);
 
  total = OrdersTotal();
   
  //���� ���������� ����������� ����.
  if (AccountFreeMargin() > 3*preUpgradedDeposit)
  {
    Lots = Lots * 2;
    preUpgradedDeposit = AccountBalance();
    Print("��� �������� � ��� ����; Lots=", Lots, "; AccountFreeMargin=", AccountFreeMargin());
  }
   
  // ���������, ���������� �� ��� ���� ������  
  bool allowTrade = true;
  if (currentTicket != 0) {
    for (i = 0; i < OrdersTotal(); i++) {
      OrderSelect (i, SELECT_BY_POS, MODE_TRADES);
      int t = OrderTicket();
      if (t == currentTicket) {
          allowTrade = false;
      }
    }
  }
  if (allowTrade) {
    currentTicket = 0;
  }
  
  //���� ���������� ��������� �������.
   
  if (allowTrade)
  {
     
    //���� �������� ������� ��������� �����.
     
    if (AccountFreeMargin() < (1000*Lots))
    {
      Print("Free Margin is absent. Account Free Margin: ", AccountFreeMargin());
      return(0);  
    }
      
    //���� ���������� ��������� ������� �� �������.
    //��������� MACD ��������� ���� ����, ��� ����� �����, � ��� ������ ���� ���������� ���������� �����.
      
    if (MACDCurrent < 0 &&
        MACDCurrent > SignalCurrent && 
        MACDPrevious < SignalPrevious &&
        MathAbs(MACDCurrent) > (MACDOpenLevel*Point) && 
        //MACurrent > MAPrevious &&
        MathAbs(MACDCurrent) > MinAbsMACD)
    {
      if (!checkEvennessMACD()) {
        absStopLoss = 0;
        if (StopLoss > 0)
        {
          absStopLoss = Bid-StopLoss*Point;
        }
         
        absTakeProfit = 0;
        if (TakeProfit > 0)
        {
          absTakeProfit = Ask+TakeProfit*Point;
        }   
      
        //���� �������� ������ �� �������.
         
        ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, absStopLoss, absTakeProfit, "Buy Order Done!", 16384, 0, Green);
      
        if (ticket>0)
        {
          currentTicket = ticket;
          if (OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
          {
            Print("Buy Order Done: ", OrderOpenPrice());
            Print("���������� ������ = ", OrdersTotal());
            preOrderTime = TimeCurrent();
          }
        } else {
          Print("������ �� �������.");
        }
      } else {
        countRejectSignal++;
        Print("BUY ��������. MACD ������������; countRejectSignal=", countRejectSignal);
      }
    }
      
    //���� ���������� ��������� ������� �� �������.  
    //��������� MACD ��������� ���� ����, ��� ������ ����, � ��� ����� ����� ���������� ���������� �����.
    
    if (MACDCurrent>0 &&
        MACDCurrent < SignalCurrent &&
        MACDPrevious > SignalPrevious && 
        MACDCurrent > (MACDOpenLevel*Point) && 
        //MACurrent < MAPrevious &&
        MathAbs(MACDCurrent) > MinAbsMACD)
    {
      if (!checkEvennessMACD()) {
        absStopLoss = 0;
        if (StopLoss > 0)
        {
          absStopLoss = Ask+StopLoss*Point;
        } 
        
        absTakeProfit = 0;
        if (TakeProfit > 0)
        {
          absTakeProfit = Bid-TakeProfit*Point;
        }
      
        //���� �������� ������ �� �������.
         
        ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3, absStopLoss, absTakeProfit, "Sell Order Done!", 16384, 0, Red);
      
        if(ticket>0)
        {
          currentTicket = ticket;
          if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
          {
            Print("Sell Order Done: ", OrderOpenPrice());
            Print("���������� ������ = ", OrdersTotal());
            preOrderTime = TimeCurrent();
          }
        } else {
          Print("������ �� �������.");
        }
      } else {
        countRejectSignal++;
        Print("SELL ��������. MACD ��������������; countRejectSignal=", countRejectSignal);
      }   
    }
  }
  
  //���� �������� ������, � ������� ���������� ����� ����� � �����������.
  
  for (i=0; i<total; i++)
  {
    OrderSelect (i, SELECT_BY_POS, MODE_TRADES);
    if (OrderType()==OP_BUY && OrderSymbol()==Symbol() && currentTicket == OrderTicket() && TimeCurrent()-OrderOpenTime()>60) {
        MACDPrevious=   iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,0);
        SignalPrevious= iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
        if (SignalPrevious > MACDPrevious && MathAbs((SignalPrevious-MACDPrevious)/MACDPrevious) > MinMACDRejectDeviation) {
            OrderClose(OrderTicket(), Lots, Bid, 3, Yellow);
            Print("���������� ������ = ", OrdersTotal());
        }
    }
    else if (OrderType()==OP_SELL && OrderSymbol()==Symbol() && currentTicket == OrderTicket() && TimeCurrent()-OrderOpenTime()>60) {
        MACDPrevious=   iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,0);
        SignalPrevious= iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
        if (SignalPrevious < MACDPrevious && MathAbs((SignalPrevious-MACDPrevious)/MACDPrevious) > MinMACDRejectDeviation) {
            OrderClose(OrderTicket(), Lots, Ask, 3, Yellow);
            Print("���������� ������ = ", OrdersTotal());
        }
    }          
  }
}

// ���������� true, ���� MACD ������������.
bool checkEvennessMACD() {
    //return (false);
    double macd[3];
    macd[0] = iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,1);
    macd[1] = iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,2);
    macd[2] = iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,3);
    double maxMACD = max3(macd[0], macd[1], macd[2]);
    double deviations[3];
    for (int i = 0; i < 3; i++) {
        deviations[i] = MathAbs((macd[i]-maxMACD)/maxMACD);
        if (deviations[i] > MinMACDDeviation) {
            Print("deviation = ", deviations[i]);
            return (false);
        }
    }
    return (true);
}

double max3(double a1, double a2, double a3) {
    double a12Max = MathMax(a1, a2);
    return (MathMax(a12Max, a3));
}


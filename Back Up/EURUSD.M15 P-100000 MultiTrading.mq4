extern double TakeProfit = 1500;
extern double StopLoss = 200;
extern double Lots = 5;
extern double TrailingStop = 500;
extern double MACDOpenLevel = 3;
extern double MACDCloseLevel = 2;
extern double MATrendPeriod = 26;
extern int CountOrder = 4;

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

static datetime lastOrderTime = 0;

int start()
{
   //Print("START");
   
   // ��������� �������� ������
   // ����� �������������� ��� ������� �������� �� ���������� ������� �
   // ������������ ��������� �������� ������� ���������� (Lots, StopLoss,
   // TakeProfit, TrailingStop)
   // � ����� ������ ��������� ������ TakeProfit
   if (Bars < 100)
   {
      Print("bars less than 100");
      return(0);  
   }
   if(TakeProfit < 10)
   {
      //Print("TakeProfit less than 10");
      //return(0); // ��������� TakeProfit
   }

   int i, ticket, total;
   double realStopLoss, realTakeProfit;
   
   double MacdCurrent=   iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   double MacdPrevious=  iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double SignalCurrent= iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   double SignalPrevious=iMACD(NULL,TimeFrameArray[TimeFrameIndex],12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   double MaCurrent= iMA(NULL,TimeFrameArray[TimeFrameIndex],MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,0);
   double MaPrevious=iMA(NULL,TimeFrameArray[TimeFrameIndex],MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,1);
 
   // ������ ���� ������������ - � ����� ��������� �������� ��������?
   // ��������, ���� �� ����� �������� ������� ��� ������?
   total = OrdersTotal();
   
   int countProfitableOrders;
   
   for(i=0;i<total;i++)
   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      double profit=OrderProfit();
      //Print("Profit: ", profit);
      if (profit>0) {
         countProfitableOrders++;
      }
   }
   
      //Print(total);
   
   //if (AccountBalance() > 50000)
   //{
   //   Lots=5;
   //}
   
   if (countProfitableOrders < CountOrder && (TimeCurrent()-lastOrderTime>(1*3600)))
   {
      // ��� �� ������ ��������� ������
      // �� ������ ������ ��������, ���� � ��� ��������� ������ �� �����?
      // �������� 1000 ����� ��� �������, ������ ����� ������� 1 ���
      if (AccountFreeMargin() < (1000*Lots))
      {
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);  
      }
      
      // ��������� �� ����������� ������ � ������� ������� (BUY)
      // ������� ����� � ������� �������:
      // MACD ���� ����, ���� ����� �����, � ��� ������ ���� ���������� ���������� �����.
      if(MacdCurrent < 0 && MacdCurrent > SignalCurrent && 
         MacdPrevious < SignalPrevious &&
         MathAbs(MacdCurrent) > (MACDOpenLevel*Point) && 
         MaCurrent > MaPrevious)
      {
         realStopLoss = 0;
         if (StopLoss > 0)
            realStopLoss = Ask-StopLoss*Point;
         
         realTakeProfit = 0;
         if (TakeProfit > 0)
            realTakeProfit = Ask+TakeProfit*Point;
            
         ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, 
                            realStopLoss,
                            realTakeProfit,
                            "macd sample",
                            16384, 0, Green);
         if(ticket>0)
         {
            if (OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
               Print("BUY order opened : ",OrderOpenPrice());
               lastOrderTime = TimeCurrent();
            }
         }
         else
            Print("Error opening BUY order : ",GetLastError()); 
         return(0); 
      }
            
      // ��������� �� ����������� ������ � �������� ������� (SELL)
      //������� ����� � �������� �������: MACD ���� ����, ���� ������ ����, � ��� ����� ����� ���������� ���������� �����.
      if(MacdCurrent>0 && MacdCurrent < SignalCurrent &&
         MacdPrevious>SignalPrevious && 
         MacdCurrent>(MACDOpenLevel*Point) && 
         MaCurrent < MaPrevious)
      {
         realStopLoss = 0;
         if (StopLoss > 0)
            realStopLoss = Bid+StopLoss*Point;
         
         realTakeProfit = 0;
         if (TakeProfit > 0)
            realTakeProfit = Bid-TakeProfit*Point;
         
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,
                          realStopLoss,
                          realTakeProfit,
                          "macd sample",
                          16384,0,Red);
         if(ticket>0) {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
               Print("SELL order opened : ",OrderOpenPrice());
               lastOrderTime = TimeCurrent();
            }
         }
         else
            Print("Error opening SELL order : ",GetLastError()); 
         return(0); 
      }
   }   

   // ��������� � ������ ����� �������� - �������� �������� �������
   // '����� ��������� ����� � �����, �� ����� - ��� ������...'
   for(i=0;i<total;i++)
   {
      //Print("Order Number: ", i);
      
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        
      if (OrderType()<=OP_SELL &&   // ��� �������� �������? OP_BUY ��� OP_SELL 
          OrderSymbol()==Symbol())  // ���������� ���������?
      {
         if(OrderType()==OP_BUY)   // ������� ������� �������
         {
            //if(TimeCurrent()-OrderOpenTime()>24*3600) {
            //   OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // ��������� �������   
            //}
            
            // ��������, ����� ��� ���� �����������?
            if(MacdCurrent>0 && MacdCurrent<SignalCurrent &&
               MacdPrevious>SignalPrevious &&
               MacdCurrent>(MACDCloseLevel*Point) &&
               MaCurrent < MaPrevious)
            {
               //OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // ��������� �������
               //return(0); // �������
            }
               
            // �������� - ����� �����/����� ��� �������� ���� �������?
            if(TrailingStop>0)  
            {                 
               if(Bid-OrderOpenPrice()>Point*TrailingStop)
               {
                  if(OrderStopLoss()<Bid-Point*TrailingStop)
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,
                                OrderTakeProfit(),0,Green);
                     return(0);
                  }
               }
            }
         }
         else if(OrderType()==OP_SELL) // ����� ��� �������� �������
         {
            //if(TimeCurrent()-OrderOpenTime()>24*3600) {
            //   OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // ��������� �������   
            //}
            
            // ��������, ����� ��� ���� �����������?
            if(MacdCurrent<0 && MacdCurrent>SignalCurrent &&
               MacdPrevious<SignalPrevious &&
               MathAbs(MacdCurrent)>(MACDCloseLevel*Point) &&
               MaCurrent > MaPrevious)
            {
               //OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // ��������� �������
               //return(0); // �������
            }
               
            // �������� - ����� �����/����� ��� �������� ���� �������?
            if(TrailingStop>0)  
            {                 
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
               {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,
                                OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
            }
         }           
      }
   }
   return(0);
}


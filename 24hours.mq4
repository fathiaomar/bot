//+------------------------------------------------------------------+
//|                                                      24hours.mq4 |
//|                                       Copyright 2026, FathiaOmar |
//|                                   https://github.com/fathiaomar  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, FathiaOmar"
#property link      "https://github.com/fathiaomar/bot"
#property version   "2.10"
#property strict

//--- Input Parameters
input int      MagicNumber       = 240024;    // Unique EA Magic Number
input bool     UseDynamicLot     = true;      // Use Risk-Based Dynamic Lot Sizing
input double   RiskPercent       = 1.0;       // Risk Per Trade (% of Balance)
input double   FixedLotSize      = 0.05;      // Fallback Fixed Lot Size
input int      StopLossPips      = 30;        // Stop Loss (pips)
input int      TakeProfitPips    = 60;        // Take Profit (pips)
input int      MaxSpreadPips     = 3;         // Max Allowed Spread (pips)
input int      MaxOpenOrders     = 1;         // Max Concurrent Orders (per symbol)
input int      SlippagePips      = 3;         // Max Slippage (pips)

//--- Indicator Settings
input int      FastEMAPeriod     = 9;         // Fast EMA Period
input int      SlowEMAPeriod     = 21;        // Slow EMA Period
input int      RSIPeriod         = 14;        // RSI Period
input double   RSIBuyMin         = 50.0;      // Minimum RSI for Buy Confirmation
input double   RSISellMax        = 50.0;      // Maximum RSI for Sell Confirmation
input double   ProfitTargetUSD   = 100.0;     // Account Floating Profit Alert Target ($)

//--- Internal State
double   g_pipSize       = 0.0;
int      g_slippagePts   = 0;
datetime g_lastBarTime   = 0;
bool     g_targetAlerted = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(FastEMAPeriod >= SlowEMAPeriod)
     {
      Print("Error: FastEMAPeriod must be less than SlowEMAPeriod.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(RiskPercent <= 0.0 || RiskPercent > 10.0)
     {
      Print("Error: RiskPercent must be between 0.01 and 10.0.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   // Normalize pip size for 4-digit and 5-digit brokers
   int pipMultiplier = (Digits == 3 || Digits == 5) ? 10 : 1;
   g_pipSize     = Point * pipMultiplier;
   g_slippagePts = SlippagePips * pipMultiplier;
   g_lastBarTime = iTime(Symbol(), PERIOD_CURRENT, 0);

   Print("24hours EA initialized on ", Symbol(), " | PipSize=", DoubleToString(g_pipSize, Digits));
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("24hours EA stopped. Reason code: ", reason);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   CheckProfitTarget();

   // Evaluate entry signals once per newly closed candle
   datetime currentBarTime = iTime(Symbol(), PERIOD_CURRENT, 0);
   if(currentBarTime == g_lastBarTime)
      return;
   g_lastBarTime = currentBarTime;

   if(!IsTradingAllowedSafe())
      return;

   if(CountOpenOrders() >= MaxOpenOrders)
      return;

   // Read closed bar [1] and prior closed bar [2] indicators to avoid repainting
   double fastCurr = iMA(Symbol(), PERIOD_CURRENT, FastEMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   double fastPrev = iMA(Symbol(), PERIOD_CURRENT, FastEMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 2);
   double slowCurr = iMA(Symbol(), PERIOD_CURRENT, SlowEMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   double slowPrev = iMA(Symbol(), PERIOD_CURRENT, SlowEMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 2);
   double rsiCurr  = iRSI(Symbol(), PERIOD_CURRENT, RSIPeriod, PRICE_CLOSE, 1);

   bool bullishCross = (fastPrev <= slowPrev) && (fastCurr > slowCurr) && (rsiCurr >= RSIBuyMin);
   bool bearishCross = (fastPrev >= slowPrev) && (fastCurr < slowCurr) && (rsiCurr <= RSISellMax);

   if(bullishCross)
      OpenTrade(OP_BUY);
   else if(bearishCross)
      OpenTrade(OP_SELL);
  }

//+------------------------------------------------------------------+
//| Validate trade permissions and spread limits                     |
//+------------------------------------------------------------------+
bool IsTradingAllowedSafe()
  {
   if(!IsTradeAllowed() || IsTradeContextBusy())
      return(false);

   double currentSpreadPips = (Ask - Bid) / g_pipSize;
   if(currentSpreadPips > MaxSpreadPips)
     {
      Print("Spread too wide (", DoubleToString(currentSpreadPips, 1), " pips). Skipping bar.");
      return(false);
     }

   return(true);
  }

//+------------------------------------------------------------------+
//| Count open orders managed by this EA on the current symbol       |
//+------------------------------------------------------------------+
int CountOpenOrders()
  {
   int count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         count++;
     }
   return(count);
  }

//+------------------------------------------------------------------+
//| Calculate normalized lot size based on account risk percentage   |
//+------------------------------------------------------------------+
double CalculateLotSize()
  {
   double minLot  = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot  = MarketInfo(Symbol(), MODE_MAXLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);

   if(lotStep <= 0.0)
      lotStep = 0.01;

   double rawLots = FixedLotSize;

   if(UseDynamicLot && StopLossPips > 0)
     {
      double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
      double tickSize  = MarketInfo(Symbol(), MODE_TICKSIZE);

      if(tickValue > 0.0 && tickSize > 0.0)
        {
         double pipValuePerLot = tickValue * (g_pipSize / tickSize);
         double riskAmount     = AccountBalance() * (RiskPercent / 100.0);
         rawLots               = riskAmount / (StopLossPips * pipValuePerLot);
        }
     }

   double normalizedLots = MathFloor(rawLots / lotStep) * lotStep;
   normalizedLots = MathMax(minLot, MathMin(maxLot, normalizedLots));
   return(NormalizeDouble(normalizedLots, 2));
  }

//+------------------------------------------------------------------+
//| Execute market Buy or Sell order with SL and TP                  |
//+------------------------------------------------------------------+
void OpenTrade(int orderType)
  {
   RefreshRates();

   double lots  = CalculateLotSize();
   double price = (orderType == OP_BUY) ? Ask : Bid;
   double sl    = 0.0;
   double tp    = 0.0;

   if(orderType == OP_BUY)
     {
      if(StopLossPips > 0)   sl = NormalizeDouble(price - StopLossPips * g_pipSize, Digits);
      if(TakeProfitPips > 0) tp = NormalizeDouble(price + TakeProfitPips * g_pipSize, Digits);
     }
   else
     {
      if(StopLossPips > 0)   sl = NormalizeDouble(price + StopLossPips * g_pipSize, Digits);
      if(TakeProfitPips > 0) tp = NormalizeDouble(price - TakeProfitPips * g_pipSize, Digits);
     }

   string comment = (orderType == OP_BUY) ? "24h_EMA_Buy" : "24h_EMA_Sell";
   color  arrow   = (orderType == OP_BUY) ? clrDodgerBlue : clrTomato;

   int ticket = OrderSend(Symbol(), orderType, lots, price, g_slippagePts, sl, tp, comment, MagicNumber, 0, arrow);
   if(ticket < 0)
      Print("OrderSend failed | Type=", orderType, " | Lots=", DoubleToString(lots, 2), " | Error=", GetLastError());
   else
      Print("Order opened | Ticket=", ticket, " | Type=", comment, " | Lots=", DoubleToString(lots, 2), " | Price=", DoubleToString(price, Digits));
  }

//+------------------------------------------------------------------+
//| Notify once when floating account profit hits target             |
//+------------------------------------------------------------------+
void CheckProfitTarget()
  {
   if(ProfitTargetUSD <= 0.0)
      return;

   double currentProfit = AccountProfit();
   if(currentProfit >= ProfitTargetUSD && !g_targetAlerted)
     {
      g_targetAlerted = true;
      string msg = "24hours EA: Profit target achieved ($" + DoubleToString(currentProfit, 2) + ")";
      Alert(msg);
      Print(msg);
     }
   else if(currentProfit < ProfitTargetUSD * 0.5)
     {
      g_targetAlerted = false;
     }
  }
//+------------------------------------------------------------------+

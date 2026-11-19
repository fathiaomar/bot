# 24-Hour Automated Forex Trading Bot

<p align="center">
  <strong>A risk-managed Forex Expert Advisor built with MQL4 for MetaTrader 4.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-MetaTrader%204-blue" />
  <img src="https://img.shields.io/badge/Language-MQL4-00A86B" />
  <img src="https://img.shields.io/badge/Strategy-EMA%20%2B%20RSI-purple" />
  <img src="https://img.shields.io/badge/Trading-Automated-orange" />
  <img src="https://img.shields.io/badge/Status-Development-yellow" />
</p>

---

## Overview

**24-Hour Automated Trading Bot** is an Expert Advisor (EA) developed in MQL4 for MetaTrader 4 (MT4).

The bot automates Forex trading using a combination of Exponential Moving Average (EMA) crossovers and Relative Strength Index (RSI) confirmation.

It includes risk-based position sizing, automated stop-loss management, break-even protection, trailing stops, trading session controls, and a daily loss protection system.

The EA is designed to evaluate signals on closed candles rather than reacting to every incoming tick, helping reduce false entries caused by incomplete candles.

## Features

### 1. Automated Trading Strategy
- Fast and Slow EMA crossover strategy.
- RSI confirmation for buy and sell signals.
- Closed-candle signal evaluation.
- Configurable indicator periods and thresholds.

### 2. Risk Management
- Dynamic lot sizing based on account balance.
- Configurable percentage risk per trade.
- Fixed lot size option.
- Automatic stop-loss and take-profit placement.
- Maximum spread protection.
- Maximum open trades restriction.

### 3. Automated Trade Management
- Break-even stop-loss adjustment.
- Configurable profit-locking distance.
- Dynamic trailing stop.
- Broker stop-level validation.
- Automatic management of EA positions using a unique Magic Number.

### 4. Trading Protection
- Optional trading session filter.
- Daily equity loss limit.
- Automatic suspension of new entries after reaching the daily loss threshold.
- Optional closure of open EA positions when the daily loss limit is triggered.

### 5. Chart Dashboard
- Live trading status.
- Indicator information.
- Open trade information.
- Daily profit and loss monitoring.
- Floating profit target alert.

---

## Trading Strategy

The EA combines two technical indicators:

| Indicator | Configuration | Purpose |
|---|---|---|
| Fast EMA | 9 | Identifies short-term price direction |
| Slow EMA | 21 | Identifies broader trend direction |
| RSI | 14 | Confirms momentum |

### Buy Signal
A buy signal is generated when:
1. The fast EMA crosses above the slow EMA on closed candles.
2. RSI meets the configured buy threshold.
3. Trading conditions and risk filters are satisfied.

### Sell Signal
A sell signal is generated when:
1. The fast EMA crosses below the slow EMA on closed candles.
2. RSI meets the configured sell threshold.
3. Trading conditions and risk filters are satisfied.

**Note:** Signals are evaluated using completed candles to avoid acting on unfinished candle data.

---

## Risk Management System

Capital protection is a core component of this EA.

| Protection | Description |
|---|---|
| Dynamic Position Sizing | Calculates trade volume based on configured risk |
| Stop Loss | Defines maximum planned trade risk |
| Take Profit | Sets the target exit distance |
| Break-Even | Moves stop loss beyond entry after sufficient profit |
| Trailing Stop | Locks in profits as the market moves favorably |
| Spread Filter | Prevents entries when spread exceeds the limit |
| Daily Loss Limit | Restricts trading after reaching the daily loss threshold |
| Order Limit | Controls the number of simultaneous EA positions |

---

## Default Configuration

| Parameter | Default Value | Description |
|---|---:|---|
| MagicNumber | 240024 | Unique identifier for EA trades |
| UseDynamicLot | true | Enables risk-based lot sizing |
| RiskPercent | 1.0% | Risk per trade |
| FixedLotSize | 0.05 | Fixed lot fallback |
| StopLossPips | 30 | Initial stop-loss distance |
| TakeProfitPips | 60 | Initial take-profit distance |
| MaxSpreadPips | 3 | Maximum permitted spread |
| MaxOpenOrders | 1 | Maximum concurrent EA orders |
| SlippagePips | 3 | Maximum permitted slippage |
| ShowChartHUD | true | Displays chart dashboard |
| UseSessionFilter | false | Enables session restrictions |
| StartHour | 8 | Session starting hour |
| EndHour | 20 | Session ending hour |
| MaxDailyLossPercent | 3.0% | Maximum daily equity loss |
| CloseOnDailyLoss | true | Closes eligible EA positions |
| UseBreakEven | true | Enables break-even protection |
| BreakEvenTriggerPips | 20 | Break-even activation threshold |
| BreakEvenLockPips | 2 | Profit locked beyond entry |
| UseTrailingStop | true | Enables trailing stop |
| TrailingStartPips | 25 | Trailing activation threshold |
| TrailingStepPips | 5 | Minimum trailing adjustment |
| FastEMAPeriod | 9 | Fast EMA period |
| SlowEMAPeriod | 21 | Slow EMA period |
| RSIPeriod | 14 | RSI period |
| RSIBuyMin | 50.0 | Minimum RSI for buy confirmation |
| RSISellMax | 50.0 | Maximum RSI for sell confirmation |
| ProfitTargetUSD | 100.0 | Floating profit alert threshold |

---

## Requirements

Before running the EA, make sure you have:

- MetaTrader 4 installed.
- MetaEditor for compiling MQL4 source code.
- An MT4-compatible trading account.
- A demo account for initial testing.

## Installation

### Step 1: Clone the Repository

```bash
git clone [https://github.com/fathiaomar/bot.git](https://github.com/fathiaomar/bot.git)
Step 2: Copy the EA File
Open MetaTrader 4.

Navigate to File → Open Data Folder.

Open MQL4/Experts/.

Copy 24hours.mq4 into the folder.

Step 3: Compile the EA
Open MetaEditor.

Locate 24hours.mq4.

Press F7 to compile.

Check the compilation results for errors.

Step 4: Attach to a Chart
Return to MetaTrader 4.

Open the Navigator panel.

Find the EA under Expert Advisors.

Drag it onto your preferred Forex chart.

Configure the input parameters.

Enable AutoTrading and Allow Live Trading if you intend to run it.

Step 5: Backtest
Use the MT4 Strategy Tester:

Press Ctrl + R.

Select the 24hours Expert Advisor.

Choose a currency pair.

Select a historical testing period.

Configure the testing model and starting deposit.

Run the backtest and review the results.

Project Structure
Plaintext
bot/
│
├── 24hours.mq4       # Main Expert Advisor source code
└── README.md         # Project documentation
Important Notes
The EA is designed for MT4, not MetaTrader 5.

Trading hours are based on broker server time.

Pip calculations account for standard 4-digit and 5-digit Forex pricing.

Dynamic lot sizing depends on broker-provided tick and contract information.

Execution, spreads, slippage, and stop-level restrictions depend on the broker.

The floating profit alert uses the account's reported profit value; the account currency should be considered when configuring the USD target.

Disclaimer
This software is provided for educational and development purposes.

Automated Forex trading involves substantial financial risk. Market conditions, execution delays, broker restrictions, and volatility can affect trading outcomes.

Past performance and historical backtesting do not guarantee future results.

Always test on a demo account before considering live trading. Never risk funds you cannot afford to lose.

Author
Fathia Omar

Blockchain Developer | Software Developer | Automation Enthusiast

GitHub: fathiaomar

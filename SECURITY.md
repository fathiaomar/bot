# Security Policy

## Reporting a Vulnerability or Critical Trading Bug

If you discover a logic flaw, order-handling bug, or risk-control bypass in `24hours.mq4` that could result in unintended order execution or unthrottled drawdown:

1. **Do not open a public issue** with exploit steps for live-account configurations.
2. Report the issue directly to the maintainer via GitHub (`@fathiaomar`) with:
   - Affected MQL4 function or input parameters
   - Broker digit/account setup and timeframe
   - Steps or Strategy Tester logs reproducing the behavior

## Operational Safety Guidelines

- Always test changes on a **demo account** or in **MT4 Strategy Tester** before deploying to a live account.
- Never hardcode broker account credentials, API keys, or investor passwords into `.mq4`, `.set`, or `.md` files.
- Verify `RiskPercent`, `MaxDailyLossPercent`, `MaxSpreadPips`, and `MagicNumber` settings whenever attaching the EA to a new chart.

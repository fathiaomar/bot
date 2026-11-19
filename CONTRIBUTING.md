# Contributing to 24-Hour Automated Forex Trading Bot

Thank you for your interest in improving `24hours.mq4` and its documentation.

## How to Contribute

1. **Fork or Branch:** Create a focused feature or fix branch off `main` (for example, `feat/atr-trailing-stop` or `fix/spread-check`).
2. **Code Standards (MQL4):**
   - Keep `#property strict` enabled with **0 compiler errors and 0 warnings** in MetaEditor (`F7`).
   - Validate user `input` parameters inside `OnInit()` and return `INIT_PARAMETERS_INCORRECT` on invalid ranges.
   - Evaluate entry signals on closed bars (`shift = 1` / `shift = 2`) unless explicitly designing tick-level trade management.
   - Normalize prices with `NormalizeDouble(..., Digits)` and respect broker `MODE_STOPLEVEL`, `MODE_MINLOT`, `MODE_MAXLOT`, and `MODE_LOTSTEP`.
3. **Test Before Submitting:**
   - Compile cleanly in MetaEditor.
   - Run a backtest in MT4 **Strategy Tester** (`Ctrl + R`) or verify behavior on a demo account before opening a pull request.
4. **Open a Pull Request:**
   - Target `main` with a clear title and summary of what changed and how it was tested.

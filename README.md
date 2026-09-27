# Bank-Management-System
A Microprocessor Project built with emu8086

User Login: A simple login system (ID & PIN) with input, ensuring straightforward implementation and usability. After successful login, the system will display a clean menu interface in an infinite loop. Users can select options by pressing corresponding numeric keys. 

Account Tier Validation: Differentiate between "Savings" and "Current" accounts. Use logic to enforce different minimum balance requirements (e.g., 500 for Savings, 2000 for Current).

Interest Rate Calculator: A unique feature that calculates the projected balance after 1 year based on a fixed interest rate. This demonstrates your ability to perform 16-bit multiplication and division.

Transaction(Deposit,Withdraw) and History checking (Session-based): Transactions like deposit and withdrawal will be adjusted and will keep a small log of the last 3-5 actions (Deposit, Withdraw, Check) performed during the current session using an array.

ATM-Style Cash Dispenser Logic: When withdrawing, the system calculates how many "notes" of 500, 100, or 50 are required. This shows advanced use of the DIV and REM (remainder) operations.

PIN Lockout Security System:  The system implements a PIN lockout mechanism to enhance security. If a user enters an incorrect PIN multiple times (typically 2 or 3 attempts), the account is automatically locked. Once locked, the user is denied further login attempts and must seek administrative support to reset the account. This prevents unauthorized access through repeated guessing attempts and ensures account protection.


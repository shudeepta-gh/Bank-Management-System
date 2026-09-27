.MODEL SMALL
.STACK 100H

.DATA
    
    welcome_msg DB 0DH, 0AH, "--- WELCOME TO BANK MANAGEMENT SYSTEM ---", "$"
    id_prompt   DB 0DH, 0AH, "Enter ID: ", "$"
    pin_prompt  DB 0DH, 0AH, "Enter PIN: ", "$"
    login_fail  DB 0DH, 0AH, "Invalid ID or PIN! Try again.", "$"
    menu_header DB 0DH, 0AH, 0DH, 0AH, "--- MAIN MENU ---", "$"
    opt1        DB 0DH, 0AH, "1. Deposit", "$"
    opt2        DB 0DH, 0AH, "2. Withdraw", "$"
    opt3        DB 0DH, 0AH, "3. Check Balance", "$"
    opt4        DB 0DH, 0AH, "4. Transaction History", "$"
    opt5        DB 0DH, 0AH, "5. Exit", "$"
    choice_msg  DB 0DH, 0AH, "Select Option: ", "$"
    exit_msg    DB 0DH, 0AH, "Exiting... Goodbye!", "$"


    valid_ids   DB "123", "789", "456"
    valid_pins  DB "111", "222", "333"
    num_users   DW 3
    input_id    DB 3 DUP(?)
    input_pin   DB 3 DUP(?)

    
    acc_type_msg DB 0DH, 0AH, "Select Account Type:", 0DH, 0AH
                 DB "1. Current Account", 0DH, 0AH
                 DB "2. Savings Account", 0DH, 0AH, "Choice: ", "$"

    
    save_menu_hdr DB 0DH, 0AH, "--- SAVINGS DASHBOARD ---", 0DH, 0AH, "$"
    save_opt1     DB "1. Deposit", 0DH, 0AH, "$"
    save_opt2     DB "2. Withdraw Saving", 0DH, 0AH, "$"
    save_opt3     DB "3. Balance Saving", 0DH, 0AH, "$"
    save_opt4     DB "4. Toggle Lock", 0DH, 0AH, "$"
    save_opt5     DB "5. Exit", 0DH, 0AH, "Choice: ", "$"
    save_bal_msg  DB 0DH, 0AH, "Savings Balance: ", "$"
    lock_on_msg   DB 0DH, 0AH, "Status: Savings Account LOCKED.", "$"
    lock_off_msg  DB 0DH, 0AH, "Status: Savings Account UNLOCKED.", "$"
    save_lock_err DB 0DH, 0AH, "Error: Account is LOCKED! Unlock to withdraw.", "$"
    save_insuff   DB 0DH, 0AH, "Error: Insufficient savings balance!", "$"

    
    balance      DW 1000
    save_bal     DW 0
    min_balance  DW 500
    temp_val     DW 0
    is_locked    DB 0

   
    history_header DB 0DH, 0AH, "--- TRANSACTION HISTORY ---", 0DH, 0AH, "$"
    history_log    DB 60 DUP('$')
    log_ptr        DW 0

  
    amt_prompt   DB 0DH, 0AH, "Enter Amount: ", "$"
    msg_dep      DB "Deposit   ", 0DH, 0AH, "$"   ; exactly 12 bytes
    msg_wit      DB "Withdraw  ", 0DH, 0AH, "$"   ; exactly 12 bytes
    msg_chk      DB "Check Bal ", 0DH, 0AH, "$"   ; exactly 12 bytes
    bal_msg      DB 0DH, 0AH, "Current Balance: ", "$"
    insufficient DB 0DH, 0AH, "Error: Min balance 500 required!", "$"
    success_msg  DB 0DH, 0AH, "Success!", "$"
    save_partial_err DB 0DH, 0AH, "Error: Must withdraw full balance only!", "$"
    
  
    notes       DW 1000, 500, 100, 50, 20, 10, 5, 2, 1
    note_labels DB "1000 notes: ", "$"
                DB "500 notes:  ", "$"
                DB "100 notes:  ", "$"
                DB "50 notes:   ", "$"
                DB "20 notes:   ", "$"
                DB "10 notes:   ", "$"
                DB "5 notes:    ", "$"
                DB "2 notes:    ", "$"
                DB "1 notes:    ", "$"
    label_ptr   DW 0
    note_header DB 0DH, 0AH, "--- Cash Breakdown ---", 0DH, 0AH, "$"

   
    failed_attempts DB 0
    max_attempts    DB 3
    lockout_msg     DB 0DH, 0AH, "ACCOUNT LOCKED! Please contact admin.", "$"

.CODE

P_STR MACRO TEXT
    LEA DX, TEXT
    MOV AH, 09H
    INT 21H
ENDM

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX


LOGIN_START:
    P_STR welcome_msg

    P_STR id_prompt
    MOV SI, OFFSET input_id
    CALL GET_INPUT

    P_STR pin_prompt
    MOV SI, OFFSET input_pin
    CALL GET_INPUT

    MOV CX, num_users
    MOV BX, 0

CHECK_LOOP:
    PUSH CX

    MOV AL, input_id[0]
    CMP AL, valid_ids[BX]
    JNE NEXT_USER
    MOV AL, input_id[1]
    CMP AL, valid_ids[BX+1]
    JNE NEXT_USER
    MOV AL, input_id[2]
    CMP AL, valid_ids[BX+2]
    JNE NEXT_USER

    MOV AL, input_pin[0]
    CMP AL, valid_pins[BX]
    JNE PIN_FAIL_DETECTED
    MOV AL, input_pin[1]
    CMP AL, valid_pins[BX+1]
    JNE PIN_FAIL_DETECTED
    MOV AL, input_pin[2]
    CMP AL, valid_pins[BX+2]
    JNE PIN_FAIL_DETECTED

    
    POP CX
    MOV failed_attempts, 0


ACCOUNT_SELECT:
    P_STR acc_type_msg
    MOV AH, 01H
    INT 21H
    CMP AL, '1'
    JE MENU_LOOP
    CMP AL, '2'
    JE SAVINGS_SECTION
    JMP ACCOUNT_SELECT

NEXT_USER:
    ADD BX, 3
    POP CX
    LOOP CHECK_LOOP
    JMP FAIL

LOCKOUT_USER:
    P_STR lockout_msg
    MOV AX, 4C00H
    INT 21H

PIN_FAIL_DETECTED:
    POP CX

FAIL:
    INC failed_attempts
    MOV AL, failed_attempts
    CMP AL, max_attempts
    JGE LOCKOUT_USER
    P_STR login_fail
    JMP LOGIN_START


MENU_LOOP:
    CALL DISPLAY_MENU
    MOV AH, 01H
    INT 21H
    CMP AL, '1'
    JE DEPOSIT_L
    CMP AL, '2'
    JE WITHDRAW_L
    CMP AL, '3'
    JE BALANCE_L
    CMP AL, '4'
    JE HISTORY_L
    CMP AL, '5'
    JE EXIT_PROG
    JMP MENU_LOOP

DEPOSIT_L:
    P_STR amt_prompt
    CALL GET_AMOUNT_INPUT
    MOV AX, temp_val
    ADD balance, AX
    LEA SI, msg_dep
    CALL UPDATE_HISTORY
    P_STR success_msg
    JMP MENU_LOOP

WITHDRAW_L:
    P_STR amt_prompt
    CALL GET_AMOUNT_INPUT
    MOV AX, balance
    SUB AX, temp_val
    CMP AX, min_balance
    JL  FAIL_WITHDRAW
    MOV balance, AX
    P_STR note_header
    MOV AX, temp_val
    CALL CALCULATE_NOTES
    LEA SI, msg_wit
    CALL UPDATE_HISTORY
    P_STR success_msg
    JMP MENU_LOOP

FAIL_WITHDRAW:
    P_STR insufficient
    JMP MENU_LOOP

BALANCE_L:
    P_STR bal_msg
    MOV AX, balance
    CALL DISPLAY_NUM
    LEA SI, msg_chk
    CALL UPDATE_HISTORY
    JMP MENU_LOOP

HISTORY_L:
    P_STR history_header
    P_STR history_log
    JMP MENU_LOOP

EXIT_PROG:
    P_STR exit_msg
    JMP ACCOUNT_SELECT


SAVINGS_SECTION:
    P_STR save_menu_hdr
    P_STR save_opt1
    P_STR save_opt2
    P_STR save_opt3
    P_STR save_opt4
    P_STR save_opt5

    MOV AH, 01H
    INT 21H
    CMP AL, '1'
    JE SAVE_DEPOSIT
    CMP AL, '2'
    JE SAVE_WITHDRAW
    CMP AL, '3'
    JE SAVE_BALANCE
    CMP AL, '4'
    JE SAVE_TOGGLE
    CMP AL, '5'
    JE ACCOUNT_SELECT
    JMP SAVINGS_SECTION

SAVE_DEPOSIT:
    P_STR amt_prompt
    CALL GET_AMOUNT_INPUT
    MOV AX, temp_val
    ADD save_bal, AX
    P_STR success_msg
    JMP SAVINGS_SECTION

SAVE_WITHDRAW:
    CMP is_locked, 1
    JE  SAVE_LOCKED_FAIL

    MOV AX, save_bal
    CMP AX, 0
    JE  SAVE_INSUFF_FAIL    

    P_STR amt_prompt
    CALL GET_AMOUNT_INPUT

   
    MOV AX, save_bal
    MOV BX, temp_val
    CMP AX, BX
    JA  SAVE_PARTIAL_FAIL   
    JB  SAVE_INSUFF_FAIL   

    
    MOV save_bal, 0
    P_STR success_msg
    JMP SAVINGS_SECTION

SAVE_PARTIAL_FAIL:
    P_STR save_partial_err
    JMP SAVINGS_SECTION

SAVE_LOCKED_FAIL:
    P_STR save_lock_err
    JMP SAVINGS_SECTION

SAVE_INSUFF_FAIL:
    P_STR save_insuff
    JMP SAVINGS_SECTION

SAVE_BALANCE:
    P_STR save_bal_msg
    MOV AX, save_bal
    CALL DISPLAY_NUM
    JMP SAVINGS_SECTION

SAVE_TOGGLE:
    XOR is_locked, 1
    CMP is_locked, 1
    JE  SHOW_LOCKED
    P_STR lock_off_msg
    JMP SAVINGS_SECTION

SHOW_LOCKED:
    P_STR lock_on_msg
    JMP SAVINGS_SECTION

MAIN ENDP


DISPLAY_MENU PROC
    P_STR menu_header
    P_STR opt1
    P_STR opt2
    P_STR opt3
    P_STR opt4
    P_STR opt5
    P_STR choice_msg
    RET
DISPLAY_MENU ENDP

GET_INPUT PROC
    MOV CX, 3
GI_LOOP:
    MOV AH, 01H
    INT 21H
    MOV [SI], AL
    INC SI
    LOOP GI_LOOP
    RET
GET_INPUT ENDP

GET_AMOUNT_INPUT PROC
    MOV temp_val, 0
    MOV BX, 10
GA_LOOP:
    MOV AH, 01H
    INT 21H
    CMP AL, 13
    JE GA_END
    SUB AL, '0'
    MOV AH, 0
    MOV CX, AX
    MOV AX, temp_val
    MUL BX
    ADD AX, CX
    MOV temp_val, AX
    JMP GA_LOOP
GA_END:
    RET
GET_AMOUNT_INPUT ENDP

UPDATE_HISTORY PROC
    MOV DI, OFFSET history_log
    ADD DI, log_ptr
    MOV CX, 12
UH_COPY:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP UH_COPY
    ADD log_ptr, 12
    CMP log_ptr, 60
    JNE UH_DONE
    MOV log_ptr, 0
UH_DONE:
    RET
UPDATE_HISTORY ENDP

DISPLAY_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV BX, 10
    MOV CX, 0
DN_DIVIDE:
    MOV DX, 0
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE DN_DIVIDE
DN_PRINT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP DN_PRINT
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DISPLAY_NUM ENDP

CALCULATE_NOTES PROC
    MOV CX, 9
    MOV SI, 0
    MOV label_ptr, OFFSET note_labels
CN_LOOP:
    PUSH CX
    PUSH AX
    MOV DX, 0
    MOV BX, notes[SI]
    DIV BX
    CMP AX, 0
    JE CN_SKIP
    PUSH DX
    PUSH AX
    MOV DX, label_ptr
    MOV AH, 09H
    INT 21H
    POP AX
    CALL DISPLAY_NUM
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    POP DX
CN_SKIP:
    ADD label_ptr, 13
    MOV AX, DX
    ADD SI, 2
    POP BX
    POP CX
    LOOP CN_LOOP
    RET
CALCULATE_NOTES ENDP

END MAIN

#include "UpCounter.h"

hBtn_t hBtnRunStop, hBtnClear;
uint16_t counter = 0;

void UpCounter_Init(){
    SPI_Init(SPI0, 0, 0, 49);
    FND_Init();
    Button_Init(&hBtnRunStop, GPIOA, GPIO_PIN_4);
    Button_Init(&hBtnClear, GPIOA, GPIO_PIN_7);
    counter = 0;
}

void UpCounter_Excute(){
    // 항상 SPI 교환 (상태 상관없이)
    static uint32_t prevSpiTime = 0;
    if(millis() - prevSpiTime >= 100) {
        prevSpiTime = millis();
        SPI_Transfer(SPI0, counter);
    }

    static upcounter_state_t upCounterState = STOP;
    switch(upCounterState){
    case STOP:
        UpCounter_Stop();
        if(Button_GetState(&hBtnRunStop) == ACT_PUSHED)
            upCounterState = RUN;
        else if(Button_GetState(&hBtnClear) == ACT_PUSHED)
            upCounterState = CLEAR;
        break;
    case RUN:
        UpCounter_Run();
        if(Button_GetState(&hBtnRunStop) == ACT_PUSHED)
            upCounterState = STOP;
        break;
    case CLEAR:
        UpCounter_Clear();
        upCounterState = STOP;
        break;
    default:
        UpCounter_Stop();
        break;
    }
}

void UpCounter_DisLoop(){
    FND_DispDigit();
}

void UpCounter_Run(){
    static uint32_t prevTimeCounter = 0;
    if(millis() - prevTimeCounter < 100-1)
        return;
    prevTimeCounter = millis();
    if(counter < 9999) counter++;
    FND_SetNum(counter);
}

void UpCounter_Stop(){
    FND_SetNum(counter);
}

void UpCounter_Clear(){
    counter = 0;
    FND_SetNum(counter);
}

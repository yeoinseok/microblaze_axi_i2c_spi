#include "SPI.h"
void SPI_Init(SPI_Typedef_t *SPIx, uint8_t cpol, uint8_t cpha, uint8_t clk_div)
{
    uint32_t reg_val = 0;
    if (cpol) reg_val |= (1 << SPI_CPOL_BIT);
    if (cpha) reg_val |= (1 << SPI_CPHA_BIT);
    SPIx->CR = reg_val;
    SPIx->CLK_DIV = clk_div;
}
uint16_t SPI_Transfer(SPI_Typedef_t *SPIx, uint16_t tx_data)
{
    SPIx->TX_DATA = tx_data;
    // start 펄스: 0→1
    SPIx->CR |= (1 << SPI_START_BIT);
    // start 바로 내림 (RTL에서 rising edge로 펄스 생성)
    SPIx->CR &= ~(1 << SPI_START_BIT);
    // busy 해제 대기
    volatile uint32_t timeout = 100000;
    while ((SPIx->SR & (1 << SPI_BUSY_BIT)) && timeout > 0) {
        timeout--;
    }
    return (uint16_t)(SPIx->SR & SPI_RX_MASK);
}

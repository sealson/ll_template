#include <stm32l4xx.h>
#include <stm32l4xx_ll_rcc.h>
#include <stm32l4xx_ll_bus.h>
#include <stm32l4xx_ll_pwr.h>
#include <stm32l4xx_ll_gpio.h>
#include <stm32l4xx_ll_utils.h>
#include <stm32l4xx_ll_system.h>
#include <core_cm4.h>
#include <stdio.h>
#include "pinout.h"

static inline void GPIO_Init( void);
static inline void CLK_Config_80Mhz( void);

void DWT_Init(void)
{
    CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
    DWT->CTRL |= DWT_CTRL_CYCCNTENA_Msk;
    DWT->CYCCNT = 0;
}

extern void  initialise_monitor_handles(void);

int main()
{
    CLK_Config_80Mhz();
#if defined(ENABLE_SEMIHOSTING) && (ENABLE_SEMIHOSTING)
    initialise_monitor_handles();
#endif
    
    GPIO_Init();

    int i = - 1; 
    while(1) {
        LL_GPIO_TogglePin(LD4_GPIO_Port, LD4_Pin);
        printf("Kek %d\r\n", i);
        LL_mDelay(500);
    }
}

static inline void GPIO_Init( void)
{
  /* GPIO Ports Clock Enable */
  LL_AHB2_GRP1_EnableClock( LL_AHB2_GRP1_PERIPH_GPIOH);
  LL_AHB2_GRP1_EnableClock( LL_AHB2_GRP1_PERIPH_GPIOA);
  LL_AHB2_GRP1_EnableClock( LL_AHB2_GRP1_PERIPH_GPIOB);
  LL_AHB2_GRP1_EnableClock( LL_AHB2_GRP1_PERIPH_GPIOC);
  
  LL_GPIO_ResetOutputPin( LD4_GPIO_Port,         LD4_Pin);
  LL_GPIO_InitTypeDef GPIO_InitStruct = {0};
  GPIO_InitStruct.Pin = LD4_Pin;
  GPIO_InitStruct.Mode = LL_GPIO_MODE_OUTPUT;
  GPIO_InitStruct.Speed = LL_GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.OutputType = LL_GPIO_OUTPUT_PUSHPULL;
  GPIO_InitStruct.Pull = LL_GPIO_PULL_NO;
  if ( LL_GPIO_Init(LD4_GPIO_Port, &GPIO_InitStruct) != SUCCESS)
      return;
}

static inline void CLK_Config_80Mhz( void)
{
    LL_APB2_GRP1_EnableClock(LL_APB2_GRP1_PERIPH_SYSCFG);
    LL_APB1_GRP1_EnableClock(LL_APB1_GRP1_PERIPH_PWR);
  
    LL_FLASH_SetLatency(LL_FLASH_LATENCY_4);
    LL_PWR_SetRegulVoltageScaling(LL_PWR_REGU_VOLTAGE_SCALE1);
    LL_RCC_HSI_Enable();
   
     /* Wait till HSI is ready */
    while(LL_RCC_HSI_IsReady() != 1) { }
   
    LL_RCC_HSI_SetCalibTrimming(16);
    LL_RCC_PLL_ConfigDomain_SYS(LL_RCC_PLLSOURCE_HSI, LL_RCC_PLLM_DIV_1, 10, LL_RCC_PLLR_DIV_2);
    LL_RCC_PLL_EnableDomain_SYS();
    LL_RCC_PLL_Enable();
   
     /* Wait till PLL is ready */
    while(LL_RCC_PLL_IsReady() != 1) { }
   
    LL_RCC_SetSysClkSource(LL_RCC_SYS_CLKSOURCE_PLL);
   
     /* Wait till System clock is ready */
    while(LL_RCC_GetSysClkSource() != LL_RCC_SYS_CLKSOURCE_STATUS_PLL) { }
   
    LL_RCC_SetAHBPrescaler(LL_RCC_SYSCLK_DIV_1);
    LL_RCC_SetAPB1Prescaler(LL_RCC_APB1_DIV_1);
    LL_RCC_SetAPB2Prescaler(LL_RCC_APB2_DIV_1);
   
    LL_Init1msTick(80000000);
   
    LL_SetSystemCoreClock(80000000);
    
    /* Periph clock sources */
    LL_RCC_SetUSARTClockSource(LL_RCC_USART2_CLKSOURCE_PCLK1);
    LL_RCC_SetUSARTClockSource(LL_RCC_USART3_CLKSOURCE_PCLK1);
    LL_RCC_SetI2CClockSource(LL_RCC_I2C1_CLKSOURCE_PCLK1);
    LL_RCC_SetI2CClockSource(LL_RCC_I2C3_CLKSOURCE_PCLK1);
    LL_RCC_SetI2CClockSource(LL_RCC_I2C2_CLKSOURCE_PCLK1);
    LL_RCC_SetADCClockSource(LL_RCC_ADC_CLKSOURCE_SYSCLK);
}

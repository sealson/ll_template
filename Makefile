PROJECT = test

STD = -std=gnu11
OPT = -O0
DEB = -g3
DR 	= DEBUG
ENABLE_SEMIHOSTING=1

# Paths
STLINK = /usr/local/bin
OPENOCD = /usr/bin/openocd
PATH_TO_CUBE = $(HOME)/STM32Cube/Repository/STM32Cube_FW_L4_V1.16.0
GCCPATH = /opt/gcc-arm-none-eabi-9-2020-q2-update/bin

STARTUP = config/startup_stm32l433xx.s
LDSCRIPT = config/STM32L433RCTx_FLASH.ld

# Includes 
C_INC  = -I.
C_INC += -Iconfig
C_INC += -I$(PATH_TO_CUBE)/Drivers/STM32L4xx_HAL_Driver/Inc
C_INC += -I$(PATH_TO_CUBE)/Drivers/CMSIS/Include
C_INC += -I$(PATH_TO_CUBE)/Drivers/CMSIS/Device/ST/STM32L4xx/Include

# Sources section
ASM_SRC = $(STARTUP)

C_SRC  = config/system_stm32l4xx.c
C_SRC += main.c

CXX_SRC =

# Definitions
DEFINES += -DVDD_VALUE=3300
DEFINES += -DHSI_VALUE=16000000
DEFINES += -DHSE_VALUE=8000000
DEFINES += -DHSE_STARTUP_TIMEOUT=100
DEFINES += -DMSI_VALUE=4000000
DEFINES += -DLSI_VALUE=32000
DEFINES += -DLSE_VALUE=32768
DEFINES += -DLSE_STARTUP_TIMEOUT=5000
DEFINES += -DEXTERNALSAI1_CLOCK_VALUE=20970000
DEFINES += -DPREFETCH_ENABLE=1
DEFINES += -DDATA_CACHE_ENABLE=1
DEFINES += -DINSTRUCTION_CACHE_ENABLE=1
DEFINES += -DSTM32L433xx
DEFINES += -DUSE_FULL_LL_DRIVER
#DEFINES += -DUSE_FULL_ASSERT 

# Warnings
WARN = -Wall
WARN += -pedantic
WARN += -Wno-unused-function
#WARN += -Wno-unused-variable
#WARN += -Wno-unused-but-set-variable
#WARN += -Wno-unused-value

ifeq ($(DR),DEBUG)
DEFINES += -DDEBUG
else
endif

LL_PREFIX = $(PATH_TO_CUBE)/Drivers/STM32L4xx_HAL_Driver/Src
C_SRC += $(LL_PREFIX)/stm32l4xx_ll_utils.c
C_SRC += $(LL_PREFIX)/stm32l4xx_ll_rcc.c
C_SRC += $(LL_PREFIX)/stm32l4xx_ll_pwr.c
C_SRC += $(LL_PREFIX)/stm32l4xx_ll_gpio.c
C_SRC += $(LL_PREFIX)/stm32l4xx_ll_exti.c
C_SRC += $(LL_PREFIX)/stm32l4xx_ll_usart.c
C_SRC += $(LL_PREFIX)/stm32l4xx_ll_tim.c
C_SRC += $(LL_PREFIX)/stm32l4xx_ll_i2c.c
C_SRC += $(LL_PREFIX)/stm32l4xx_ll_adc.c
C_SRC += $(LL_PREFIX)/stm32l4xx_ll_dma.c
C_SRC += $(LL_PREFIX)/stm32l4xx_ll_crc.c
#C_SRC += $(LL_PREFIX)/stm32l4xx_ll_rtc.c
#C_SRC += $(LL_PREFIX)/stm32l4xx_ll_spi.c
#C_SRC += $(LL_PREFIX)/stm32l4xx_ll_comp.c
#C_SRC += $(LL_PREFIX)/stm32l4xx_ll_crs.c
#C_SRC += $(LL_PREFIX)/stm32l4xx_ll_dac.c
#C_SRC += $(LL_PREFIX)/stm32l4xx_ll_dma2d.c
#C_SRC += $(LL_PREFIX)/stm32l4xx_ll_lptim.c
#C_SRC += $(LL_PREFIX)/stm32l4xx_ll_lpuart.c
#C_SRC += $(LL_PREFIX)/stm32l4xx_ll_opamp.c
#C_SRC += $(LL_PREFIX)/stm32l4xx_ll_pka.c
#C_SRC += $(LL_PREFIX)/stm32l4xx_ll_rng.c
#C_SRC += $(LL_PREFIX)/stm32l4xx_ll_swpmi.c

include ./rules.mk

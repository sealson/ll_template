CPU 		= -mcpu=cortex-m4 -mlittle-endian
FPU 		= -mfpu=fpv4-sp-d16
FLOAT-ABI 	= -mfloat-abi=hard
MCU 		= -mthumb -mthumb-interwork $(CPU) $(FPU) $(FLOAT-ABI)

MKDIR   = mkdir -p
RM 		= rm -rf
TRIPLET = arm-none-eabi
CC 		= $(GCCPATH)/$(TRIPLET)-gcc
CXX 	= $(GCCPATH)/$(TRIPLET)-g++
LD 		= $(GCCPATH)/$(TRIPLET)-gcc
AR 		= $(GCCPATH)/$(TRIPLET)-ar
AS 		= $(GCCPATH)/$(TRIPLET)-gcc -x assembler-with-cpp
SIZE	= $(GCCPATH)/$(TRIPLET)-size
OD 		= $(GCCPATH)/$(TRIPLET)-objdump
OBJCOPY = $(GCCPATH)/$(TRIPLET)-objcopy
BIN 	= $(OBJCOPY) -O binary -S
HEX 	= $(OBJCOPY) -O ihex

ifeq ($(DR),DEBUG)
BUILDDIR = dbg
else
BUILDDIR = rls
endif

# Various directories
OBJDIR    = $(BUILDDIR)/obj
LSTDIR    = $(BUILDDIR)/lst

# Flags ================================================================================================== #

CFLAGS 		= $(MCU) $(OPT) $(DEB) $(STD) $(C_INC) $(DEFINES) $(WARN) \
			  -fdata-sections -ffunction-sections \
			  -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"

CXXFLAGS 	=

LDFLAGS 	= -Wl,--gc-sections,-Map=$(BUILDDIR)/$(PROJECT).map,-cref \
			  -T $(LDSCRIPT) $(MCU)

ODFLAGS	  	= -x --syms

ifeq ($(ENABLE_SEMIHOSTING),1)   
CFLAGS   += -DENABLE_SEMIHOSTING=1
LDFLAGS  += --specs=nosys.specs --specs=nano.specs --specs=rdimon.specs 
LDFLAGS  += -Wl,-lrdimon
else
CFLAGS   += -DENABLE_SEMIHOSTING=0
LDFLAGS  += --specs=nosys.specs --specs=nano.specs
endif

# Rules ================================================================================================== #

OBJECTS = $(addprefix $(OBJDIR)/,$(notdir $(C_SRC:.c=.o)))
vpath %.c $(sort $(dir $(C_SRC)))
OBJECTS += $(addprefix $(OBJDIR)/,$(notdir $(CXX_SRC:.cpp=.o)))
vpath %.cpp $(sort $(dir $(CXX_SRC)))
OBJECTS += $(addprefix $(OBJDIR)/,$(notdir $(ASM_SRC:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SRC)))

OUTFILES = $(BUILDDIR)/$(PROJECT).elf $(BUILDDIR)/$(PROJECT).hex \
           $(BUILDDIR)/$(PROJECT).bin $(BUILDDIR)/$(PROJECT).dmp

all: $(BUILDDIR) \
	$(OBJECTS) \
	$(OUTFILES)
	@echo $(DR)

$(OBJDIR)/%.o: %.c Makefile | $(BUILDDIR)
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(LSTDIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(OBJDIR)/%.o: %.cpp Makefile | $(BUILDDIR)
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.o: %.s Makefile | $(BUILDDIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILDDIR)/$(PROJECT).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SIZE) $@

$(BUILDDIR)/%.bin: $(BUILDDIR)/%.elf | $(BUILDDIR)
	$(BIN) $< $@

$(BUILDDIR)/%.hex: $(BUILDDIR)/%.elf | $(BUILDDIR)
	$(HEX) $< $@

$(BUILDDIR)/%.dmp: $(BUILDDIR)/%.elf | $(BUILDDIR)
	$(OD) $(ODFLAGS) $< > $@

$(BUILDDIR):
	$(MKDIR) $(BUILDDIR)
	$(MKDIR) $(OBJDIR)
	$(MKDIR) $(LSTDIR)

clean:
	$(RM) $(BUILDDIR)

#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/ds_rules

#---------------------------------------------------------------------------------
# Header variables
#---------------------------------------------------------------------------------
NAME		:=	Manic Miner LL
AUTHOR		:=	By Flash
VERSION		:=	www.retrobytesportal.com
NITRODIR	:=	-d efsroot
LOGO		:=	
ICON		:=	-b logo.bmp
EFS			:=	1

export TARGET		:=	$(shell basename $(CURDIR))
export TOPDIR		:=	$(CURDIR)


.PHONY: $(TARGET).arm7 $(TARGET).arm9

#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
all: $(TARGET).nds

#---------------------------------------------------------------------------------
$(TARGET).nds	:	$(TARGET).arm7 $(TARGET).arm9
ifeq ($(EFS), 1)
	ndstool -c $(TARGET).nds -7 $(TARGET).arm7 -9 $(TARGET).arm9 $(NITRODIR) $(LOGO) $(ICON) "$(NAME);$(AUTHOR);$(VERSION)"
	efs $(TARGET).nds
else
	ndstool -c $(TARGET).nds -7 $(TARGET).arm7 -9 $(TARGET).arm9 $(LOGO) $(ICON) "$(NAME);$(AUTHOR);$(VERSION)"
endif

#---------------------------------------------------------------------------------
$(TARGET).arm7	: arm7/$(TARGET).elf
$(TARGET).arm9	: arm9/$(TARGET).elf

#---------------------------------------------------------------------------------
arm7/$(TARGET).elf:
	$(MAKE) -C arm7
	
#---------------------------------------------------------------------------------
arm9/$(TARGET).elf:
	$(MAKE) -C arm9

#---------------------------------------------------------------------------------
clean:
	$(MAKE) -C arm9 clean
	$(MAKE) -C arm7 clean
	rm -f $(TARGET).nds $(TARGET).arm7 $(TARGET).arm9

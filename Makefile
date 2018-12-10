NAME=boxos
BUILDDIR=/dev/shm/$(NAME)
TARGET=$(BUILDDIR)/$(NAME).elf
DATE=$(shell git log -n 1 --date=short --pretty=format:%cd)
COMMIT=$(shell git log -n 1 --pretty=format:%h)

BUILDSRC:=$(BUILDDIR)/Makefile
CARDREADERSRC:=$(BUILDDIR)/card-reader.c
CONSOLESRC:=$(BUILDDIR)/console.c
CORESRC:=$(BUILDDIR)/boxos.c
CHARGERSRC:=$(BUILDDIR)/charger.c
DRIVERSRC:=$(BUILDDIR)/uart.c
EGGSRC:=$(BUILDDIR)/egg.c
ENGINEERSRC:=$(BUILDDIR)/engineer.c
LOCKSRC:=$(BUILDDIR)/lock.c
NETWORKSRC:=$(BUILDDIR)/network.c
UTILITYSRC:=$(BUILDDIR)/utility.c $(BUILDDIR)/base64.c $(BUILDDIR)/hash.c $(BUILDDIR)/mt19937.c $(BUILDDIR)/ring.c $(BUILDDIR)/stack.c $(BUILDDIR)/defination.h

LEXFSMSRC:=$(BUILDDIR)/at-lex-fsm.c
CHARGERFSMSRC:=$(BUILDDIR)/charger-fsm.c
EC20FSMSRC:=$(BUILDDIR)/ec20-fsm.c
EC20SYNTAXFSMSRC:=$(BUILDDIR)/ec20-syntax-fsm.c
EGGFSMSRC:=$(BUILDDIR)/egg-fsm.c
ENGINEERFSMSRC:=$(BUILDDIR)/engineer-fsm.c
ESP8266FSMSRC:=$(BUILDDIR)/esp8266-fsm.c
ESP8266SYNTAXFSMSRC:=$(BUILDDIR)/esp8266-syntax-fsm.c
LOCKBOARDFSMSRC:=$(BUILDDIR)/lockboard-fsm.c
LOCKDGZLFSMSRC:=$(BUILDDIR)/lock-dgzl-fsm.c
LOCKFCFSMSRC:=$(BUILDDIR)/lock-fc-fsm.c
UART3FSMSRC:=$(BUILDDIR)/uart3-fsm.c
UART4FSMSRC:=$(BUILDDIR)/uart4-fsm.c
UPSTREAMFSMSRC:=$(BUILDDIR)/upstream-fsm.c

CHARGERPROTO:=$(BUILDDIR)/charger.tr
CHARGERPROTOSCR:=$(BUILDDIR)/charger_payload.c
UART3PROTO:=$(BUILDDIR)/uart3.tr
UART3PROTOSCR:=$(BUILDDIR)/uart3_payload.c

LIBRARY:=$(BUILDDIR)/libopencm3
CONFIG:=$(BUILDDIR)/config
CONFIGSRC:=$(BUILDDIR)/config.orig

include .config

all: $(TARGET)

ifdef ENGINEER_MODE
ifeq ($(LOCK),DGZL)
DEPENDS=$(BUILDSRC) $(CONSOLESRC) $(CORESRC) $(DRIVERSRC) $(LOCKSRC) $(UTILITYSRC) $(ENGINEERFSMSRC) $(LOCKDGZLFSMSRC) $(UART4FSMSRC) $(ENGINEERSRC) $(LIBRARY) $(CONFIGSRC)
endif
ifeq ($(LOCK),FC)
DEPENDS=$(BUILDSRC) $(CONSOLESRC) $(CORESRC) $(DRIVERSRC) $(LOCKSRC) $(UTILITYSRC) $(ENGINEERFSMSRC) $(LOCKFCFSMSRC) $(UART4FSMSRC) $(ENGINEERSRC) $(LIBRARY) $(CONFIGSRC)
endif
else
ifeq ($(LOCK),DGZL)
DEPENDS=$(BUILDSRC) $(CARDREADERSRC) $(CONSOLESRC) $(CORESRC) $(CHARGERSRC) $(DRIVERSRC) $(EGGSRC) $(LOCKSRC) $(NETWORKSRC) $(UTILITYSRC) $(LEXFSMSRC) $(CHARGERFSMSRC) $(EC20FSMSRC) $(EC20SYNTAXFSMSRC) $(EGGFSMSRC) $(ENGINEERFSMSRC) $(ESP8266FSMSRC) $(ESP8266SYNTAXFSMSRC) $(LOCKBOARDFSMSRC) $(LOCKDGZLFSMSRC) $(UART3FSMSRC) $(UART4FSMSRC) $(UPSTREAMFSMSRC) $(CHARGERPROTOSCR) $(UART3PROTOSCR) $(LIBRARY) $(CONFIGSRC)
endif
ifeq ($(LOCK),FC)
DEPENDS=$(BUILDSRC) $(CARDREADERSRC) $(CONSOLESRC) $(CORESRC) $(CHARGERSRC) $(DRIVERSRC) $(EGGSRC) $(LOCKSRC) $(NETWORKSRC) $(UTILITYSRC) $(LEXFSMSRC) $(CHARGERFSMSRC) $(EC20FSMSRC) $(EC20SYNTAXFSMSRC) $(EGGFSMSRC) $(ENGINEERFSMSRC) $(ESP8266FSMSRC) $(ESP8266SYNTAXFSMSRC) $(LOCKBOARDFSMSRC) $(LOCKFCFSMSRC) $(UART3FSMSRC) $(UART4FSMSRC) $(UPSTREAMFSMSRC) $(CHARGERPROTOSCR) $(UART3PROTOSCR) $(LIBRARY) $(CONFIGSRC)
endif
endif

$(TARGET): $(DEPENDS)
	sed 's/\$${LOCK}/$(LOCK)/g' $(CONFIGSRC) | sed 's/\$${NETWORK}/$(NETWORK)/g' | sed 's/\$${DOMAIN}/${DOMAIN}/g' | sed 's/\$${PORT}/${PORT}/g' | sed 's/\$${MAIN}/${MAIN_VERSION}/g' | sed 's/\$${SUB}/${SUB_VERSION}/g' > $(CONFIG)

ifdef DEBUG
	sed -i 'a \DEBUG=1' $(CONFIG)
endif
ifdef ENGINEER_MODE
	sed -i 'a \ENGINEER_MODE=1' $(CONFIG)
endif
	cd $(BUILDDIR); make; cd -

$(BUILDSRC): build.org | prebuild
	org-tangle $<
	sed -i 's/        /\t/g' $@
	sed -i 's/        /\t/g' $(BUILDDIR)/libopencm3.rules.mk
	sed -i 's/        /\t/g' $(BUILDDIR)/libopencm3.target.mk
$(CARDREADERSRC): card-reader.org | prebuild
	org-tangle $<
$(CONSOLESRC): console.org | prebuild
	org-tangle $<
$(CORESRC): core.org | prebuild
	org-tangle $<
$(CHARGERSRC): charger.org | prebuild
	org-tangle $<
$(DRIVERSRC): driver.org | prebuild
	org-tangle $<
$(EGGSRC): egg.org | prebuild
	org-tangle $<
$(ENGINEERSRC): engineer.org | prebuild
	org-tangle $<
$(LOCKSRC): lock.org | prebuild
	org-tangle $<
$(NETWORKSRC): network.org | prebuild
	org-tangle $<
$(UTILITYSRC): utility.org | prebuild
	org-tangle $<
$(LEXFSMSRC): at-lex-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix at-lex --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix at-lex --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@
$(CHARGERFSMSRC): charger-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix charger --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix charger --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@
$(EC20FSMSRC): ec20-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20 --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20 --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@
$(EC20SYNTAXFSMSRC): ec20-syntax-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20-syntax --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20-syntax --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@
$(EGGFSMSRC): egg-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix egg --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix egg --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@
$(ENGINEERFSMSRC): engineer-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix engineer --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix engineer --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@
$(ESP8266FSMSRC): esp8266-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix esp8266 --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix esp8266 --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@
$(ESP8266SYNTAXFSMSRC): esp8266-syntax-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix esp8266-syntax --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix esp8266-syntax --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@
$(LOCKBOARDFSMSRC): lockboard-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix lockboard --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix lockboard --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@
$(LOCKDGZLFSMSRC): lock-dgzl-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix lock --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix lock --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@
$(LOCKFCFSMSRC): lock-fc-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix lock --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix lock --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@
$(UART3FSMSRC): uart3-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix uart3 --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix uart3 --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@
$(UART4FSMSRC): uart4-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix uart4 --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix uart4 --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@
$(UPSTREAMFSMSRC): upstream-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix upstream --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix upstreawm --style table --debug
#	sed -i '1a#include "console.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/console_log(\"(\");/g' $@
#	sed -i 's/printf/console_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@

$(CHARGERPROTOSCR): $(CHARGERPROTO) | prebuild
	tightrope -entity -serial -clang -d $(BUILDDIR) $<

$(CHARGERPROTO): charger.org | prebuild
	org-tangle $<

$(UART3PROTOSCR): $(UART3PROTO) | prebuild
	tightrope -entity -serial -clang -d $(BUILDDIR) $<

$(UART3PROTO): driver.org | prebuild
	org-tangle $<

$(LIBRARY):
	ln -sf $(LIBOPENCM3) $(BUILDDIR)

flash: $(TARGET)
	cd $(BUILDDIR); make flash V=1; cd -

release: /dev/shm/boxos-fc-ec20-$(MAIN_VERSION).$(SUB_VERSION)-$(COMMIT)-$(DATE).bin /dev/shm/boxos-fc-esp8266-$(MAIN_VERSION).$(SUB_VERSION)-$(COMMIT)-$(DATE).bin /dev/shm/boxos-dgzl-ec20-$(MAIN_VERSION).$(SUB_VERSION)-$(COMMIT)-$(DATE).bin /dev/shm/boxos-dgzl-esp8266-$(MAIN_VERSION).$(SUB_VERSION)-$(COMMIT)-$(DATE).bin

/dev/shm/boxos-fc-ec20-$(MAIN_VERSION).$(SUB_VERSION)-$(COMMIT)-$(DATE).bin: $(BUILDSRC) $(CARDREADERSRC) $(CONSOLESRC) $(CORESRC) $(CHARGERSRC) $(DRIVERSRC) $(EGGSRC) $(LOCKSRC) $(NETWORKSRC) $(UTILITYSRC) $(LEXFSMSRC) $(CHARGERFSMSRC) $(EC20FSMSRC) $(EC20SYNTAXFSMSRC) $(EGGFSMSRC) $(ENGINEERFSMSRC) $(ESP8266FSMSRC) $(ESP8266SYNTAXFSMSRC) $(LOCKBOARDFSMSRC) $(LOCKFCFSMSRC) $(UART3FSMSRC) $(UART4FSMSRC) $(UPSTREAMFSMSRC) $(CHARGERPROTOSCR) $(UART3PROTOSCR) $(LIBRARY) $(CONFIGSRC)
	sed 's/\$${LOCK}/FC/g' $(CONFIGSRC) | sed 's/\$${NETWORK}/EC20/g' | sed 's/\$${DOMAIN}/${DOMAIN}/g' | sed 's/\$${PORT}/${PORT}/g' | sed 's/\$${MAIN}/${MAIN_VERSION}/g' | sed 's/\$${SUB}/${SUB_VERSION}/g' > $(CONFIG)
ifdef DEBUG
	sed -i 'a \DEBUG=1' $(CONFIG)
endif
ifdef ENGINEER_MODE
	sed -i 'a \ENGINEER_MODE=1' $(CONFIG)
endif
	cd $(BUILDDIR); make clean; make bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

/dev/shm/boxos-fc-esp8266-$(MAIN_VERSION).$(SUB_VERSION)-$(COMMIT)-$(DATE).bin: $(BUILDSRC) $(CARDREADERSRC) $(CONSOLESRC) $(CORESRC) $(CHARGERSRC) $(DRIVERSRC) $(EGGSRC) $(LOCKSRC) $(NETWORKSRC) $(UTILITYSRC) $(LEXFSMSRC) $(CHARGERFSMSRC) $(EC20FSMSRC) $(EC20SYNTAXFSMSRC) $(EGGFSMSRC) $(ENGINEERFSMSRC) $(ESP8266FSMSRC) $(ESP8266SYNTAXFSMSRC) $(LOCKBOARDFSMSRC) $(LOCKFCFSMSRC) $(UART3FSMSRC) $(UART4FSMSRC) $(UPSTREAMFSMSRC) $(CHARGERPROTOSCR) $(UART3PROTOSCR) $(LIBRARY) $(CONFIGSRC)
	sed 's/\$${LOCK}/FC/g' $(CONFIGSRC) | sed 's/\$${NETWORK}/ESP8266/g' | sed 's/\$${DOMAIN}/${DOMAIN}/g' | sed 's/\$${PORT}/${PORT}/g' | sed 's/\$${MAIN}/${MAIN_VERSION}/g' | sed 's/\$${SUB}/${SUB_VERSION}/g' > $(CONFIG)
ifdef DEBUG
	sed -i 'a \DEBUG=1' $(CONFIG)
endif
ifdef ENGINEER_MODE
	sed -i 'a \ENGINEER_MODE=1' $(CONFIG)
endif
	cd $(BUILDDIR); make clean; make bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

/dev/shm/boxos-dgzl-ec20-$(MAIN_VERSION).$(SUB_VERSION)-$(COMMIT)-$(DATE).bin: $(BUILDSRC) $(CARDREADERSRC) $(CONSOLESRC) $(CORESRC) $(CHARGERSRC) $(DRIVERSRC) $(EGGSRC) $(LOCKSRC) $(NETWORKSRC) $(UTILITYSRC) $(LEXFSMSRC) $(CHARGERFSMSRC) $(EC20FSMSRC) $(EC20SYNTAXFSMSRC) $(EGGFSMSRC) $(ENGINEERFSMSRC) $(ESP8266FSMSRC) $(ESP8266SYNTAXFSMSRC) $(LOCKBOARDFSMSRC) $(LOCKDGZLFSMSRC) $(UART3FSMSRC) $(UART4FSMSRC) $(UPSTREAMFSMSRC) $(CHARGERPROTOSCR) $(UART3PROTOSCR) $(LIBRARY) $(CONFIGSRC)
	sed 's/\$${LOCK}/DGZL/g' $(CONFIGSRC) | sed 's/\$${NETWORK}/EC20/g' | sed 's/\$${DOMAIN}/${DOMAIN}/g' | sed 's/\$${PORT}/${PORT}/g' | sed 's/\$${MAIN}/${MAIN_VERSION}/g' | sed 's/\$${SUB}/${SUB_VERSION}/g' > $(CONFIG)
ifdef DEBUG
	sed -i 'a \DEBUG=1' $(CONFIG)
endif
ifdef ENGINEER_MODE
	sed -i 'a \ENGINEER_MODE=1' $(CONFIG)
endif
	cd $(BUILDDIR); make clean; make bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

/dev/shm/boxos-dgzl-esp8266-$(MAIN_VERSION).$(SUB_VERSION)-$(COMMIT)-$(DATE).bin: $(BUILDSRC) $(CARDREADERSRC) $(CONSOLESRC) $(CORESRC) $(CHARGERSRC) $(DRIVERSRC) $(EGGSRC) $(LOCKSRC) $(NETWORKSRC) $(UTILITYSRC) $(LEXFSMSRC) $(CHARGERFSMSRC) $(EC20FSMSRC) $(EC20SYNTAXFSMSRC) $(EGGFSMSRC) $(ENGINEERFSMSRC) $(ESP8266FSMSRC) $(ESP8266SYNTAXFSMSRC) $(LOCKBOARDFSMSRC) $(LOCKDGZLFSMSRC) $(UART3FSMSRC) $(UART4FSMSRC) $(UPSTREAMFSMSRC) $(CHARGERPROTOSCR) $(UART3PROTOSCR) $(LIBRARY) $(CONFIGSRC)
	sed 's/\$${LOCK}/DGZL/g' $(CONFIGSRC) | sed 's/\$${NETWORK}/ESP8266/g' | sed 's/\$${DOMAIN}/${DOMAIN}/g' | sed 's/\$${PORT}/${PORT}/g' | sed 's/\$${MAIN}/${MAIN_VERSION}/g' | sed 's/\$${SUB}/${SUB_VERSION}/g' > $(CONFIG)
ifdef DEBUG
	sed -i 'a \DEBUG=1' $(CONFIG)
endif
ifdef ENGINEER_MODE
	sed -i 'a \ENGINEER_MODE=1' $(CONFIG)
endif
	cd $(BUILDDIR); make clean; make bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

prebuild:
ifeq "$(wildcard $(BUILDDIR))" ""
	@mkdir -p $(BUILDDIR)
endif

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean flash prebuild release

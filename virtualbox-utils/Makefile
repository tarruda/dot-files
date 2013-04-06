TCP_SRC = tcp-command/tcp-command.c
TCP_EXE = build/tcp-command.exe

VBOX_SRC = vbox-tray-icon/vbox-tray-icon.c
VBOX_RC = vbox-tray-icon/resources/vbox-tray-icon.rc
VBOX_ICO = vbox-tray-icon/resources/vbox.ico
VBOX_RES = build/vbox-tray-icon.res
VBOX_EXE = build/vbox-tray-icon.exe

all: $(TCP_EXE) $(VBOX_EXE) $(VBOX_RES)

prepare:
	mkdir -p build

clean:
	rm -rf build

$(TCP_EXE): prepare $(TCP_SRC)
	$(CC) $(TCP_SRC) -o $(TCP_EXE) -Wall -DMINGW32 -lws2_32 

$(VBOX_EXE): prepare $(VBOX_SRC) $(VBOX_RES)
	$(CC) $(VBOX_SRC) $(VBOX_RES) -o $(VBOX_EXE) -mwindows -Wall -DMINGW32 -lshell32 

$(VBOX_RES): $(VBOX_ICO) $(VBOX_RC)
	i586-mingw32msvc-windres $(VBOX_RC) -O coff -o $(VBOX_RES)

.PHONY: all prepare clean

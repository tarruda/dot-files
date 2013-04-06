TCP_SRC = tcp-command.c
TCP_EXE = tcp-command.exe

VBOX_SRC = vbox-tray-icon.c
VBOX_RC = vbox-tray-icon.rc
VBOX_ICO = vbox.ico
VBOX_RES = vbox-tray-icon.res
VBOX_EXE = vbox-tray-icon.exe

all: $(TCP_EXE) $(VBOX_EXE) $(VBOX_RES)

$(TCP_EXE): $(TCP_SRC)
	$(CC) $(TCP_SRC) -o $(TCP_EXE) -Wall -DMINGW32 -lws2_32 

$(VBOX_EXE): $(VBOX_SRC) $(VBOX_RES)
	$(CC) $(VBOX_SRC) $(VBOX_RES) -o $(VBOX_EXE) -mwindows -Wall -DMINGW32 -lshell32 

$(VBOX_RES): $(VBOX_ICO) $(VBOX_RC)
	i586-mingw32msvc-windres $(VBOX_RC) -O coff -o $(VBOX_RES)

clean:
	rm -f $(TCP_EXE) $(VBOX_EXE) $(VBOX_RES)

.PHONY: all clean

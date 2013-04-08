SRC      = api.cpp main.cpp sdk/bindings/mscom/lib/VirtualBox_i.c
RC       = resources/resources.rc
ICO      = resources/vbox.ico
EXE      = VBoxTrayIcon.exe
RES      = resources.res
EXE64    = VBoxTrayIcon-x64.exe
RES64    = resources-x64.res
INC      = sdk/bindings/mscom/include
SDK      = sdk
SDK_URL  = http://download.virtualbox.org/virtualbox/4.2.10/VirtualBoxSDK-4.2.10-84104.zip


all: $(EXE) $(EXE64)

$(EXE): $(SRC) $(RES)
	i686-w64-mingw32-gcc $(SRC) $(RES) -o $(EXE) -I$(INC) -static\
 	-mwindows -Wall -DMINGW32 -lshell32 -lole32 -loleaut32 -lstdc++\
 	-lgcc

$(EXE64): $(SRC) $(RES64)
	x86_64-w64-mingw32-gcc $(SRC) $(RES64) -o $(EXE64) -I$(INC) -static\
	 	-mwindows -Wall -DMINGW64 -lshell32 -lole32 -loleaut32 -lstdc++\
	 	-lgcc

$(SRC): $(SDK)

$(SDK):
	wget $(SDK_URL) -O sdk.zip
	unzip sdk.zip

$(RES): $(ICO) $(RC)
	i686-w64-mingw32-windres $(RC) -O coff -o $(RES)

$(RES64): $(ICO) $(RC)
	x86_64-w64-mingw32-windres $(RC) -O coff -o $(RES64)

clean:
	rm -f *.res *.exe

.PHONY: clean

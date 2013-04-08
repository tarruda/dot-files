SRC     = api.cpp main.cpp sdk/bindings/mscom/lib/VirtualBox_i.c
RC      = resources/resources.rc
ICO     = resources/vbox.ico
RES     = resources.res
EXE     = vbox-tray-icon.exe
INC     = sdk/bindings/mscom/include
SDK     = sdk
SDK_URL = http://download.virtualbox.org/virtualbox/4.2.10/VirtualBoxSDK-4.2.10-84104.zip

all: $(EXE)

$(EXE): $(SRC) $(RES)
	i586-mingw32msvc-gcc $(SRC) $(RES) -o $(EXE) -mwindows -Wall -DMINGW32\
	 	-lshell32 -lole32 -loleaut32 -lstdc++

$(SRC): $(SDK)

$(SDK):
	wget $(SDK_URL) -O sdk.zip
	unzip sdk.zip

$(RES): $(ICO) $(RC)
	i586-mingw32msvc-windres $(RC) -O coff -o $(RES)

clean:
	rm -f *.res *.exe

.PHONY: clean

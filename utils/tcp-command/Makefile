TCP_SRC = tcp-command.c
TCP_EXE = build/tcp-command.exe


all: $(TCP_EXE)

prepare:
	mkdir -p build

clean:
	rm -rf build

$(TCP_EXE): prepare $(TCP_SRC)
	$(CC) $(TCP_SRC) -o $(TCP_EXE) -Wall -DMINGW32 -lws2_32 

.PHONY: all prepare clean

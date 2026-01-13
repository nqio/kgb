SRCC = build/build.c
ENDC = build/build.bin
COMPC = gcc

END = build/kgb.iso
COMP = ENDC
SIZE = 5000

all: $(END)

$(END): $(SRC)
	$(COMPC) $(SRCC) -o $(ENDC)
	$(COMP) -o $(END) -s $(SIZE)

clean:
	rm $(END) $(ENDC)

.PHONY: all clean

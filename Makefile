SRCC = build/build.c
ENDC = build/build.bin
COMPC = gcc

END = build/kgb.iso
FINAL_END = kernel.asm.cat
COMP = $(ENDC)
SIZE = 5000

all: $(END)

$(END): $(SRC)
	$(COMPC) $(SRCC) -o $(ENDC)
	$(COMP) -o $(END) -s $(SIZE)
	rm $(FINAL_END)

clean:
	rm $(END) $(ENDC)

.PHONY: all clean

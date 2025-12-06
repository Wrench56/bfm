ASM := nasm
ASMFLAGS := -Isrc -f bin
TARGET := bfm
SRC    := src/bfm.asm

all: $(TARGET)

$(TARGET): $(SRC)
	$(ASM) $(ASMFLAGS) -o $@ $<
	@chmod +x $(TARGET)

clean:
	rm -f $(TARGET)

run: $(TARGET)
	strace ./$(TARGET)

dump: $(TARGET)
	readelf -h $(TARGET)

.PHONY: all clean

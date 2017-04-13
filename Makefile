SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.o)
DEPS := $(OBJS:.o=.d)

CC = gcc
INCLUDES = -I./
CCFLAGS = -g -Wall -O0

TARGET = efipartition

$(TARGET) : $(OBJS)
	$(CC) $^ -o $@ $(INCLUDES)

%.o : %.c
	$(CC) -MMD -c $< $(CCFLAGS)

clean:
	rm $(TARGET)

-include $(DEPS)

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <unistd.h>

char readByte(int serial_port)
{
    char r;
    read(serial_port, &r, 1);
    return r;
}

void writeByte(int serial_port, unsigned char c)
{
    write(serial_port, &c, 1);
}

int writeMem(uint16_t m, int serial_port)
{
    uint8_t lsb = m & 0xFF;
    uint8_t msb = (m >> 8) & 0xFF;

    printf("Sending %02x%02x\n\r", msb, lsb);

    writeByte(serial_port, 'w');
    if (readByte(serial_port) != 'm')
    {
        printf("error!\n\r");
        return 1;
    }

    writeByte(serial_port, msb);
    if (readByte(serial_port) != 'l')
    {
        printf("error!\n\r");
        return 1;
    }
    writeByte(serial_port, lsb);
    unsigned char c = readByte(serial_port);
    if (c != msb)
    {
        printf("error msb %02x\n\r", c);
        return 1;
    }

    c = readByte(serial_port);
    if (c != lsb)
    {
        printf("error lsb %02x\n\r", c);
        return 1;
    }

    return 0;
}

int openPort(char portname[])
{
    int serial_port = open(portname, O_RDWR);

    if (serial_port < 0)
    {
        printf("Error %i from opening serial port: %s\n", errno, strerror(errno));
        return -1;
    }

    struct termios tty;
    if (tcgetattr(serial_port, &tty) != 0)
    {
        printf("Error %i from tcgetattr: %s\n", errno, strerror(errno));
        close(serial_port);
        return -1;
    }

    tty.c_cflag &= ~PARENB; // disable parity
    tty.c_cflag &= ~CSTOPB; // 1 stop bit

    // 8 bits per byte (most common)
    tty.c_cflag &= ~CSIZE;
    tty.c_cflag |= CS8;

    tty.c_cflag &= ~CRTSCTS; // disable hw flow control

    tty.c_cflag |= CREAD | CLOCAL; // enable read, ignore ctrl

    tty.c_lflag &= ~ICANON;                 // canon mode
    tty.c_lflag &= ~ECHO;                   // disable echo
    tty.c_lflag &= ~ECHOE;                  // disable erasure
    tty.c_lflag &= ~ECHONL;                 // disable new-line echo
    tty.c_lflag &= ~ISIG;                   // disable signal handling
    tty.c_iflag &= ~(IXON | IXOFF | IXANY); // disable xon/xoff flow control

    // disable interpretation
    tty.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL);
    tty.c_oflag &= ~OPOST;

    tty.c_oflag &= ~ONLCR; // disable conversion of nl to cr

    // configure blocking reads
    tty.c_cc[VTIME] = 0;
    tty.c_cc[VMIN] = 1;

    // set baud rate
    cfsetispeed(&tty, B9600);
    cfsetospeed(&tty, B9600);

    // save settings
    if (tcsetattr(serial_port, TCSANOW, &tty) != 0)
    {
        printf("Error %i from tcsetattr: %s\n", errno, strerror(errno));
        close(serial_port);
        return -1;
    }

    return serial_port;
}

int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        printf("Not enough arguments!\n\r");
        exit(-1);
    }

    FILE *memfile = fopen(argv[1], "r");

    if (!memfile)
    {
        fprintf(stdout, "Error opening file %s\n\r", argv[1]);
        exit(-1);
    }

    uint16_t mem[1536];
    int memsize = 0;
    char memline[10];
    while (fgets(memline, sizeof(memline), memfile))
    {
        if (memsize >= 1024)
        {
            printf("Program file is too large!\n\r");
            fclose(memfile);
        }
        uint16_t m;
        sscanf(memline, "%x", &m);
        mem[memsize++] = m;
    }
    fclose(memfile);

    int serial_port = openPort(argv[2]);

    if (serial_port < 0)
        exit(-1);

retry:
    writeByte(serial_port, 'r');

    printf("Waiting for toymcu bootloader... \n\r");
    while (readByte(serial_port) != 0x05)
        ;
    printf("ok\n\r");

    for (int i = 0; i < memsize; i++)
        if (writeMem(mem[i], serial_port))
            goto retry;

    printf("Done, launching program\n\r");
    writeByte(serial_port, 'e');

    close(serial_port);

    return 0;
}

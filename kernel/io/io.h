#ifndef IO_H
#define IO_H

unsigned char inb(unsigned short port);     //inb is used to read 1 byte of data from a port
unsigned short insw(unsigned short port);   //insw is used to read 2 bytes of data from a port
void outb(unsigned short port, unsigned char data);      //outb is used to send 1 byte of data to a port
void outw(unsigned short port, unsigned short *data, unsigned short count);  //outw is used to send 2 bytes of data to a port

#endif
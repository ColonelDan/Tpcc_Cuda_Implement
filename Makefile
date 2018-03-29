#
# desc : Makefile for cuda_tpcc project.
# date : 2018-3-28
# author : Xie Shangwei
#

# variables
CC 	= nvcc
#CC 	= gcc


cuda_tpcc : tpcc_main.o tpcc_table.o statistics_generator.o \
	    support.o

support.o : support.c 
	$(CC) -c support.c

statistics_generator.o : statistics.c
	$(CC) -c statistics.c

tpcc_table.o : tpcc_table.c
	$(cc) -c tpcc_table.c

.PHONY : clean
clean :
	-rm *.o




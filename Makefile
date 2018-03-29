#
# desc : Makefile for cuda_tpcc project.
# date : 2018-3-28
# author : Xie Shangwei
#

# variables
#CC 	= nvcc
CC 	= gcc


main : 	c_warehouse.o c_stock.o tpcc_main.o c_district.o c_customer.o \
	c_new_order.o c_order.o c_order_line.o c_item.o c_history.o tpcc_table.o
	$(CC) -o $@ c_warehouse.o c_stock.o c_district.o tpcc_main.o c_customer.o \
			c_new_order.o c_order.o c_order_line.o c_item.o c_history.o \
			tpcc_table.o
			

tpcc_main.o : tpcc_main.c
	$(CC) -c $<

c_warehouse.o : c_warehouse.c 
	$(CC) -c $<

c_stock.o : c_stock.c
	$(CC) -c $<

c_district.o : c_district.c
	$(CC) -c $<

c_customer.o : c_customer.c
	$(CC) -c $<

c_new_order.o : c_new_order.c
	$(CC) -c $<

c_order.o : c_order.c
	$(CC) -c $<

c_order_line.o : c_order_line.c
	$(CC) -c $<

c_item.o : c_item.c
	$(CC) -c $<

c_history.o : c_history.c
	$(CC) -c $<

tpcc_table.o : tpcc_table.c
	$(CC) -c $<

.PHONY : clean
clean :
	-rm *.o




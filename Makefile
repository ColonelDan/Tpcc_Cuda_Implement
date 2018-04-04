#
# desc : Makefile for cuda_tpcc project.
# date : 2018-3-28
# author : Xie Shangwei
#

# variables
CC 	= nvcc

# https://stackoverflow.com/questions/31006581/cuda-device-unresolved-extern-function
# https://blog.csdn.net/hxh1994/article/details/49621759
DEBUG_CC_FLAGS = -G -g -dc	
#CC 	= gcc

all: main

main : 	c_warehouse.o c_stock.o tpcc_main.o c_district.o c_customer.o \
	c_new_order.o c_order.o c_order_line.o c_item.o c_history.o tpcc_table.o utility.o\
	table_operator.o tx_stock_level.o
	$(CC) -G -g -o $@ c_warehouse.o c_stock.o c_district.o c_customer.o \
			c_new_order.o c_order.o c_order_line.o c_item.o c_history.o \
			tpcc_table.o tpcc_main.o utility.o table_operator.o \
			tx_stock_level.o
			

tpcc_main.o : tpcc_main.cu
	$(CC) $(DEBUG_CC_FLAGS) -c $<

c_warehouse.o : c_warehouse.cu 
	$(CC) $(DEBUG_CC_FLAGS) -c $<

c_stock.o : c_stock.cu
	$(CC) $(DEBUG_CC_FLAGS) -c $<

c_district.o : c_district.cu
	$(CC) $(DEBUG_CC_FLAGS) -c $<

c_customer.o : c_customer.cu
	$(CC) $(DEBUG_CC_FLAGS) -c $<

c_new_order.o : c_new_order.cu
	$(CC) $(DEBUG_CC_FLAGS) -c $<

c_order.o : c_order.cu
	$(CC) $(DEBUG_CC_FLAGS) -c $<

c_order_line.o : c_order_line.cu
	$(CC) $(DEBUG_CC_FLAGS) -c $<

c_item.o : c_item.cu
	$(CC) $(DEBUG_CC_FLAGS) -c $<

c_history.o : c_history.cu
	$(CC) $(DEBUG_CC_FLAGS) -c $<

tpcc_table.o : tpcc_table.cu
	$(CC) $(DEBUG_CC_FLAGS) -c $<

utility.o : utility.cu
	$(CC) $(DEBUG_CC_FLAGS) -c $<
	
table_operator.o : table_operator.cu
	$(CC) $(DEBUG_CC_FLAGS) -c $<

tx_stock_level.o : tx_stock_level.cu
	$(CC) $(DEBUG_CC_FLAGS) -c $<

.PHONY : clean
clean :
	-rm *.o




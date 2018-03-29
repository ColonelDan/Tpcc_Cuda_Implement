//
//  	desc: tpcc benchmark implementation in GPU
//	date: 2018-3-27
//	author: Xie Shangwei
//


#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include <cuda_runtime.h>

#include "tpcc_table.h"

void load_items();
void load_warehouses();
void load_orders();
void load_customers();

//get 9 tables.
struct warehouse h_warehouses[MAX_WAREHOUSE_NUM];
struct district h_districts[MAX_DISTRICT_NUM];
struct customer h_customers[MAX_CUSTOMER_NUM];
struct history h_hIstorys[MAX_HISTORY_NUM];
struct new_order h_neworders[MAX_NEWORDER_NUM];
struct order h_orders[MAX_ORDER_NUM];
struct order_line h_orderlines[MAX_ORDER_LINE];
struct item h_items[MAX_ITEM_NUM];
struct stoc h_stocks[MAX_STOCK_NUM];

//tables's slot flag, mark the slot is used or not.
char warehouse h_warehouses_flag[MAX_WAREHOUSE_NUM];
char district h_districts_flag[MAX_DISTRICT_NUM];   
char customer h_customers_flag[MAX_CUSTOMER_NUM];   
char history h_hIstorys_flag[MAX_HISTORY_NUM];      
char new_order h_neworders_flag[MAX_NEWORDER_NUM];  
char order h_orders_flag[MAX_ORDER_NUM];            
char order_line h_orderlines_flag[MAX_ORDER_LINE];  
char item h_items_flag[MAX_ITEM_NUM];               


int main(int argc, char **argv){
		
}



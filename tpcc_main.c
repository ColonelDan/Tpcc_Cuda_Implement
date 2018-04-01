//
//  	desc: tpcc benchmark implementation in GPU
//	date: 2018-3-27
//	author: Xie Shangwei
//


#include <stdlib.h>
#include <string.h>
#include <stdio.h>

//#include <cuda_runtime.h>

#include "tpcc_table.h"

int get_item(struct item *item_arr);
int get_warehouse(struct warehouse *warehouse_arr);
int get_order(struct order *order);
int get_customer(struct customer *c);
int get_new_order(struct new_order *n);
int get_order_line(struct order_line *o);
int get_district(struct district *d);
int get_stock(struct stock *s);
int get_history(struct history *h);


//get 9 tables.
struct warehouse h_warehouses[MAX_WAREHOUSE_NUM];
struct district h_districts[MAX_DISTRICT_NUM];
struct customer h_customers[MAX_CUSTOMER_NUM];
struct history h_historys[MAX_HISTORY_NUM];
struct new_order h_neworders[MAX_NEWORDER_NUM];
struct order h_orders[MAX_ORDER_NUM];
struct order_line h_orderlines[MAX_ORDER_LINE_NUM];
struct item h_items[MAX_ITEM_NUM];
struct stock h_stocks[MAX_STOCK_NUM];

//tables's slot flag, mark the slot is used or not.
char  h_warehouses_flag[MAX_WAREHOUSE_NUM];
char  h_districts_flag[MAX_DISTRICT_NUM];   
char  h_customers_flag[MAX_CUSTOMER_NUM];   
char  h_historys_flag[MAX_HISTORY_NUM];      
char  h_neworders_flag[MAX_NEWORDER_NUM];  
char  h_orders_flag[MAX_ORDER_NUM];            
char  h_orderlines_flag[MAX_ORDER_LINE_NUM];  
char  h_items_flag[MAX_ITEM_NUM];               
char  h_stocks_flag[MAX_ITEM_NUM];



void load_data();
//void cp_data_to_dev();
int main(int argc, char **argv){
	load_data();
	//struct warehouse *d_warehouse;
	//struct district *d_district;
	//cudaMalloc( (void **)&d_warehouse, sizeof(struct warehouse)*(MAX_WAREHOUSE_NUM));
	printf("ok\n");	

}

//void cp_data_to_dev(){
	
//}

void load_data(){
		int warehouse_num = get_warehouse(h_warehouses);
		int i;
		for(i = 0; i<warehouse_num ; i++){
			mark_slot_used( h_warehouses_flag, i);
		}
				
		int stock_num = get_stock(h_stocks);
		for( i = 0; i<stock_num; i++){
			mark_slot_used( h_stocks_flag, i);
		}

		int district_num = get_district(h_districts);
		for( i = 0; i<district_num; i++){
			mark_slot_used( h_districts_flag, i);
		}
		
		int customer_num = get_customer(h_customers);
		for( i = 0; i<customer_num; i++){
			mark_slot_used( h_customers_flag, i);
		}

			
		int new_order_num = get_new_order(h_neworders);
		for( i = 0; i<new_order_num; i++){
			mark_slot_used( h_neworders_flag, i);
		}
		
		int order_num = get_order(h_orders);
		for( i = 0; i<order_num; i++){
			mark_slot_used( h_orders_flag, i);
		}
	
		int order_line_num = get_order_line(h_orderlines);
		for( i = 0; i<order_line_num; i++){
			mark_slot_used( h_orderlines_flag, i);
		}
		
		int item_num = get_item(h_items);
		for( i = 0; i<item_num; i++){
			mark_slot_used( h_items_flag, i);
		}		
	
		int history_num = get_history(h_historys);
		for( i = 0; i<history_num; i++){
			mark_slot_used( h_historys_flag, i);
		}
}


//
//  	desc: tpcc benchmark implementation in GPU
//	date: 2018-3-27
//	author: Xie Shangwei
//


#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>

#include <cuda_runtime.h>
#include <curand_kernel.h>

#include "tpcc_table.h"
#include "utility.h"
#include "table_operator.h"
#include "tx.h"

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
struct stock h_stocks[MAX_STOCK_NUM];
struct item h_items[MAX_ITEM_NUM];

//tables's slot flag, mark the slot is used or not.
char  h_warehouses_flag[MAX_WAREHOUSE_NUM];
char  h_districts_flag[MAX_DISTRICT_NUM];   
char  h_customers_flag[MAX_CUSTOMER_NUM];   
char  h_historys_flag[MAX_HISTORY_NUM];      
char  h_neworders_flag[MAX_NEWORDER_NUM];  
char  h_orders_flag[MAX_ORDER_NUM];            
char  h_orderlines_flag[MAX_ORDER_LINE_NUM];  
char  h_items_flag[MAX_ITEM_NUM];               
char  h_stocks_flag[MAX_STOCK_NUM];

struct warehouse *h_d_warehouses;
struct district *h_d_districts;
struct customer *h_d_customers;
struct history *h_d_historys;
struct new_order *h_d_new_orders;
struct order *h_d_orders;
struct order_line *h_d_orderlines;
struct item *h_d_items;
struct stock *h_d_stocks;

char *h_d_warehouses_flag;
char *h_d_districts_flag;
char *h_d_customers_flag;
char *h_d_historys_flag;
char *h_d_new_orders_flag;
char *h_d_orders_flag;
char *h_d_orderlines_flag;
char *h_d_items_flag;
char *h_d_stocks_flag;

__device__ char *d_warehouses_flag;
__device__ char *d_districts_flag;
__device__ char *d_customers_flag;
__device__ char *d_historys_flag;
__device__ char *d_new_orders_flag;
__device__ char *d_orders_flag;
__device__ char *d_orderlines_flag;
__device__ char *d_items_flag;
__device__ char *d_stocks_flag;

__device__ struct warehouse *d_warehouses;
__device__ struct district *d_districts;
__device__ struct customer *d_customers;
__device__ struct history *d_historys;
__device__ struct new_order *d_new_orders;
__device__ struct order *d_orders;
__device__ struct order_line *d_orderlines;
__device__ struct item *d_items;
__device__ struct stock *d_stocks;

__global__
void cp_table_to_device(
	struct warehouse *h_d_warehouses,
	struct district *h_d_districts,
	struct customer *h_d_customers,
	struct history *h_d_historys,
	struct new_order *h_d_new_orders,
	struct order *h_d_orders,
	struct order_line *h_d_orderlines,
	struct item *h_d_items,
	struct stock *h_d_stocks);

__global__
void cp_flag_to_device(
	char *h_d_warehouses_flag,
	char *h_d_districts_flag,
	char *h_d_customers_flag,
	char *h_d_historys_flag,
	char *h_d_new_orders_flag,
	char *h_d_orders_flag,
	char *h_d_orderlines_flag,
	char *h_d_items_flag,
	char *h_d_stocks_flag);

__global__
void transaction_process(){
	//tx_stock_level();
	tx_new_order();
	tx_payment();
}

void load_data();
void cp_data_to_dev();

int main(int argc, char **argv){
	load_data();

	cp_data_to_dev();

	cp_table_to_device<<<1, 1>>>(
			h_d_warehouses,
			h_d_districts,
			h_d_customers,
			h_d_historys,
			h_d_new_orders,
			h_d_orders,
			h_d_orderlines,
			h_d_items,
			h_d_stocks);

	cp_flag_to_device<<<1, 1>>>(
			h_d_warehouses_flag,
			h_d_districts_flag,
			h_d_customers_flag,
			h_d_historys_flag,
			h_d_new_orders_flag,
			h_d_orders_flag,
			h_d_orderlines_flag,
			h_d_items_flag,
			h_d_stocks_flag);

	transaction_process<<<1, 1>>>();
	
	cudaMemcpy(h_warehouses_flag, h_d_warehouses_flag, sizeof(char)*MAX_WAREHOUSE_NUM, cudaMemcpyDeviceToHost);
	
	return 0;
}

void load_data(){
		int warehouse_num = get_warehouse(h_warehouses);
		int i;
		for(i = 0; i<warehouse_num ; i++){
			h_warehouses_flag[i] = 1;
		}

		int stock_num = get_stock(h_stocks);
		for( i = 0; i<stock_num ; i++){
			h_stocks_flag[i] = 1;
		}

		int district_num = get_district(h_districts);
		for( i = 0; i<district_num ; i++){
			h_districts_flag[i] = 1;
		}

		int customer_num = get_customer(h_customers);
		for( i = 0; i<customer_num ; i++){
			h_customers_flag[i] = 1;
		}

		int new_order_num = get_new_order(h_neworders);
		for( i = 0; i<new_order_num ; i++){
			h_neworders_flag[i] = 1;
		}

		int order_num = get_order(h_orders);
		for( i = 0; i<order_num ; i++){
			h_orders_flag[i] = 1;
		}

		int order_line_num = get_order_line(h_orderlines);
		for( i = 0; i<order_line_num ; i++){
			h_orderlines_flag[i] = 1;
		}

		int item_num = get_item(h_items);
		for( i = 0; i<item_num ; i++){
			h_items_flag[i] = 1;
		}

		int history_num = get_history(h_historys);
		for( i = 0; i<history_num ; i++){
			h_historys_flag[i] = 1;
		}
		printf("load data succeed!\n");
}

void cp_data_to_dev(){
	cudaMalloc( (void **)&h_d_warehouses, sizeof(struct warehouse)*(MAX_WAREHOUSE_NUM));
	cudaMalloc( (void **)&h_d_districts,  sizeof(struct district)*(MAX_DISTRICT_NUM));
	cudaMalloc( (void **)&h_d_customers,  sizeof(struct customer)*(MAX_CUSTOMER_NUM));
	cudaMalloc( (void **)&h_d_historys,  sizeof(struct history)*(MAX_HISTORY_NUM));
	cudaMalloc( (void **)&h_d_new_orders,  sizeof(struct new_order)*(MAX_NEWORDER_NUM));
	cudaMalloc( (void **)&h_d_orders,  sizeof(struct order)*(MAX_ORDER_NUM));
	cudaMalloc( (void **)&h_d_orderlines,  sizeof(struct order_line)*(MAX_ORDER_LINE_NUM));
	cudaMalloc( (void **)&h_d_items,  sizeof(struct item)*(MAX_ITEM_NUM));
	cudaMalloc( (void **)&h_d_stocks,  sizeof(struct stock)*(MAX_STOCK_NUM));

	cudaMalloc( (void **)&h_d_warehouses_flag, sizeof(char)*MAX_WAREHOUSE_NUM);
	cudaMalloc( (void **)&h_d_districts_flag, sizeof(char)*MAX_DISTRICT_NUM);
	cudaMalloc( (void **)&h_d_customers_flag, sizeof(char)*MAX_CUSTOMER_NUM);
	cudaMalloc( (void **)&h_d_historys_flag, sizeof(char)*MAX_HISTORY_NUM);
	cudaMalloc( (void **)&h_d_new_orders_flag, sizeof(char)*MAX_NEWORDER_NUM);
	cudaMalloc( (void **)&h_d_orders_flag, sizeof(char)*MAX_ORDER_NUM);
	cudaMalloc( (void **)&h_d_orderlines_flag, sizeof(char)*MAX_ORDER_LINE_NUM);
	cudaMalloc( (void **)&h_d_items_flag, sizeof(char)*MAX_ITEM_NUM);
	cudaMalloc( (void **)&h_d_stocks_flag, sizeof(char)*MAX_STOCK_NUM);
	printf("device memory allocate succeed.\n");	

	cudaMemcpy(h_d_warehouses, h_warehouses, sizeof(struct warehouse)*(MAX_WAREHOUSE_NUM), cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_districts, h_districts, sizeof(struct district)*MAX_DISTRICT_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_customers, h_customers, sizeof(struct customer)*MAX_CUSTOMER_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_historys, h_historys, sizeof(struct history)*MAX_HISTORY_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_new_orders, h_neworders, sizeof(struct new_order)*MAX_NEWORDER_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_orders, h_orders, sizeof(struct order)*MAX_ORDER_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_orderlines, h_orderlines, sizeof(struct order_line)*MAX_ORDER_LINE_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_items, h_items, sizeof(struct item)*MAX_ITEM_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_stocks, h_stocks, sizeof(struct stock)*MAX_STOCK_NUM, cudaMemcpyHostToDevice);
	
	cudaMemcpy(h_d_warehouses_flag, h_warehouses_flag, sizeof(char)*(MAX_WAREHOUSE_NUM), cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_districts_flag, h_districts_flag, sizeof(char)*MAX_DISTRICT_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_customers_flag, h_customers_flag, sizeof(char)*MAX_CUSTOMER_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_historys_flag, h_historys_flag, sizeof(char)*MAX_HISTORY_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_new_orders_flag, h_neworders_flag, sizeof(char)*MAX_NEWORDER_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_orders_flag, h_orders_flag, sizeof(char)*MAX_ORDER_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_orderlines_flag, h_orderlines_flag, sizeof(char)*MAX_ORDER_LINE_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_items_flag, h_items_flag, sizeof(char)*MAX_ITEM_NUM, cudaMemcpyHostToDevice);
	cudaMemcpy(h_d_stocks_flag, h_stocks_flag, sizeof(char)*MAX_STOCK_NUM, cudaMemcpyHostToDevice);
	printf("memcpy succeed.\n");
}

__global__
void cp_table_to_device(
	struct warehouse *h_d_warehouses,
	struct district *h_d_districts,
	struct customer *h_d_customers,
	struct history *h_d_historys,
	struct new_order *h_d_new_orders,
	struct order *h_d_orders,
	struct order_line *h_d_orderlines,
	struct item *h_d_items,
	struct stock *h_d_stocks){

	d_warehouses = h_d_warehouses;
	d_districts = h_d_districts;
	d_customers = h_d_customers;
	d_historys = h_d_historys;
	d_new_orders = h_d_new_orders;
	d_orders = h_d_orders;
	d_orderlines = h_d_orderlines;
	d_items = h_d_items;
	d_stocks = h_d_stocks;
}

__global__
void cp_flag_to_device(
	char *h_d_warehouses_flag,
	char *h_d_districts_flag,
	char *h_d_customers_flag,
	char *h_d_historys_flag,
	char *h_d_new_orders_flag,
	char *h_d_orders_flag,
	char *h_d_orderlines_flag,
	char *h_d_items_flag,
	char *h_d_stocks_flag){

	d_warehouses_flag = h_d_warehouses_flag;
	d_districts_flag = h_d_districts_flag;
	d_customers_flag = h_d_customers_flag;
	d_historys_flag = h_d_historys_flag;
	d_new_orders_flag = h_d_new_orders_flag;
	d_orders_flag = h_d_orders_flag;
	d_orderlines_flag = h_d_orderlines_flag;
	d_items_flag = h_d_items_flag;
	d_stocks_flag = h_d_stocks_flag;
}

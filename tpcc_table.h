//
//	desc: head file the 9 table in tpcc.
//	date: 2018-3-27
//	author: Xie Shangwei
//
//
#ifndef TPCC_TABLE_H
#define TPCC_TABLE_H

#define MAX_WAREHOUSE_NUM 10
#define MAX_STOCK_NUM (MAX_WAREHOUSE_NUM*100000)
#define MAX_DISTRICT_NUM  ( MAX_WAREHOUSE_NUM*10 )
#define MAX_CUSTOMER_NUM (MAX_WAREHOUSE_NUM*30000)
#define MAX_HISTORY_NUM (MAX_WAREHOUSE_NUM*30000)
#define MAX_NEWORDER_NUM (MAX_WAREHOUSE_NUM*9000)
#define MAX_ITEM_NUM (100000)
#define MAX_ORDER_NUM (MAX_WAREHOUSE_NUM*30000)
#define	MAX_ORDER_LINE_NUM (MAX_WAREHOUSE_NUM*300000) 

// table_type
#define	WAREHOUSE 0
#define	STOCK 1
#define	DISTRICT 2
#define	CUSTOMER 3
#define HISTORY 4
#define	NEW_ORDER 5
#define	ITEM 6
#define	ORDER 7
#define	ORDER_LINE 8
// attribution type
#define LONG 0
#define DOUBLE 1
#define INT 2
#define STR 3

// operation type
#define EQ 0	// equal
#define LT 1    // less than
#define GT 2	// greater than
#define LE 3	// less than or equal
#define GE 4 	// greater than or equal
#define NE 5 	// not equal
#define NO 6	// no comparison



// define warehouse 
// primary :W_ID
struct warehouse
{	
	long W_ID ; //warehous id. 		
	char W_NAME[10+1] ; // warehouse name.
	char W_STREET_1[20+1] ; // address 1.
	char W_STREET_2[20+1] ; // address 2.
	char W_CITY[20+1]	; // city.
	char W_STATE[2+1] ; // state.
	char W_ZIP[9+1] ; // zip number.
 	double W_TAX ; // sale tax.
	double W_YTD ; // year to date balance.
};

// define distric
// primary key: D_W_ID. D_ID
// D_W_ID foreign key. references W_ID
struct district
{
	long D_ID; 
	long D_W_ID; // reference to warehouse.
	char D_NAME[10+1]; 
	char D_STREET_1[20+1];
	char D_STREET_2[20+1];
	char D_CITY[20+1];
	char D_STATE[2+1];
	char D_ZIP[9+1];
	double D_TAX;
	double D_YTD;
	
	long D_NEXT_O_ID ; //next order id.
};

// define customer
struct customer
{
	long C_ID ; 
	long C_D_ID ; 
	long C_W_ID ; 
	char C_FIRST[16+1] ;//  first name .
	char C_MIDDLE[2+1] ; // middle name.
	char C_LAST[16+1] ; // last name.
	char C_STREET_1[20+1] ; //
	char C_STREET_2[20+1] ; //
	char C_CITY[20+1] ; //
	char C_STATE[2+1] ;
	char C_ZIP[9+1] ;
	char C_PHONE[16+1] ;
	long C_SINCE ;	//register time.
	char C_CREDIT[2+1]; // "GC" = good , "BC" = bad
	double C_CREDIT_LIM; //
	double C_DISCOUNT ; //
	double C_BALANCE ;
	double C_YTD_PAYMENT;
	double C_PAYMENT_CNT;
	double C_DELIVERY_CNT;
	char C_DATA[500+1];	//
};

// define table history
struct history
{
	long H_C_ID;
	long H_C_D_ID;
	long H_C_W_ID;
	long H_D_ID;
	long H_W_ID;
 	long H_DATE;
	double H_AMOUNT;
	char H_DATA[24+1];

};

// define table new_order.
struct new_order
{
	long NO_O_ID;
	long NO_D_ID;
	long NO_W_ID;
};

// define table order
struct order
{
	long O_ID;
	long O_D_ID;
	long O_W_ID;
	long O_C_ID;
	long O_ENTRY_DATE;
	long O_CARRIER_ID;
	int O_OL_CNT;
	int O_ALL_LOCAL;
};

// define order_line
struct order_line
{
	long OL_O_ID;
	long OL_D_ID;
	long OL_W_ID;
	long OL_NUMBER;
	long OL_I_ID;
	long OL_SUPPLY_W_ID;
	long OL_DELIVERY_D;
	double OL_QUANTITY;
	double OL_AMOUNT;
	char OL_DIST_INFO[25];
};

// define item.
struct item
{
	long I_ID;
	long I_IM_ID;
	char I_NAME[25+1];
	double I_PRICE;
	char I_DATA[50+1];
};

// define stock
struct stock
{
	long S_I_ID;
	long S_W_ID;
	double S_QUANTITY;
 	char S_DIST_01[24+1];
 	char S_DIST_02[24+1];
 	char S_DIST_03[24+1];
 	char S_DIST_04[24+1];
 	char S_DIST_05[24+1];
 	char S_DIST_06[24+1];
 	char S_DIST_07[24+1];
 	char S_DIST_08[24+1];
 	char S_DIST_09[24+1];
 	char S_DIST_10[24+1];
	double S_YTD;
	double S_ORDER_CNT;
	double S_REMOTE_CNT;
	char S_DATA[51];
};


//get 9 tables.
extern struct warehouse h_warehouses[MAX_WAREHOUSE_NUM];
extern struct district h_districts[MAX_DISTRICT_NUM];
extern struct customer h_customers[MAX_CUSTOMER_NUM];
extern struct history h_historys[MAX_HISTORY_NUM];
extern struct new_order h_neworders[MAX_NEWORDER_NUM];
extern struct order h_orders[MAX_ORDER_NUM];
extern struct order_line h_orderlines[MAX_ORDER_LINE_NUM];
extern struct stock h_stocks[MAX_STOCK_NUM];
extern struct item h_items[MAX_ITEM_NUM];

//tables's slot flag, mark the slot is used or not.
extern char  h_warehouses_flag[MAX_WAREHOUSE_NUM];
extern char  h_districts_flag[MAX_DISTRICT_NUM];
extern char  h_customers_flag[MAX_CUSTOMER_NUM];
extern char  h_historys_flag[MAX_HISTORY_NUM];
extern char  h_neworders_flag[MAX_NEWORDER_NUM];
extern char  h_orders_flag[MAX_ORDER_NUM];
extern char  h_orderlines_flag[MAX_ORDER_LINE_NUM];
extern char  h_items_flag[MAX_ITEM_NUM];
extern char  h_stocks_flag[MAX_STOCK_NUM];

extern struct warehouse *h_d_warehouses;
extern struct district *h_d_districts;
extern struct customer *h_d_customers;
extern struct history *h_d_historys;
extern struct new_order *h_d_new_orders;
extern struct order *h_d_orders;
extern struct order_line *h_d_orderlines;
extern struct item *h_d_items;
extern struct stock *h_d_stocks;
 
 extern char *h_d_warehouses_flag;
 extern char *h_d_districts_flag;
 extern char *h_d_customers_flag;
 extern char *h_d_historys_flag;
 extern char *h_d_new_orders_flag;
 extern char *h_d_orders_flag;
 extern char *h_d_orderlines_flag;
 extern char *h_d_items_flag;
 extern char *h_d_stocks_flag;

 extern __device__ char *d_warehouses_flag;
 extern __device__ char *d_districts_flag;
 extern __device__ char *d_customers_flag;
 extern __device__ char *d_historys_flag;
 extern __device__ char *d_new_orders_flag;
 extern __device__ char *d_orders_flag;
 extern __device__ char *d_orderlines_flag;
 extern __device__ char *d_items_flag;
 extern __device__ char *d_stocks_flag;
 extern __device__ struct warehouse *d_warehouses;
 extern __device__ struct district *d_districts;
 extern __device__ struct customer *d_customers;
 extern __device__ struct history *d_historys;
 extern __device__ struct new_order *d_new_orders;
 extern __device__ struct order *d_orders;
 extern __device__ struct order_line *d_orderlines;
 extern __device__ struct item *d_items;
 extern __device__ struct stock *d_stocks;
//

__device__
int get_free_slot(char *slot_flag_arry, int table_type);

__device__
void mark_slot_used(char *slot_flag_arry, int slot_id);

__device__
void mark_slot_free(char *slot_flag_arry, int slot_id);

#endif 




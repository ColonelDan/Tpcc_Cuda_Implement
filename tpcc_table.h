//
//	desc: head file the 9 table in tpcc.
//	date: 2018-3.27
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
//

// define warehouse 
// primary :W_ID
struct warehouse
{	
	int W_ID ; //warehous id. 		
	char W_NAME[10] ; // warehouse name.
	char W_STREET_1[20] ; // address 1.
	char W_STREET_2[20] ; // address 2.
	char W_CITY[20]	; // city.
	char W_STATE[2] ; // state.
	char W_ZIP[9] ; // zip number.
	float W_TAX ; // sale tax.
	float W_YTD ; // year to date balance.
};

// define distric
// primary key: D_W_ID. D_ID
// D_W_ID foreign key. references W_ID
struct district
{
	int D_ID; 
	int D_W_ID; // reference to warehouse.
	char D_NAME[10]; 
	char D_STREET_1[10];
	char D_STREET_2[20];
	char D_CITY[20];
	char D_STATE[2];
	char D_ZIP[9];
	float D_TAX;
	float D_YTD;
	
	int D_NEXT_O_ID ; //next order id.
};

// define customer
struct customer
{
	long C_ID ; 
	long C_D_ID ; 
	long C_W_ID ; 
	char C_FIRST[16] ;//  first name .
	char C_MIDDLE[2] ; // middle name.
	char C_LAST[16] ; // last name.
	char C_STREET_1[20] ; //
	char C_STREET_2[20] ; //
	char C_CITY[20] ; //
	char C_STATE[2] ;
	char C_ZIP[9] ;
	char C_PHONE[16] ;
	long C_SINCE ;	//register time.
	char C_CREDIT[2]; // "GC" = good , "BC" = bad
	double C_CREDIT_LIM; //
	double C_DISCOUNT ; //
	double C_BALANCE ;
	double C_YTD_PAYMENT;
	double C_PAYMENT_CNT;
	double C_DELIVERY_CNT;
	char C_DATA[500];	//
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
	char H_DATA;

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
};

// define item.
struct item
{
	long I_ID;
	long I_IM_ID;
	char I_NAME[25];
	double I_PRICE;
	char I_DATA[50];
};

// define stock
struct stock
{
	long S_I_ID;
	long S_W_ID;
	double S_QUANTITY;
 	char S_DIST_01[24];
 	char S_DIST_02[24];
 	char S_DIST_03[24];
 	char S_DIST_04[24];
 	char S_DIST_05[24];
 	char S_DIST_06[24];
 	char S_DIST_07[24];
 	char S_DIST_08[24];
 	char S_DIST_09[24];
 	char S_DIST_10[24];
	double S_YTD;
	double S_ORDER_CNT;
	double S_REMOTE_CNT;

};

//
// desc : get a free slot id from the table.
// intput : slot flag arry , table type.
// output : the slot id or -1 if there is no
// 	    free slot exists.
//
int get_free_slot(char *slot_flag_arry, int table_type);

//
// desc : mark the slot as used by slot id.
//
void mark_slot_used(char *slot_flag_array, int slot_id);

//
// desc : mark the slot as freed by slot id.
//

void mark_slot_free(char *slot_flag_array, int slot_id);



#endif 




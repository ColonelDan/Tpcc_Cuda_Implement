//
// desc: transaction delivery.
// date: 2018-4-8
// author: Xie Shangwei
//
//

#include <stdio.h>

#include <curand_kernel.h>
#include <cuda_runtime.h>

#include "tpcc_table.h"
#include "tx.h"
#include "utility.h"
#include "table_operator.h"


__device__
void tx_delivery(){
	printf("transaction : delivery.\n");

	long D_ID;
	long W_ID;
	long D_W_ID;
	long O_CARRIER_ID;

	//generate parameters.
	int rid = d_random(0, 20);
	struct district *dis_p;
	rid = table_scan(DISTRICT, LONG, 0, 0, NO, NULL, rid);

	if(rid != -1)
		dis_p = (struct district *)get(DISTRICT, rid);
	else{
		printf("rid = -1, can not get the content.\n");
	}
	//dis_p = (struct district *)content;
	//printf("ok\n");
	//d_memcpy(&tmp_district, content, sizeof(struct district));
	D_W_ID = dis_p->D_W_ID;
	D_ID = dis_p->D_ID;
	W_ID = D_W_ID;
	O_CARRIER_ID = d_random(1, 11);

	printf("D_ID %ld\n", dis_p->D_ID);

	printf("parameters:\n");
	printf("D_W_ID : %ld\n", D_W_ID);
	printf("D_ID : %ld\n", D_ID);
	printf("W_ID : %ld\n", W_ID);
	printf("O_CARRIER_ID : %ld\n", O_CARRIER_ID);
	// transaction begin.
	// first step.
	struct new_order tmp_no;
	struct new_order *no_p;
	int offset_DID = (long)&tmp_no.NO_D_ID - (long)&tmp_no.NO_O_ID;
	int start_id = 0;
	rid = table_scan(NEW_ORDER, LONG , 0, offset_DID, EQ, &D_ID, start_id);
	while(rid != -1){
		no_p = (struct new_order *)get(NEW_ORDER, rid);
		if(no_p->NO_W_ID == W_ID){
			break;
		}
	}
	if(rid == -1)
		printf("there is no new_order satisfy condition\n");
	long NO_O_ID = no_p->NO_O_ID;
	printf("NO_O_ID : %ld\n", NO_O_ID);
	//return ;
	// delete record in the new_order table.
	struct order *or_p;
	start_id = 0;
	//int offset_O_D_ID = (long)&tmp_or.O_D_ID - (long)&tmp_or.O_ID;
	rid = table_scan(ORDER, LONG, 0, 0, EQ, &NO_O_ID, start_id);
	// printf("rid : %d\n", rid);
	// 	or_p = (struct order *)get(ORDER, rid);
	// 	printf(" wid : %ld , did : %ld, customer_id : %ld\n, ", or_p->O_W_ID, or_p->O_D_ID, or_p->O_C_ID);
	//return;
	while(rid != -1){
		or_p = (struct order *)get(ORDER, rid);
		if(or_p->O_W_ID == W_ID &&
			or_p->O_D_ID == D_ID ){
		//	printf("to be break\n");
			break;
		}
		//printf("wont break\n");
		rid = table_scan(ORDER, LONG, 0, 0, EQ, &NO_O_ID, rid+1);
		//printf("here rid = %ld\n", rid);
	}
	//printf("rid = %ld\n", rid);
	//return;
	if(rid == -1)
		printf("there is no record in table order satisfy condition.\n");
	long O_C_ID = or_p->O_C_ID;
	printf("O_C_ID : %ld\n", O_C_ID);
	//int offse_O_CARRIER_ID = (long)&tmp_or.O_CARRIER_ID - (long)&tmp_or.O_ID;
	//d_memcpy((void *)or_p+offse_O_CARRIER_ID, &O_CARRIER_ID, sizeof(long));
	or_p->O_CARRIER_ID = O_CARRIER_ID;
	printf("after set , carrier id is : %ld\n", (struct order *)or_p->O_CARRIER_ID);


	// next step operate in table order_line.
	start_id = 0;
	struct order_line *orl_p;
	//int offset_OL_W_ID = (long)&tmp_orl.OL_W_ID - (long)&tmp_orl.OL_O_ID;
	double sum_of_amout = 0;
	rid = table_scan(ORDER_LINE, LONG, 0, 0, EQ, &NO_O_ID, start_id);
	printf("order line rid = %ld\n", rid);
	//return;
	while(rid != -1){
		orl_p = (struct order_line *)get(ORDER_LINE, rid);
		if(orl_p->OL_D_ID == D_ID &&
			orl_p->OL_W_ID == W_ID ){
			orl_p -> OL_DELIVERY_D = 1234567;
			sum_of_amout += orl_p->OL_AMOUNT;
			//printf("here rid = %ld, amout : %lf\n", rid, orl_p->OL_AMOUNT);
		}
		rid = table_scan(ORDER_LINE, LONG, 0, 0, EQ, &NO_O_ID, rid+1);

	}
	printf("the OL_AMOUNT : %lf\n", sum_of_amout);
	//return;

	start_id = 0;
	struct customer *cus_p;
	//int offset_C_W_ID = (long)&cus.C_W_ID - (long)&cus.C_ID;
	rid = table_scan(CUSTOMER, LONG, 0, 0, EQ, &O_C_ID, start_id);
	//return;
	while(rid != -1){
		cus_p = (struct customer *)get(CUSTOMER, rid);
		if(cus_p->C_W_ID == W_ID &&
			cus_p->C_D_ID == D_ID){
			cus_p->C_BALANCE += sum_of_amout;
			cus_p->C_DELIVERY_CNT++;
			//printf("custmer rid : %d\n", rid);
			break;
		}
		rid = table_scan(CUSTOMER, LONG, 0, 0, EQ, &O_C_ID, rid+1);
	}
	if(rid == -1)
		printf("there is no record satisfy condition.\n");
	printf("customer id : %d\n", rid);
	printf("delivery process over!\n");
}
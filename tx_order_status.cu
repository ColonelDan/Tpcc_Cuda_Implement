#include <stdio.h>

#include <curand_kernel.h>
#include <cuda_runtime.h>

#include "tpcc_table.h"
#include "tx.h"
#include "utility.h"
#include "table_operator.h"

#define MAX_PRINT_ORDER_LINE 1000

//test for order_status transaction!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

__device__
void tx_order_status(){
	//输入的数据
	long os_C_W_ID=1;	long os_C_D_ID=3;	long os_C_ID=3;	//customer ID


	//事务启动
	printf("Order Status Transaction is start!\n");


	//在客户表（customers）中查询客户代码（C_W_ID,C_D_ID,C_ID）。
	struct customer customer_tmp;
	struct customer *p_customer_tmp;
	int rid_in_customers=0;
	while(1){
		rid_in_customers = table_scan(CUSTOMER, LONG, sizeof(long int), ((long)&(customer_tmp.C_W_ID)-(long)&(customer_tmp.C_ID)), EQ, &os_C_W_ID, rid_in_customers);	//扫描整张customer表找出C_W_ID为os_C_W_ID的记录号
		if(rid_in_customers == -1){	//customers中没有os_C_W_ID对应的记录 
			printf("Transaction Exception:\tC_W_ID is not in customer table!\n");
			return;
		}
		p_customer_tmp=(struct customer *)get(CUSTOMER, rid_in_customers);	//获取os_C_W_ID对应的记录
		if(p_customer_tmp->C_D_ID == os_C_D_ID && p_customer_tmp->C_ID == os_C_ID){	//customers中有os_C_W_ID,os_C_D_ID,os_C_ID对应的记录
			break;
		}else{
			rid_in_customers++;
		}
	}
	printf("rid_in_customers:%d\tC_W_ID:%ld\tC_D_ID:%ld\tC_ID:%ld\tC_FIRST:%s\tC_MIDDLE:%s\tC_LAST:%s\tC_BALANCE:%lf\n",
		rid_in_customers,
		p_customer_tmp->C_W_ID,
		p_customer_tmp->C_D_ID,
		p_customer_tmp->C_ID,
		p_customer_tmp->C_FIRST,	//取姓名
		p_customer_tmp->C_MIDDLE,
		p_customer_tmp->C_LAST,
		p_customer_tmp->C_BALANCE);	//欠款余额


	//在定单表（orders）中查询仓库代码（O_W_ID）、地区代码（O_D_ID）、客户代码（O_C_ID），并且定单代码（O_ID）最大的记录。
	struct order order_tmp;
	struct order *p_order_tmp;
	int rid_in_orders=0;
	int os_rid_in_orders_max=-1;
	long os_O_ID_max=-1;
	while(1){
		rid_in_orders = table_scan(ORDER, LONG, sizeof(long int), ((long)&(order_tmp.O_W_ID)-(long)&(order_tmp.O_ID)), EQ, &os_C_W_ID, rid_in_orders);	//扫描整张order表找出O_W_ID为os_C_W_ID的记录号
		if(rid_in_orders == -1){
			break;
		}
		p_order_tmp=(struct order *)get(ORDER, rid_in_orders);	//获取os_C_W_ID对应的记录
		if(p_order_tmp->O_D_ID == os_C_D_ID && p_order_tmp->O_C_ID == os_C_ID && p_order_tmp->O_ID > os_O_ID_max){
			os_rid_in_orders_max=rid_in_orders;
			os_O_ID_max=p_order_tmp->O_ID;
			rid_in_orders++;
		}else{
			rid_in_orders++;
		}
	}
	if(os_rid_in_orders_max == -1){	//orders中没有(os_C_W_ID、os_C_D_ID、os_C_ID)对应的记录 
		printf("Transaction Exception:\thave not found right record in order table!\n");
		return;
	}else{
		p_order_tmp=(struct order *)get(ORDER, os_rid_in_orders_max);
		printf("rid_in_orders:%d\tO_ID:%ld\tO_ENTRY_DATE:%ld\tO_CARRIER_ID:%ld\n", 
			os_rid_in_orders_max,
			p_order_tmp->O_ID,	//取定单代码
			p_order_tmp->O_ENTRY_DATE,	//制单日期
			p_order_tmp->O_CARRIER_ID);	//货运代码
	}


	//在定单分录表（orderlines）中查询满足仓库代码（OL_W_ID）、地区代码（OL_D_ID）、定单代码（OL_O_ID）条件的所有记录。
	struct order_line orderline_tmp;
	struct order_line *p_orderline_tmp;
	int rid_in_orderlines=0;
	struct order_line orderline_arr[MAX_PRINT_ORDER_LINE];
	int count=0;
	while(1){
		rid_in_orderlines = table_scan(ORDER_LINE, LONG, sizeof(long int), ((long)&(orderline_tmp.OL_W_ID)-(long)&(orderline_tmp.OL_O_ID)), EQ, &os_C_W_ID, rid_in_orderlines);	//扫描整张orderlines表找出C_W_ID为os_C_W_ID的记录号
		if(rid_in_orderlines == -1){
			break;
		}
		p_orderline_tmp=(struct order_line *)get(ORDER_LINE, rid_in_orderlines);	//获取os_C_W_ID对应的记录
		if(p_orderline_tmp->OL_D_ID == os_C_D_ID && p_orderline_tmp->OL_O_ID == p_order_tmp->O_ID){
			d_memcpy(&(orderline_arr[count]),p_orderline_tmp,sizeof(struct order_line));
			count++;
			if(count==MAX_PRINT_ORDER_LINE){
				break;
			}
			rid_in_orderlines++;
		}else{
			rid_in_orderlines++;
		}
	}
	if(count==0){
		printf("Transaction Exception:\thave not found right record in orderline table!\n");
		return;
	}else{
		int i,j,k;
		for(i=0;i<count;i++){	//根据商品代码排序并输出
			k=i;
			for(j=i+1;j<count;j++){
				if(orderline_arr[j].OL_I_ID>orderline_arr[k].OL_I_ID){
					k=j;
				}
			}
			if(i!=k){
				d_memcpy(&orderline_tmp,&orderline_arr[i],sizeof(struct order_line));
				d_memcpy(&orderline_arr[i],&orderline_arr[k],sizeof(struct order_line));
				d_memcpy(&orderline_arr[k],&orderline_tmp,sizeof(struct order_line));
			}
			printf("OL_I_ID:%ld\tOL_SUPPLY_W_ID:%ld\tOL_QUANTITY:%lf\tOL_AMOUNT:%lf\tOL_DELIVERY_D:%ld\n",
				orderline_arr[i].OL_I_ID,
				orderline_arr[i].OL_SUPPLY_W_ID,	//供应仓库代码
				orderline_arr[i].OL_QUANTITY,	//数量
				orderline_arr[i].OL_AMOUNT,	//金额
				orderline_arr[i].OL_DELIVERY_D);	//发货时间
		}
	}


	//事务提交 
	printf("Order Status Transaction is finished!\n");
}
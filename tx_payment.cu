#include <stdio.h>

#include <curand_kernel.h>
#include <cuda_runtime.h>

#include "tpcc_table.h"
#include "tx.h"
#include "utility.h"
#include "table_operator.h"

//test for payment transaction!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

__device__
void tx_payment(){
	//输入的数据
	long pay_W_ID=1;	//warehouse ID
	long pay_D_W_ID=1;	long pay_D_ID=3;	//district ID
	long pay_C_W_ID=1;	long pay_C_D_ID=3;	long pay_C_ID=3;	//customer ID
	double pay_H_AMOUNT=52.0;	//支付金额


	//事务启动
	printf("Payment Transaction is start!\n");


	//在仓库表（warehouses）中查询仓库代码（W_ID）。取名称（W_NAME）、地址1（W_STREET_1）、地址2（W_STREET_2）、城市（W_CITY）、州（W_STATE）、邮政编码（W_ZIP）、累计发生额（W_YTD）。
	struct warehouse warehouse_tmp;	//为了求attr_offset 
	int rid_in_warehouses=0;
	//int table_scan(int table_type, int attr_type, int attr_size, int attr_offset, int op, void *value, int r_id);
	rid_in_warehouses= table_scan(WAREHOUSE, LONG, sizeof(long int), ((long)&(warehouse_tmp.W_ID)-(long)&(warehouse_tmp)), EQ, &pay_W_ID, rid_in_warehouses);	//扫描整张warehouses表找出W_ID为pay_W_ID的记录号 
	if(rid_in_warehouses==-1){	//warehouses中没有pay_W_ID对应的记录 
		printf("Transaction Exception:\tW_ID is not in warehouse table!");
		return;
	}
	struct warehouse *p_warehouse_tmp =(struct warehouse *)get(WAREHOUSE, rid_in_warehouses);	//获取no_W_ID对应的记录
	printf("rid_in_warehouses:%d\tW_ID:%ld\tW_NAME:%s\tW_STREET_1:%s\tW_STREET_2:%s\tW_CITY:%s\tW_STATE:%s\tW_ZIP:%s\tW_YTD:%lf\n",
		rid_in_warehouses,
		p_warehouse_tmp->W_ID,
		p_warehouse_tmp->W_NAME,	//取名称（W_NAME）
		p_warehouse_tmp->W_STREET_1,	//地址1（W_STREET_1）
		p_warehouse_tmp->W_STREET_2,	//地址2（W_STREET_2）
		p_warehouse_tmp->W_CITY,	//城市（W_CITY）
		p_warehouse_tmp->W_STATE,	//州（W_STATE）
		p_warehouse_tmp->W_ZIP,	//邮政编码（W_ZIP）
		p_warehouse_tmp->W_YTD);	//取累计发生额（W_YTD）
	//void  d_memcpy(void *des, void *src, int size)
	d_memcpy(&warehouse_tmp,p_warehouse_tmp,sizeof(struct warehouse));
	warehouse_tmp.W_YTD+=pay_H_AMOUNT;
	//void update(int table_type, int record_id, void *record);
	update(WAREHOUSE,rid_in_warehouses,&warehouse_tmp);	//累计发生金额加上支付金额
	// printf("rid_in_warehouses:%d\tW_ID:%ld\tW_NAME:%s\tW_STREET_1:%s\tW_STREET_2:%s\tW_CITY:%s\tW_STATE:%s\tW_ZIP:%s\tW_YTD:%lf\n",
	// 	rid_in_warehouses,
	// 	p_warehouse_tmp->W_ID,
	// 	p_warehouse_tmp->W_NAME,	//取名称（W_NAME）
	// 	p_warehouse_tmp->W_STREET_1,	//地址1（W_STREET_1）
	// 	p_warehouse_tmp->W_STREET_2,	//地址2（W_STREET_2）
	// 	p_warehouse_tmp->W_CITY,	//城市（W_CITY）
	// 	p_warehouse_tmp->W_STATE,	//州（W_STATE）
	// 	p_warehouse_tmp->W_ZIP,	//邮政编码（W_ZIP）
	// 	p_warehouse_tmp->W_YTD);	//取累计发生额（W_YTD）
	// //void  d_memcpy(void *des, void *src, int size)
	// d_memcpy(&warehouse_tmp,p_warehouse_tmp,sizeof(struct warehouse));


	//在地区表（districts）中查询地区代码（D_W_ID,D_ID）。取名称（D_NAME）、地址1（D_STREET_1）、地址2（D_STREET_2）、城市（D_CITY）、州（D_STATE）、邮政编码（D_ZIP）、累计发生额（D_YTD）。
	struct district district_tmp;
	struct district *p_district_tmp;
	int rid_in_districts=0;
	while(1){
		rid_in_districts = table_scan(DISTRICT, LONG, sizeof(long int), ((long)&(district_tmp.D_W_ID)-(long)&(district_tmp.D_ID)), EQ, &pay_D_W_ID, rid_in_districts);	//扫描整张districts表找出D_W_ID为pay_D_W_ID的记录号
		if(rid_in_districts == -1){	//warehouses中没有pay_D_W_ID对应的记录 
			printf("Transaction Exception:\tD_W_ID is not in district table!");
			return;
		}
		p_district_tmp=(struct district *)get(DISTRICT, rid_in_districts);	//获取pay_D_W_ID对应的记录
		if(p_district_tmp->D_ID == pay_D_ID){	//district中有pay_D_W_ID,pay_D_ID对应的记录
			break;
		}else{
			rid_in_districts++;
		}
	}
	printf("rid_in_districts:%d\tD_W_ID:%ld\tD_ID:%ld\tD_NAME:%s\tD_STREET_1:%s\tD_STREET_2:%s\tD_CITY:%s\tD_STATE:%s\tD_ZIP:%s\tD_YTD:%lf\n",
		rid_in_districts,
		p_district_tmp->D_W_ID,
		p_district_tmp->D_ID,
		p_district_tmp->D_NAME,	//取名称（D_NAME）
		p_district_tmp->D_STREET_1,	//地址1（D_STREET_1）
		p_district_tmp->D_STREET_2,	//地址2（D_STREET_2）
		p_district_tmp->D_CITY,	//城市（D_CITY）
		p_district_tmp->D_STATE,	//州（D_STATE）
		p_district_tmp->D_ZIP,	//邮政编码（D_ZIP）
		p_district_tmp->D_YTD);	//取累计发生额（D_YTD）
	//void  d_memcpy(void *des, void *src, int size)
	d_memcpy(&district_tmp,p_district_tmp,sizeof(struct district));
	district_tmp.D_YTD+=pay_H_AMOUNT;
	//void update(int table_type, int record_id, void *record);
	update(DISTRICT,rid_in_districts,&district_tmp);	//累计发生金额加上支付金额
	// printf("rid_in_districts:%d\tD_W_ID:%ld\tD_ID:%ld\tD_NAME:%s\tD_STREET_1:%s\tD_STREET_2:%s\tD_CITY:%s\tD_STATE:%s\tD_ZIP:%s\tD_YTD:%lf\n",
	// 	rid_in_districts,
	// 	p_district_tmp->D_W_ID,
	// 	p_district_tmp->D_ID,
	// 	p_district_tmp->D_NAME,	//取名称（D_NAME）
	// 	p_district_tmp->D_STREET_1,	//地址1（D_STREET_1）
	// 	p_district_tmp->D_STREET_2,	//地址2（D_STREET_2）
	// 	p_district_tmp->D_CITY,	//城市（D_CITY）
	// 	p_district_tmp->D_STATE,	//州（D_STATE）
	// 	p_district_tmp->D_ZIP,	//邮政编码（D_ZIP）
	// 	p_district_tmp->D_YTD);	//取累计发生额（D_YTD）


	//在客户表（customers）中查询地区代码（C_W_ID,C_D_ID,C_ID）。
	struct customer customer_tmp;
	struct customer *p_customer_tmp;
	int rid_in_customers=0;
	while(1){
		rid_in_customers = table_scan(CUSTOMER, LONG, sizeof(long int), ((long)&(customer_tmp.C_W_ID)-(long)&(customer_tmp.C_ID)), EQ, &pay_C_W_ID, rid_in_customers);	//扫描整张customer表找出C_W_ID为pay_C_W_ID的记录号
		if(rid_in_customers == -1){	//customers中没有pay_C_W_ID对应的记录 
			printf("Transaction Exception:\tC_W_ID is not in customer table!\n");
			return;
		}
		p_customer_tmp=(struct customer *)get(CUSTOMER, rid_in_customers);	//获取pay_C_W_ID对应的记录
		if(p_customer_tmp->C_D_ID == pay_C_D_ID && p_customer_tmp->C_ID == pay_C_ID){	//customers中有pay_C_W_ID,pay_C_D_ID,pay_C_ID对应的记录
			break;
		}else{
			rid_in_customers++;
		}
	}
	printf("rid_in_customers:%d\tC_W_ID:%ld\tC_D_ID:%ld\tC_ID:%ld\tC_FIRST:%s\tC_MIDDLE:%s\tC_LAST:%s\tC_STREET_1:%s\tC_STREET_2:%s\tC_CITY:%s\tC_STATE:%s\tC_ZIP:%s\tC_PHONE:%s\tC_SINCE:%ld\tC_CREDIT:%s\tC_CREDIT_LIM:%lf\tC_DISCOUNT:%lf\tC_BALANCE:%lf\n",
		rid_in_customers,
		p_customer_tmp->C_W_ID,
		p_customer_tmp->C_D_ID,
		p_customer_tmp->C_ID,
		p_customer_tmp->C_FIRST,	//取姓名
		p_customer_tmp->C_MIDDLE,
		p_customer_tmp->C_LAST,
		p_customer_tmp->C_STREET_1,	//地址1
		p_customer_tmp->C_STREET_2,	//地址2
		p_customer_tmp->C_CITY,	//城市
		p_customer_tmp->C_STATE,	//州
		p_customer_tmp->C_ZIP,	//邮政编码
		p_customer_tmp->C_PHONE,	//电话
		p_customer_tmp->C_SINCE,	//登记日期
		p_customer_tmp->C_CREDIT,	//信用
		p_customer_tmp->C_CREDIT_LIM,	//超支限额
		p_customer_tmp->C_DISCOUNT,	//折扣
		p_customer_tmp->C_BALANCE);	//欠款余额
	//void  d_memcpy(void *des, void *src, int size)
	d_memcpy(&customer_tmp,p_customer_tmp,sizeof(struct customer));
	customer_tmp.C_BALANCE-=pay_H_AMOUNT;	//欠款余额减去支付金额
	customer_tmp.C_YTD_PAYMENT+=pay_H_AMOUNT;	//累计发生金额加上支付金额
	customer_tmp.C_PAYMENT_CNT++;	//支付次数加一
	//void update(int table_type, int record_id, void *record);
	update(CUSTOMER,rid_in_customers,&customer_tmp);	//修改记录
	// printf("rid_in_customers:%d\tC_W_ID:%ld\tC_D_ID:%ld\tC_ID:%ld\tC_FIRST:%s\tC_MIDDLE:%s\tC_LAST:%s\tC_STREET_1:%s\tC_STREET_2:%s\tC_CITY:%s\tC_STATE:%s\tC_ZIP:%s\tC_PHONE:%s\tC_SINCE:%ld\tC_CREDIT:%s\tC_CREDIT_LIM:%lf\tC_DISCOUNT:%lf\tC_BALANCE:%lf\n",
	// 	rid_in_customers,
	// 	p_customer_tmp->C_W_ID,
	// 	p_customer_tmp->C_D_ID,
	// 	p_customer_tmp->C_ID,
	// 	p_customer_tmp->C_FIRST,	//取姓名
	// 	p_customer_tmp->C_MIDDLE,
	// 	p_customer_tmp->C_LAST,
	// 	p_customer_tmp->C_STREET_1,	//地址1
	// 	p_customer_tmp->C_STREET_2,	//地址2
	// 	p_customer_tmp->C_CITY,	//城市
	// 	p_customer_tmp->C_STATE,	//州
	// 	p_customer_tmp->C_ZIP,	//邮政编码
	// 	p_customer_tmp->C_PHONE,	//电话
	// 	p_customer_tmp->C_SINCE,	//登记日期
	// 	p_customer_tmp->C_CREDIT,	//信用
	// 	p_customer_tmp->C_CREDIT_LIM,	//超支限额
	// 	p_customer_tmp->C_DISCOUNT,	//折扣
	// 	p_customer_tmp->C_BALANCE);	//欠款余额


	//如果信用（C_CREDIT）为“BC”,则客户备注(C_DATA)右移，左端插入客户代码（C_W_ID、C_D_ID、C_ID）、地区代码（D_ID）、仓库代码（W_ID）、支付金额（H_AMOUNT）
	if(d_strcmp(customer_tmp.C_CREDIT,"BC")==0){
		char pay_C_DATA[500+1];
		char char_C_W_ID[50];
		char char_C_D_ID[50];
		char char_C_ID[50];
		char char_D_ID[50];
		char char_W_ID[50];
		d_ltoa(customer_tmp.C_W_ID,char_C_W_ID);	//客户代码（C_W_ID、C_D_ID、C_ID）
		d_ltoa(customer_tmp.C_D_ID,char_C_D_ID);
		d_ltoa(customer_tmp.C_ID,char_C_ID);
		d_ltoa(pay_D_ID,char_D_ID);	//地区代码（D_ID）
		d_ltoa(pay_W_ID,char_W_ID);	//仓库代码（W_ID）
		char *separator=";";
		d_str_append(pay_C_DATA,char_C_W_ID,501);
		d_str_append(pay_C_DATA,separator,501);
		d_str_append(pay_C_DATA,char_C_D_ID,501);
		d_str_append(pay_C_DATA,separator,501);
		d_str_append(pay_C_DATA,char_C_ID,501);
		d_str_append(pay_C_DATA,separator,501);
		d_str_append(pay_C_DATA,char_D_ID,501);
		d_str_append(pay_C_DATA,separator,501);
		d_str_append(pay_C_DATA,char_W_ID,501);
		d_str_append(pay_C_DATA,separator,501);
		d_str_append(pay_C_DATA,customer_tmp.C_DATA,501);
		d_memcpy(customer_tmp.C_DATA,pay_C_DATA,501);
		update(CUSTOMER,rid_in_customers,&customer_tmp);	//修改记录
		//printf("C_DATA:%s\n",p_customer_tmp->C_DATA);
	}


	//向历史记录表（historys）中添加一条记录，备注（H_DATA）写为仓库名称（W_NAME）和地区名称（D_NAME）
	struct history history_tmp;
	history_tmp.H_C_ID=pay_C_ID;
	history_tmp.H_C_D_ID=pay_C_D_ID;
	history_tmp.H_C_W_ID=pay_C_W_ID;
	history_tmp.H_D_ID=pay_D_ID;
	history_tmp.H_W_ID=pay_W_ID;
	history_tmp.H_DATE=1184;
	history_tmp.H_AMOUNT=pay_H_AMOUNT;
	int pay_W_NAME_length=d_strlen(p_warehouse_tmp->W_NAME);
	d_memcpy(history_tmp.H_DATA,p_warehouse_tmp->W_NAME,pay_W_NAME_length);
	history_tmp.H_DATA[pay_W_NAME_length]=';';
	d_memcpy(history_tmp.H_DATA+(pay_W_NAME_length+1),p_district_tmp->D_NAME,d_strlen(p_district_tmp->D_NAME));
	//int insert_rec(int table_type, void *record);
	insert_rec(HISTORY,&history_tmp);

	//事务提交 
	printf("Payment Transaction is finished!\n");
}
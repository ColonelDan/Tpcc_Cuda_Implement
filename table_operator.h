//
//  	desc: table_operator head file. 
//	date: 2018-4-3
//	author: Xie Shangwei
//

#ifndef TABLE_OPERATOR_H
#define TABLE_OPERATOR_H

__device__
void insert_rec(int table_type, void *record);

__device__
void delete_rec(int table_type, int record_id);

__device__
void update(int table_type, int record_id, void *record);

__device__
void *get(int table_type, int rid);

__device__
void get_table_head(int table_type, void **table_head);

__device__
void get_flag_head(int table_type, char **flag_head);

__device__
void get_table_size(int table_type, int *table_size);

__device__
void get_record_size(int table_type, int *record_size);

__device__
int table_scan(int table_type, int attr_type, int attr_size,  int attr_offset, int op , void *value, int rid);
#endif

import mysql.connector as sql
conn = sql.connect(host='localhost', user='root', passed='123@Abcd', database='bank')
#if conn. is connected():
    #print('connected successfully')
cur = conn.cursor()
cur.execute('create table customer_details(acct_no int primary key, acct_name varchar(25), phone_no bigint(25) check(phone_no>11), address varchar(25), cr_amt float)')

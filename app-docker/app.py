#!/usr/bin/python
import mysql.connector
import datetime


from mysql.connector import Error
try:
    connection = mysql.connector.connect(host='mysql.service.irena.consul',
#    connection = mysql.connector.connect(host='3.82.214.180',
                             database='employees',
                             user='irena',
                             password='irena')
    if connection.is_connected():
       db_Info = connection.get_server_info()
       print("Connected to MySQL database... MySQL Server version on ",db_Info)
       cursor = connection.cursor()
       cursor.execute("select database();")
       record = cursor.fetchone()
       print ("Your connected to - ", record)
except Error as e :
    print ("Error while connecting to MySQL", e)
finally:
    mytext = "irena"
    mytime = datetime.datetime.now()
    request_id= 10
    sql_insert_query = """insert into app_requests (request_id,text,request_time) VALUES(%s, %s, %s)"""
    insert_tuple = (request_id,mytext,mytime)
    result = cursor.execute(sql_insert_query, insert_tuple)
    connection.commit()
    print("Record inserted successfully into python_users table")

    #closing database connection.
    if(connection.is_connected()):
        cursor.close()
        connection.close()
        print("MySQL connection is closed")

from flask import Flask
app = Flask(__name__)


@app.route('/')
def hello_world():
    return 'Nice to meet you!'


@app.route('/goaway')
def goaway():
    return 'GO AWAY!'


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
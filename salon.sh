#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon -c"



function salon(){
echo "hello , enter exit or quit to exit"
services=$($PSQL "select service_id as id,name from services")
if [[ -z "$services" || "$services" =~ "(0 rows)" ]]
then 
  echo "no services , system out"
  exit
else 
  echo -e "$services" | while read id name
  do
    if [[ $id =~ ^[0-9] ]]
    then
    echo "$id) ${name:2}"
    fi
  done
  read SERVICE_ID_SELECTED
  if [[ "$SERVICE_ID_SELECTED" == "exit" || "$SERVICE_ID_SELECTED" == "quit" ]]
    then
    exit
  fi
  while [[ -z "$SERVICE_ID_SELECTED" || ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]
  do
    echo "input is null or is not number, again"
    read SERVICE_ID_SELECTED
  done
  data=$($PSQL "select service_id as id,name from services where service_id = $SERVICE_ID_SELECTED")
  if [[ -z "$data" || "$data" =~ "(0 rows)" ]]
  then
    echo "the service is not exist , again"
    salon
  else
    echo "input your phone"
    read CUSTOMER_PHONE
    phone=$($PSQL "select phone from customers where phone = '$CUSTOMER_PHONE'")
    if [[ -z "$phone" || "$phone" =~ "(0 rows)" ]]
    then
      #$($PSQL "insert into customers(phone,name) values ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      echo "you haven't registered this,input your name"
      read CUSTOMER_NAME
      while [[ -z "$CUSTOMER_NAME" ]]
      do
        echo "your name is empty"
        read CUSTOMER_NAME
      done
      insert_customer=$($PSQL "insert into customers(phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    echo "input your time (yyyy-MM-dd)"
    read SERVICE_TIME
    while [[ ! "$SERVICE_TIME" =~ ^((19|20)[0-9]{2})-((0?2-((0?[1-9])|([1-2][0-9])))|(0?(1|3|5|7|8|10|12)-((0?[1-9])|([1-2][0-9])|(3[0-1])))|(0?(4|6|9|11)-((0?[1-9])|([1-2][0-9])|30)))$ ]]
    do
      echo "your time style is wrong , the right style is yyyy-MM-dd"
      read SERVICE_TIME
    done
    
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    
    echo -e "$CUSTOMER_ID" | while read c_id
    do
    if [[ $c_id =~ ^[0-9] ]]
      then
        ADD_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values ($c_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        if [[ "$ADD_APPOINTMENT_RESULT" == "INSERT 0 1" ]]
        then
          echo "success"
        else
          echo "server is busy,please do it later"
        fi
        salon
      fi
    done
  fi
fi
}


salon




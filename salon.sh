#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~ Salon FreeCodeCamp ~~\n"
MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  else
    echo "Welcome to My Salon, how can I help you?"
  fi
  SERVICES_OPTIONS=$($PSQL "SELECT * FROM services")
  if [[ -z $SERVICES_OPTIONS ]]
  then
    echo "Sorry no services today!"
  else
    echo "$SERVICES_OPTIONS" | while read ID BAR NAME
    do
      echo "$ID) $NAME"
    done
    # User select un services
    read SERVICE_ID_SELECTED
    SERVICE_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_RESULT ]]
    then
      MENU "Service not found, try again:" 
    else
      CREATE_APPOINTMENT
    fi
  fi
  
}



CREATE_APPOINTMENT() {
  echo -e "\nWhat's your number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record of this number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
}


MENU 
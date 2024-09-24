#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ My Salon ~~~~~\n"
echo Welcome to My Salon, how can I help you?

MAIN_MENU(){
  if [[ $1 ]] 
  then
    echo -e "\n$1"
  fi
  SERVICES_LIST=$($PSQL "SELECT * FROM services")

  
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    NAME_SELECT=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$(echo $NAME_SELECT | sed 's/ //g')

    if [[ -z $NAME_SELECT ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CUSTOMER_NAME_FORMATED=$(echo $CUSTOMER_NAME | sed 's/ //g')
      INSERT_CUSTOMERS_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME_FORMATED','$CUSTOMER_PHONE')")
    fi

    SERVICE_NAME_FORMATED=$(echo $SERVICE_NAME| sed 's/ //g')

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATED, $CUSTOMER_NAME_FORMATED?"
    read SERVICE_TIME

    INSERT_APPOINTMENTS_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $INSERT_APPOINTMENTS_RESULT == "INSERT 0 1" ]]
    then
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME_FORMATED."
    fi
  fi
}

MAIN_MENU

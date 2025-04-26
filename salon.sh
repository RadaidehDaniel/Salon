#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  # display a numbered list of the services
  SERVICES_SELECTED=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES_SELECTED" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # read a service_id (SERVICE_ID_SELECTED)
  read SERVICE_ID_SELECTED

  # SERVICE_ID_SELECTED is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nEnter a number\n"
    MAIN_MENU
  else

    # SERVICE_ID_SELECTED is not null
    SERVICE_ID_EXIST=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    echo $SERVICE_ID_EXIST
    if [[ -z $SERVICE_ID_EXIST ]]
    then
      echo -e "\nEnter a number from the list\n"
      MAIN_MENU
    else

      # read users phone number (CUSTOMER_PHONE)
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # Check if the customer exist
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then

        # Read customer name (CUSTOMER_NAME)
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # Insert customer's name and phone to the database
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
      # Read time (SERVICE_TIME)
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      
      # Insert the appointment
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")

      # Display the final message and finish the script
      echo -e "I have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU

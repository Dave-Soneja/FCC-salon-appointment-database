#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Get available services and display them as a numbered list
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  if [[ -z $AVAILABLE_SERVICES ]]; then
    echo "Sorry, we don't have any service available right now."
  else
    echo "Here are the available services:\n"
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

    # Prompt the user to select a service
    echo -e "\nPlease choose a service by entering the corresponding number:"
    read SERVICE_ID_SELECTED

    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "That is not a valid number. Please select a valid service."
    else
      SERV_AVAIL=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      NAME_SERV=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ -z $SERV_AVAIL ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        if [[ -z $CUSTOMER_NAME ]]
        then
          # Phone number is new, ask for name and insert into customers table
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME
          
          # Insert the new customer into the customers table
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
          
          # Ensure insertion is successful
          if [[ $INSERT_CUSTOMER_RESULT ]]
          then
            echo -e "\nThank you, $CUSTOMER_NAME! We’ve added you to our system."
          fi
        fi

        # Get the customer_id for the customer (either new or existing)
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        echo -e "\nWhat time would you like your $NAME_SERV, $CUSTOMER_NAME?"
        read SERVICE_TIME

        if [[ $SERVICE_TIME ]]; then
          # Insert appointment into appointments table
          INSERT_SERV_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          
          # Ensure insertion is successful
          if [[ $INSERT_SERV_RESULT ]]; then
            echo -e "\nI have put you down for a $NAME_SERV at $SERVICE_TIME, $CUSTOMER_NAME."
          else
            echo "Sorry, we couldn't book your appointment. Please try again."
          fi
        fi
      fi
    fi
  fi
}
MAIN MENU

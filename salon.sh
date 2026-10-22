#! /bin/bash
#PSQL="psql -X --username=freecodecamp --dbname=<nombre_base_de_datos> --tuples-only -c"
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
#Main variable: MAIN_MENU
MAIN_MENU() {
  if [[ $1 ]]
  then
echo -e "\n$1"
else
#Welcome message
echo -e "\nBienvenido. ¿Que look estás buscando? Selecciona un servicio\n"
fi
#Numbered list of services
NUMBERED_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$NUMBERED_LIST" | while read SERVICE_ID BAR NAME
do
echo "$SERVICE_ID) $NAME"
done
#Read the option selected by the user
read SERVICE_ID_SELECTED
#Check whether the service exists in the database.
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
if [[ -z $SERVICE_NAME ]]
then
#If the service does not exist, return to the main menu
MAIN_MENU "\nPor favor, elige una opcion válida\n"
else
#If the service exists:
echo -e "\nElegiste el servicio: $SERVICE_NAME\n"
#Request a telephone number
echo -e "\n¿Cuál es tu número de teléfono?\n"
read CUSTOMER_PHONE
#Clear all fields where the user can enter text
CUSTOMER_PHONE="${CUSTOMER_PHONE// /}"
#Check whether the number is in the customer table
PHONE_NUMBER=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $PHONE_NUMBER ]]
then
#New customer registration
echo -e "\n¿Cual es tu nombre\n"
read CUSTOMER_NAME
ADD_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi
#Get customer ID
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
COSTUMER_NAME=$($PSQL "SELECT name FROM customer WHERE customer_id = '$CUSTOMER_ID'")
#Request an appointment, using the predefined form
echo -e "\n¿Que fecha y hora te va mejor?\n"
read SERVICE_TIME
#Inserting the appointment into the ‘appointments’ table
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
#Removing whitespace from text variables
SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | sed -r 's/^ *| *$//g')
CUSTOMER_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | sed -r 's/^ *| *$//g')
#Closing message: I have put you down for a <service> at <time>, <name>.
echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
fi
}
MAIN_MENU

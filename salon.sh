#! /bin/bash
#PSQL="psql -X --username=freecodecamp --dbname=<nombre_base_de_datos> --tuples-only -c"
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
#Variable principal: MAIN_MENU
MAIN_MENU() {
  if [[ $1 ]]
  then
echo -e "\n$1"
else
#mensaje de bienvenida
echo -e "\nBienvenido. ¿Que look estás buscando? Selecciona un servicio\n"
fi
#lista numerada de los servicios
NUMBERED_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$NUMBERED_LIST" | while read SERVICE_ID BAR NAME
do
echo "$SERVICE_ID) $NAME"
done
#leer la opción seleccionada por el usuario
read SERVICE_ID_SELECTED
#Verifica si el servicio existe en la base de datos.
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
if [[ -z $SERVICE_NAME ]]
then
#si el srvicio no existe, retorno al menu principal
MAIN_MENU "\nPor favor, elige una opcion válida\n"
else
#si el servicio existe:
echo -e "\nElegiste el servicio: $SERVICE_NAME\n"
#solicitar numero de telefono
echo -e "\n¿Cuál es tu número de teléfono?\n"
read CUSTOMER_PHONE
# Limpiar todos los espacios que el usuario pueda escribir
CUSTOMER_PHONE="${CUSTOMER_PHONE// /}"
#consulta si el numero esta en la tabla clientes
PHONE_NUMBER=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $PHONE_NUMBER ]]
then
#Registro cliente nuevo
echo -e "\n¿Cual es tu nombre\n"
read CUSTOMER_NAME
ADD_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi
#Obtener id del cliente
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
COSTUMER_NAME=$($PSQL "SELECT name FROM customer WHERE customer_id = '$CUSTOMER_ID'")
#Solicitar la cita, con formato predefinido
echo -e "\n¿Que fecha y hora te va mejor?\n"
read SERVICE_TIME
# Inserción de la cita en la tabla appointments
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
# Limpieza de espacios en blanco en las variables de texto
SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | sed -r 's/^ *| *$//g')
CUSTOMER_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | sed -r 's/^ *| *$//g')
#Mensaje final: I have put you down for a <service> at <time>, <name>.
echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
fi
}
MAIN_MENU

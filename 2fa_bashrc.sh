#!/bin/bash

##
# Este script junto a su par, 2fa_profile.sh, son un conjunto de
# scripts cuya función es establecer un segundo factor de 
# autenticación para progener las cuentas de usuario en el que 
# sea implementado.
#
# AUTOR: José Emilio Gutiérrez
# FECHA: Junio 2017
# CONTACTO: gutierrezmoran@hotmail.com
##

# Variables a utilizar
codigo_aleatorio=""
codigo_introducido="."
equipo=$(hostname)
mensaje=$(echo -e "Se está iniciando sesión en $equipo. Introduzca la siguiente clave para completar el inicio de sesión:")

# Activar TRAP para evitar poder detener el script con [Ctrl]+[C]
trap '' 2 3 9 15

# Función para generar una clave aleatoria
function generar_clave {
	for i in `seq 1 6`;
	do
		rand=$(( $RANDOM % 10 ))
		codigo_aleatorio="${codigo_aleatorio}${rand}"
	done
}

# Función que envía un correo electrónico con la clave aleatoria
function enviar_email {
	sendemail -f correo_origen@correo.com -t correo_destino@correo.com -xu "correo_origen@correo.com" -xp "contraseña_correo_origen" -m "$mensaje $codigo_aleatorio" -s smtp.live.com:25 -o message-charset=utf-8 tls=yes -u "Clave de acceso" > /dev/null
}

generar_clave
enviar_email

# El mensaje puede ser modificado a gusto del usuario
	printf "
El usuario especificado cuenta con un 2FA como medida de seguridad.

Si este usuario le corresponde, por favor, revise su correo electrónico.

"
while [ "${codigo_aleatorio}" != "${codigo_introducido}" ]; do
	read -p "Introduzca el código de autenticación: " codigo_introducido
done
	echo -e "\e[32mHa accedido satisfactoriamente.\e[0m\n"

# Se genera un archivo de control para evitar el 2FA dos veces sin haber reiniciado o apagado
# el equipo.
touch /tmp/.t2fa_${UID}
chmod 000 /tmp/.t2fa_${UID}

# Desactivar el TRAP
trap - 2 3 9 15

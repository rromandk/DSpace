#!/bin/bash
set -e

###################################
######## VARIABLES CONFIGURABLES ##
###################################
cwd=`pwd`
#Directorio del código fuente de la aplicación
DSPACE_SRC=$(dirname $(readlink -f $0))
#Directorio de instalación de la aplicación
DSPACE_DIR=$DSPACE_SRC/install
#Directorio de backups de la aplicación
DSPACE_BKP_DIR=$DSPACE_SRC/backups
#Ruta al script de actualización de la base de datos. Si no existe, se tirará una advertencia y se seguirá con la actualización
DATABASE_BKP_SCRIPT_FULLPATH=
#Usuario con el que se debe ejecutar la actualización de DSpace
DSPACE_USER=`whoami`
#Nombre del servicio para ejecutar tomcat
TOMCAT="tomcat8"

#JAVA_OPTS="JAVA_OPTS=-Xmx1024m"
#ANT_OPTS="-q"
#MVN_OPTS="-q"
MVN_PROFILES=\!dspace-jspui,\!dspace-rdf,\!dspace-sword,\!dspace-swordv2
MIRAGE2_PROPERTIES="-Dmirage2.on=true -Dmirage2.deps.included=false"


update()
{
    show_message "Introduce tu contraseña de superusuario para poder continuar"
    sudo echo "[ÉXITO!] Continuamos..."
        
	show_message "Actualizando la instalacion de DSpace. Esta operación suele demorar un par de minutos."
	
	show_message "Actualizamos el código fuente de github."
	cd $DSPACE_SRC
	git stash && git pull --rebase origin master
	#Si el 'git stash' guardó el estado del workspace, entonces los sacamos del stash. 
	#Si hacemos stash pop y el stash está vacío, el script corta la ejecución...
	if [ ! -z "`git stash list`" ]; then
            git stash pop
	fi
	
	show_message "Instalamos los recursos"
	#$JAVA_OPTS mvn install $MIRAGE2_PROPERTIES $MVN_OPTS -P $MVN_PROFILES
	$JAVA_OPTS mvn package $MIRAGE2_PROPERTIES $MVN_OPTS -P $MVN_PROFILES
		
	show_message "Paramos Tomcat..."
	sudo /etc/init.d/$TOMCAT stop
	
	#Limpiar cache XMLUI/Cocoon
	#sudo rm /var/lib/$TOMCAT/work/Catalina/localhost/_/cache-dir/cocoon-ehcache.data
	#sudo rm /var/lib/$TOMCAT/work/Catalina/localhost/_/cache-dir/cocoon-ehcache.index

	show_message "Actualizamos los sources..."
	cd dspace/target/dspace-installer
	# TODO reusar el /var/dspace/install/config/GeoLiteCity.dat
	$JAVA_OPTS ant update $ANT_OPTS 
	
	show_message "ESPACIO OCUPADO POR BACKUPS"
	find $DSPACE_DIR -name *.bak-* -exec du -sh {} \;
	show_message "¿Desea eliminar los directorio de backup en el directorio de instalación? [Yy-Nn]"
	read continuar
	if [[ "$continuar" == [Yy] ]]; then
		show_message "eliminamos directorios de bkp viejos"
		ant clean_backups -Ddspace.dir=$DSPACE_DIR
	fi
	
	show_message "Limpiando directorio temporales creados por 'mvn'"
	cd $DSPACE_SRC
	$JAVA_OPTS mvn clean
	
	show_message "Iniciamos Tomcat..."
	sudo /etc/init.d/$TOMCAT start
	
	show_message "Se hicieron los siguientes reemplazos en la configuración"
	find  $DSPACE_DIR/config/ -name "*.old"
	
	show_message "Se actualizó correctamente DSpace"
	cd $cwd

}

show_message()
{
   YELLOW_COLOUR="\e[33m"
   DEFAULT_COLOR="\e[m"
   printf "#################################################################################################\n"
   printf "# ${YELLOW_COLOUR} $1 ${DEFAULT_COLOR} #\n"
   printf "#################################################################################################\n"
}


show_help()
{
   bold=$(tput bold)
   normal=$(tput sgr0)
   
   printf "##########################\n#USO: $0 {dev|prod} \n#\n#${bold}MODOS DE EJECUCIÓN${normal}\n#   %s \n#   %s \n# \n# %s \n# %s \n##########################\n" \
                  " ${bold}dev${normal} [DESARROLLO]: se compila el proyecto utilizando el profile de desarrollo (development) de Mirage2, y además se ejecutan backups de la base de datos y archivos de configuración del directorio de instalación. En este modo, los archivos CSS y Javascript generados por Mirage2 no pasan por un proceso de 'minification'." \
                  " ${bold}prod${normal} [PRODUCCIÓN]: en este modo, todos los archivos CSS y Javascript generados por Mirage2 pasaron por una 'minification'." \
                  "${bold}VARIABLES CONFIGURABLES${normal} --> El script cuenta con algunas variables dependientes del entorno de ejecución, por lo que conviene editarlas antes de ejecutarlo..." \
                  "${bold}IMPORTANTE${normal} --> El script debe ejecutarse configurando la consola como ${bold}\"Login Shell\"${normal}, sino fallará la compilación de Mirage2... Para ésto, ejecutar ${bold}/bin/bash --login${normal} antes de ejecutar el script, ó ejecutar el script de la siguiente forma: ${bold}/bin/bash --login -c \"./build.sh {dev|prod}${normal}\"." >&2
}

#Sólo hacemos backups en MODO PRODUCCIÓN
do_backups(){
	show_message "Ejecutando backups..."
	#existe el script de backup?
	if [ -f  "$DATABASE_BKP_SCRIPT_FULLPATH" ]; then
		bash -c "$DATABASE_BKP_SCRIPT_FULLPATH"
	else
		echo "* ERROR[!]No se encuentra el script de backups de la base de datos en la ruta $DATABASE_BKP_SCRIPT_FULLPATH. Se cancela este backup y se continúa con la actualización..."
	fi
	
	#existe el directorio de backup de configuración?
	if [ -d "$DSPACE_BKP_DIR" ]; then
            if [ ! -d "$DSPACE_BKP_DIR/config" ];then
               mkdir $DSPACE_BKP_DIR/config
            fi
            tar -czf $DSPACE_BKP_DIR/config/config.bkp.`date +%F_%H-%M-%S`.tgz $DSPACE_DIR/config
            echo "* [EXITO!] Backup de configuraciones realizado..."
	else
            echo "* ERROR[!] No se encuentra el directorio $DSPACE_BKP_DIR. Se cancela el backup del directorio de configuración y se continúa con la actualización..."
	fi

}


################################
######## MAIN ##################
################################

case "$1" in
  dev)
         #Mirage2 Modo Development
         MVN_PROFILES=mirage2_dev,$MVN_PROFILES
         show_message "Ejecutando en MODO DESARROLLO"
         ;;
  prod)
         #Modo Producción
	show_message "Ejecutando en MODO PRODUCCIÓN"
	do_backups
         ;;
  *)
        show_help
        exit 3
        ;;
esac

##Antes que nada verificamos si se está ejecutando el script en una "Login Shell"...
## TODO: aunque me loguee como una "Login Shell", cuando pregunto por la propiedad 'login_shell' me dice 'off', aunque el script
## no lanza error al compilar Mirage2...
#shopt -q login_shell || echo $?; show_message "ERROR!";
#	 					printf "No se encuentra en una consola en modo \"Login Shell\".\nCancelando la actualización...\n";
#exit 6



#Verificamos que el usuario necesario para correr la actualización sea el configurado...	
if [ "`whoami`" != "$DSPACE_USER" ]; then
    show_message "You must run this script using dspace user $DSPACE_USER"
    exit 1
fi

#Comenzamos con la actualización
update

exit 0


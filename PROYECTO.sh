#!/bin/bash

mostrar_menu_principal() {
    clear
    echo "======== Menú de Automatización ========"
    echo "1. Actualizar el sistema y paquetes"
    echo "2. Configurar cronjobs para descargar archivos desde la web"
    echo "3. Monitorear el uso de CPU, memoria y almacenamiento"
    echo "4. Configurar alertas de recursos"
    echo "5. Ordenar carpetas"
    echo "6. Salir"
    echo "======================================="
}

mostrar_menu_ordenar_carpetas() {
    echo "Seleccione el criterio de ordenación:"
    echo "1. Orden alfabético"
    echo "2. Fecha de modificación"
    echo "3. Cantidad de almacenamiento"
    echo "4. Volver al menú principal"
    read -p "Ingrese su elección: " opcion

    case $opcion in
        1)
            echo "Ordenando carpetas alfabéticamente:"
            ls -l | grep "^d" | awk '{print $9}' | sort
            ;;
        2)
            echo "Ordenando carpetas por fecha de modificación:"
            ls -lt | grep "^d" | awk '{print $9}'
            ;;
        3)
            echo "Ordenando carpetas por cantidad de almacenamiento:"
            du -h --max-depth=1 | sort -h
            ;;
        4)
            return 1  # Indica que el usuario desea volver al menú principal
            ;;
        *)
            echo "Opción no válida. No se realizará ninguna acción."
            ;;
    esac
}

actualizar_sistema() {
    sudo yum update -y
}

configurar_cronjob_descargar_archivos() {
    read -p "Ingrese la URL del archivo a descargar: " url_archivo
    read -p "Ingrese la ruta local para guardar el archivo: " ruta_local

    # Agrega aquí la configuración del cronjob para descargar archivos desde la web
    # Utilizando el comando wget para descargar el archivo
    (crontab -l 2>/dev/null; echo "0 3 * * * wget -O $ruta_local $url_archivo") | crontab -
}

monitorear_recursos() {
    echo "========== Estado del Equipo =========="
    echo ""

    echo "Uso de CPU:"
    mpstat | grep 'all' | awk '{print "Uso de CPU: " 100 - $12"%"}'
    echo ""

    echo "Uso de Memoria:"
    free -m | awk 'NR==2{printf "Memoria Usada: %sMB (%.2f%%)\nMemoria Libre: %sMB (%.2f%%)\n", $3, $3*100/$2, $4, $4*100/$2}'
    echo ""

    echo "Uso de Almacenamiento:"
    df -h | awk '$NF=="/"{printf "Espacio Usado: %d/%dGB (%s)\n", $3,$2,$5}'
    echo ""
}

configurar_alertas() {
    read -p "Ingrese el umbral para la alerta de memoria (en MB): " umbral_memoria
    read -p "Ingrese el umbral para la alerta de almacenamiento (en %): " umbral_almacenamiento

    # Agrega aquí la configuración de alertas según los umbrales proporcionados
    # Por ejemplo, utilizando un script que verifica y alerta si los recursos superan el umbral:
    cat <<EOF > script-verificar-recursos.sh
#!/bin/bash

umbral_memoria=$umbral_memoria
umbral_almacenamiento=$umbral_almacenamiento

uso_memoria=\$(free -m | awk 'NR==2{printf "%.2f", \$3*100/\$2}')
if (( \$(echo "\$uso_memoria > $umbral_memoria" | bc -l) )); then
    echo "Alerta: Uso de memoria supera el umbral establecido ($umbral_memoria MB)."
fi

uso_almacenamiento=\$(df -h / | awk 'NR==2{print \$5}' | cut -d'%' -f1)
if (( \$uso_almacenamiento > $umbral_almacenamiento )); then
    echo "Alerta: Uso de almacenamiento supera el umbral establecido ($umbral_almacenamiento%)."
fi
EOF

    chmod +x script-verificar-recursos.sh  # Dar permisos de ejecución al script
}

while true; do
    mostrar_menu_principal

    read -p "Ingrese el número de la opción deseada: " opcion

    case $opcion in
        1)
            actualizar_sistema
            ;;
        2)
            configurar_cronjob_descargar_archivos
            ;;
        3)
            monitorear_recursos
            read -p "Presione Enter para continuar..."
            ;;
        4)
            configurar_alertas
            ;;
        5)
            while true; do
                mostrar_menu_ordenar_carpetas
                if [ $? -eq 1 ]; then
                    break  # Sal del bucle de ordenar carpetas para volver al menú principal
                fi
                read -p "Presione Enter para continuar..."
            done
            ;;
        6)
            echo "Saliendo del script. ¡Hasta luego!"
            exit 0
            ;;
        *)
            echo "Opción no válida. Inténtalo de nuevo."
            ;;
    esac
done

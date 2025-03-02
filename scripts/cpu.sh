#!/bin/bash

export LC_NUMERIC="en_US.UTF-8"

# Reemplaza "io.flutter.calificator" con el nombre de tu paquete
PACKAGE_NAME="io.flutter.calificator"

# Archivo de salida CSV
output_csv="cpu_usage.csv"

# Intervalo en segundos entre mediciones
INTERVAL=2

# Obtener el número de núcleos del dispositivo
num_cores=$(adb shell cat /proc/cpuinfo | grep processor | wc -l)
echo "Número de núcleos detectados: $num_cores"

# Escribe el encabezado en el archivo CSV
echo "Timestamp,CPU Usage (%) (Normalized)" > "$output_csv"

while true; do
    # Obtén la hora actual en formato de timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # Obtén el uso del CPU para el paquete
    cpu_usage=$(adb shell top -b -n 1 | grep "$PACKAGE_NAME" | awk '{print $9}')

    if [[ -n "$cpu_usage" ]]; then
        # Normaliza el uso del CPU dividiendo entre el número de núcleos
        normalized_cpu_usage=$(echo "scale=2; $cpu_usage / $num_cores" | bc)

        # Escribe el timestamp y el uso del CPU normalizado en el archivo CSV
        printf "%s,%.2f\n" "$timestamp" "$normalized_cpu_usage" >> "$output_csv"
        printf "[$timestamp] CPU Usage (Normalized): %.2f%%\n" "$normalized_cpu_usage"
    else
        echo "[$timestamp] No se pudo obtener el uso del CPU para el paquete $PACKAGE_NAME."
    fi

    echo "------------------------------------"
    sleep $INTERVAL
done

#!/bin/bash

# Reemplaza "io.flutter.calificator" con el nombre de tu paquete
PACKAGE_NAME="io.flutter.calificator"

# Archivo de salida CSV
output_csv="memory_usage.csv"

# Intervalo en segundos entre mediciones
INTERVAL=2

# Escribe el encabezado en el archivo CSV
echo "Timestamp,Total Memory (PSS) (MB)" > "$output_csv"

while true; do
    # Obtén la hora actual en formato de timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # Obtén la memoria TOTAL PSS
    total_memory_kb=$(adb shell dumpsys meminfo $PACKAGE_NAME | grep -E "TOTAL" | awk '$2 ~ /PSS/ {print $3}')

    echo $total_memory_kb
    if [[ -n "$total_memory_kb" ]]; then
        total_memory_mb=$(echo "scale=2; $total_memory_kb / 1024" | bc)

        # Escribe el timestamp y la memoria total en el archivo CSV
        echo "$timestamp,$total_memory_mb" >> "$output_csv"
        echo "[$timestamp] Total Memory (PSS): $total_memory_mb MB"
    else
        echo "[$timestamp] No se pudo obtener la memoria PSS."
    fi

    echo "------------------------------------"
    sleep $INTERVAL
done
#!/bin/bash


# Archivo de salida CSV
output_csv="memory_usage_mysql.csv"

# Intervalo en segundos entre mediciones
INTERVAL=2

# Escribe el encabezado en el archivo CSV
echo "Timestamp,Total Memory" > "$output_csv"

while true; do
    # Obtén la hora actual en formato de timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # Obtén la memoria TOTAL PSS
    total_memory=$(docker stats --no-stream mysql-db | awk 'NR>1 {print $4}')

    echo $total_memory
    if [[ -n "$total_memory" ]]; then
        

        # Escribe el timestamp y la memoria total en el archivo CSV
        echo "$timestamp,$total_memory" >> "$output_csv"
        echo "[$timestamp] Total Memory: $total_memory"
    else
        echo "[$timestamp] No se pudo obtener la memoria."
    fi

    echo "------------------------------------"
    sleep $INTERVAL
done
#!/bin/bash


input_csv="test.csv"

output_csv="memory_usage_server.csv"

# Escribir encabezado en el archivo de salida
echo "Timestamp,Used (MB),Committed (MB),Max (MB)" > "$output_csv"

# Leer cada línea del archivo CSV (excepto la primera línea)
tail -n +2 "$input_csv" | while IFS=, read -r time used committed max; do
       # Convertir el valor de 'time' de segundos desde la época Unix a formato de fecha
    timestamp=$(date -d @$time "+%Y-%m-%d %H:%M:%S")

    # Convertir bytes a MB (1 MB = 1024 * 1024 bytes)
    used_mb=$(echo "scale=2; $used / 1024 / 1024" | bc)
    if [[ -z "$committed" ]]; then
        committed_mb=""  # Asigna vacío si committed está vacío
    else
        committed_mb=$(echo "scale=2; $committed / 1024 / 1024" | bc)
    fi
    if [[ -z "$max" ]]; then
        max_mb=""  # Asigna vacío si max está vacío
    else
        max_mb=$(echo "scale=2; $max / 1024 / 1024" | bc)
    fi
    # Escribir la línea convertida en el archivo de salida
    echo "$timestamp,$used_mb,$committed_mb,$max_mb" >> "$output_csv"
done

echo "El archivo CSV con memoria en MB ha sido creado: $output_csv"
#!/bin/bash

# es necesario para limpiar log viejos adb logcat -c

# Es necesario ejecutar el siguiente comando para copar los log anteriores al archivo log: stdbuf -oL adb logcat | grep -E "processing-score|network-time" > log.txt
# tail -f log.txt para ir viendo los logs que se copiaron
# Archivo de entrada y salida
log_file="log.txt"
output_csv="jobs.csv"

# Inicializa variables
current_start=""
echo "Job Index,Network duration (ms),Detection time (ms)" > "$output_csv"  # Escribe el encabezado CSV


# Procesa cada línea del archivo de logs
while IFS= read -r line; do
    # Extraer network-time

    if [[ "$line" =~ network-time:\ index\ ([0-9]+)\ in\ ([0-9]+)ms ]]; then
        # Extrae la hora de fin (parte de la línea)
          network_ms="${BASH_REMATCH[2]}"
          job_index=$((BASH_REMATCH[1]))
          # Escribe el índice del job, tiempo de inicio y fin al archivo CSV
          echo "$job_index,$network_ms", >> "$output_csv"
    fi

    # Extraer  detection time

    if [[ "$line" =~ detection-time-processing-score:\ index\ ([0-9]+)\ in\ ([0-9]+) ]]; then
        # Extrae la hora de fin (parte de la línea)
          detection_time="${BASH_REMATCH[2]}"
          job_index=$((BASH_REMATCH[1]))
          # Escribe el índice del job, tiempo de inicio y fin al archivo CSV
          echo "$job_index,,$detection_time" >> "$output_csv"
    fi

done < "$log_file"

echo "Resultados guardados en $output_csv"

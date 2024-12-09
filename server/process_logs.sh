#!/bin/bash

# Archivo de entrada y salida
log_file="log.txt"
output_csv="jobs.csv"

# Inicializa el mapa asociativo
declare -A map

# Escribe el encabezado del CSV
echo "Job Index,Network duration (ms),Detection time (ms)" > "$output_csv"

# Procesa cada línea del archivo de logs
while IFS= read -r line; do
    if [[ "$line" =~ network-time:\ index\ ([0-9]+)\ in\ ([0-9]+)ms ]]; then
        job_index="${BASH_REMATCH[1]}"
        network_time="${BASH_REMATCH[2]}"
        
        # Almacena o actualiza el valor en el mapa
        map["$job_index,network"]="$network_time"
       
    elif [[ "$line" =~ detection-time-processing-score:\ index\ ([0-9]+)\ in\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        detection_time="${BASH_REMATCH[2]}"

        # Almacena o actualiza el valor en el mapa
        map["$job_index,detection"]="$detection_time"
    fi

    # Verifica si ambos valores están presentes
    if [[ -n "${map["$job_index,network"]}" && -n "${map["$job_index,detection"]}" ]]; then
        # Escribe la línea en el CSV
        echo "$job_index,${map["$job_index,network"]},${map["$job_index,detection"]}" >> "$output_csv"
        
        # Limpia los datos de este índice
        unset map["$job_index,network"]
        unset map["$job_index,detection"]
    fi

done < "$log_file"

echo "Resultados guardados en $output_csv"

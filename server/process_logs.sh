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
       if [[ "$line" =~ network-time:\ index\ ([0-9]+)\ in\ ([0-9]+)ms ]]; then
        job_index="${BASH_REMATCH[1]}"
        network_time="${BASH_REMATCH[2]}"
        
        # Almacena o actualiza el valor en el mapa
        job_data["$job_index,network"]="$network_time"

    elif [[ "$line" =~ detection-time-processing-score:\ index\ ([0-9]+)\ in\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        detection_time="${BASH_REMATCH[2]}"

        # Almacena o actualiza el valor en el mapa
        job_data["$job_index,detection"]="$detection_time"
    fi

    # Verifica si ambos valores están presentes
    if [[ -n "${job_data["$job_index,network"]}" && -n "${job_data["$job_index,detection"]}" ]]; then
        # Escribe la línea en el CSV
        echo "$job_index,${job_data["$job_index,network"]},${job_data["$job_index,detection"]}" >> "$output_csv"
        
        # Limpia los datos de este índice
        unset job_data["$job_index,network"]
        unset job_data["$job_index,detection"]
    fi

done < "$log_file"

echo "Resultados guardados en $output_csv"

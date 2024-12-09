#!/bin/bash

# Archivo de entrada y salida
log_file="log.txt"
output_csv="jobs.csv"

# Inicializa el mapa asociativo
declare -A map

# Escribe el encabezado del CSV
echo "Job Index,Network duration (ms),Saving Image in Disk (ms), Python preprocessing (ms),Detection time (ms),Job time (ms), All process (ms)" > "$output_csv"

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
    elif [[ "$line" =~ job-processing-score:\ index\ ([0-9]+)\ in\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        job_time="${BASH_REMATCH[2]}"

        # Almacena o actualiza el valor en el mapa
        map["$job_index,job"]="$job_time"
    elif [[ "$line" =~ saving-image-pre-processing-score:\ index\ ([0-9]+)\ in\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        saving_image_time="${BASH_REMATCH[2]}"

        # Almacena o actualiza el valor en el mapa
        map["$job_index,saving-image"]="$saving_image_time"
    elif [[ "$line" =~ completed-processing-score:\ index\ ([0-9]+)\ in\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        completed="${BASH_REMATCH[2]}"

        # Almacena o actualiza el valor en el mapa
        map["$job_index,completed"]="$completed"
    elif [[ "$line" =~ python-preprocessing-time-processing-score:\ index\ ([0-9]+)\ in\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        pythonPreprocessing="${BASH_REMATCH[2]}"

        # Almacena o actualiza el valor en el mapa
        map["$job_index,python-preprocessing"]="$pythonPreprocessing"
    fi



    # Verifica si ambos valores están presentes
    if [[ -n "${map["$job_index,network"]}" && -n "${map["$job_index,detection"]}" && -n "${map["$job_index,job"]}" && -n "${map["$job_index,saving-image"]}" && -n "${map["$job_index,completed"]}" && -n "${map["$job_index,python-preprocessing"]}" ]]; then
        # Escribe la línea en el CSV
        echo "$job_index,${map["$job_index,network"]},${map["$job_index,saving-image"]},${map["$job_index,python-preprocessing"]},${map["$job_index,detection"]},${map["$job_index,job"]},${map["$job_index,completed"]}" >> "$output_csv"
        
        # Limpia los datos de este índice
        unset map["$job_index,network"]
        unset map["$job_index,completed"]
        unset map["$job_index,detection"]
        unset map["$job_index,saving-image"]
        unset map["$job_index,job"]
    fi


done < "$log_file"

echo "Resultados guardados en $output_csv"

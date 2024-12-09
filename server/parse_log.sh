#!/bin/bash

# es necesario para limpiar log viejos adb logcat -c

# Es necesario ejecutar el siguiente comando para copar los log anteriores al archivo log: stdbuf -oL adb logcat | grep -E "processing-score|network-time" > log.txt
# tail -f log.txt para ir viendo los logs que se copiaron
# Archivo de entrada y salida
log_file="log.txt"
output_csv="jobs.csv"

# Inicializa el mapa asociativo
declare -A map
declare -A sums
declare -A sums_squared
declare -A counts

# Inicializa los campos que quieres procesar
fields=("network" "saving-image" "plugin-call" "python-preprocessing" "detection" "job" "completed")

# Escribe el encabezado del CSV
echo "Job Index,Network duration (ms),Saving Image in Disk (ms),Plugin execution (ms),Python preprocessing (ms),Detection time (ms),Job time (ms),All process (ms)" > "$output_csv"

# Procesa cada línea del archivo de logs
while IFS= read -r line; do
    if [[ "$line" =~ network-time:\ index\ ([0-9]+)\ in\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        network_time="${BASH_REMATCH[2]}"
        map["$job_index,network"]="$network_time"

    elif [[ "$line" =~ detection-time-processing-score:\ index\ ([0-9]+)\ in\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        detection_time="${BASH_REMATCH[2]}"
        map["$job_index,detection"]="$detection_time"

    elif [[ "$line" =~ job-processing-score:\ index\ ([0-9]+)\ in\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        job_time="${BASH_REMATCH[2]}"
        map["$job_index,job"]="$job_time"

    elif [[ "$line" =~ saving-image-pre-processing-score:\ index\ ([0-9]+)\ in\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        saving_image_time="${BASH_REMATCH[2]}"
        map["$job_index,saving-image"]="$saving_image_time"

    elif [[ "$line" =~ completed-processing-score:\ index\ ([0-9]+)\ in\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        completed="${BASH_REMATCH[2]}"
        map["$job_index,completed"]="$completed"

    elif [[ "$line" =~ python-preprocessing-time-processing-score:\ index\ ([0-9]+)\ in\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        pythonPreprocessing="${BASH_REMATCH[2]}"
        map["$job_index,python-preprocessing"]="$pythonPreprocessing"

    elif [[ "$line" =~ before-plugin-processing-score:\ index\ ([0-9]+)\ at\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        beforePlugin="${BASH_REMATCH[2]}"
        map["$job_index,before-plugin"]="$beforePlugin"

    elif [[ "$line" =~ in-plugin-processing-score:\ index\ ([0-9]+)\ at\ ([0-9]+) ]]; then
        job_index="${BASH_REMATCH[1]}"
        inPlugin="${BASH_REMATCH[2]}"
        map["$job_index,in-plugin"]="$inPlugin"
    fi

    # Verifica si todos los valores están presentes
    if [[ -n "${map["$job_index,network"]}" && -n "${map["$job_index,detection"]}" && -n "${map["$job_index,job"]}" && -n "${map["$job_index,saving-image"]}" && -n "${map["$job_index,completed"]}" && -n "${map["$job_index,python-preprocessing"]}" && -n "${map["$job_index,before-plugin"]}" && -n "${map["$job_index,in-plugin"]}" ]]; then
        plugin_call_duration=$(( ${map["$job_index,in-plugin"]} - ${map["$job_index,before-plugin"]} ))

        # Escribe la línea en el CSV
        echo "$job_index,${map["$job_index,network"]},${map["$job_index,saving-image"]},$plugin_call_duration,${map["$job_index,python-preprocessing"]},${map["$job_index,detection"]},${map["$job_index,job"]},${map["$job_index,completed"]}" >> "$output_csv"

        # Actualiza las sumas y los conteos para cada campo
        for field in "${fields[@]}"; do
            value="${map["$job_index,$field"]}"
            sums["$field"]=$((sums["$field"] + value))
            sums_squared["$field"]=$((sums_squared["$field"] + value * value))
            counts["$field"]=$((counts["$field"] + 1))
        done

        # Limpia los datos de este índice
        for key in "${fields[@]}" "before-plugin" "in-plugin"; do
            unset map["$job_index,$key"]
        done
    fi

done < "$log_file"

# Calcula el promedio y la desviación estándar para cada campo
averages=()
stddevs=()

for field in "${fields[@]}"; do
    count="${counts["$field"]}"
    sum="${sums["$field"]}"
    sum_squared="${sums_squared["$field"]}"

    if (( count > 0 )); then
        avg=$((sum / count))
        variance=$(( (sum_squared - (sum * sum) / count) / count ))
        stddev=$(awk "BEGIN { print sqrt($variance) }")
    else
        avg=0
        stddev=0
    fi

    averages+=("$avg")
    stddevs+=("$stddev")
done

# Escribe los promedios y desviaciones estándar al final del archivo CSV
echo "Averages,${averages[*]}" >> "$output_csv"
echo "Standard Deviations,${stddevs[*]}" >> "$output_csv"

echo "Resultados guardados en $output_csv"

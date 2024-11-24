#!/bin/bash

# Es necesario ejecutar el siguiente comando para generar el log stdbuf -oL adb logcat | grep -E "Initiating Job at SystemCurrentMillis|runBenchmark: END" > log.txt

# Archivo de entrada y salida
log_file="log.txt"
output_csv="jobs.csv"

# Inicializa variables
job_index=1
current_start=""
echo "Job Index,Start Time (ms),End Time,Duration (ms)" > "$output_csv"  # Escribe el encabezado CSV

convert_to_ms() {
    local time=$1
    local h=$(echo "$time" | cut -d: -f1| sed 's/^0*//')  # Extrae las horas
    local m=$(echo "$time" | cut -d: -f2| sed 's/^0*//')  # Extrae los minutos
    local s_ms=$(echo "$time" | cut -d: -f3| sed 's/^0*//')  # Extrae segundos y milisegundos
    local s=$(echo "$s_ms" | cut -d. -f1| sed 's/^0*//')  # Separa los segundos
    local ms=$(echo "$s_ms" | cut -d. -f2| sed 's/^0*//') # Separa los milisegundos
    # Convierte todo a milisegundos
    echo $(( (h * 3600 + m * 60 + s) * 1000 + ms ))
}

# Procesa cada línea del archivo de logs
while IFS= read -r line; do
    if [[ "$line" =~ Initiating\ Job\ at\ SystemCurrentMillis:\ ([0-9]+) ]]; then
        # Captura el tiempo de inicio
        current_start="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ runBenchmark:\ END ]]; then
        # Extrae la hora de fin (parte de la línea)
        end_time=$(echo "$line" | awk '{print $2}')
        if [[ -n "$current_start" ]]; then
            start_sec=$((current_start / 1000))
            start_ms=$((current_start % 1000))  # Obtenemos los milisegundos
            start_time=$(date -d @$start_sec "+%H:%M:%S")  # Solo hora, minutos, segundos
            start_time="$start_time.$start_ms"  # Agregamos los milisegundos

            end=$(convert_to_ms "$end_time")
            start=$(convert_to_ms "$start_time")


            # Calcula la duración en milisegundos
           duration_ms=$((end - start))

            # Escribe el índice del job, tiempo de inicio y fin al archivo CSV
            echo "$job_index,$start_time,$end_time,$duration_ms" >> "$output_csv"
            job_index=$((job_index + 1))
            current_start=""
        fi
    fi
done < "$log_file"

echo "Resultados guardados en $output_csv"

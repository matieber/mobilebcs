#!/bin/bash

# Es necesario ejecutar el siguiente comando para generar el log stdbuf -oL adb logcat | grep -E "runBenchmark: END" > log.txt

# Archivo de entrada y salida
log_file="log.txt"
output_csv="jobs.csv"

# Inicializa variables
job_index=1
current_start=""
echo "Job Index,Duration (ms)" > "$output_csv"  # Escribe el encabezado CSV


# Procesa cada línea del archivo de logs
while IFS= read -r line; do
    if [[ "$line" =~ runBenchmark:\ END\ with\ processing\ time\ ([0-9]+) ]]; then
        # Extrae la hora de fin (parte de la línea)
          duration_ms="${BASH_REMATCH[1]}"

          # Escribe el índice del job, tiempo de inicio y fin al archivo CSV
          echo "$job_index,$duration_ms" >> "$output_csv"
          job_index=$((job_index + 1))
        
    fi
done < "$log_file"

echo "Resultados guardados en $output_csv"

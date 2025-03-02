#!/bin/bash

input_csv="eugenia-network-2.csv"
output_csv="output.csv"

server_ip="192.168.0.215"
mobile_ip="192.168.0.42"

declare -A sent_packets

# Agregar encabezado al archivo de salida
echo "Time Sent,Time Received,RTT (ms)" > "$output_csv"

while IFS=',' read -r number time source destination protocol length info; do
    # Eliminar comillas de las variables
    source=$(echo "$source" | tr -d '"')
    destination=$(echo "$destination" | tr -d '"')
    info=$(echo "$info" | tr -d '"')

    # Ignorar paquetes malformados
    if [[ $info == *"Malformed Packet"* ]]; then
        echo "Ignorado: paquete malformado \"$info\""
        continue
    fi

    echo "Procesando: \"$source\" -> \"$destination\", Info: \"$info\""

if [[ $source == "$server_ip" && $destination == "$mobile_ip" && $info =~ Seq=([0-9]+).*Len=([0-9]+) ]]; then
        seq=${BASH_REMATCH[1]}
        len=${BASH_REMATCH[2]}

        index=$((seq+len))
        echo "len $seq and $len and $index"
        if [[ -z ${sent_packets["$index"]} ]]; then
            sent_packets["$index"]=$time
            echo "Guardado: Seq=$seq con longitud Len=$len (index $index)enviado a las \"$time\""
        else
            echo "Advertencia: Seq=$seq con longitud Len=$len ya estaba registrado con el tiempo ${sent_packets["$index"]}"
        fi

    elif [[ $source == "$mobile_ip" && $destination == "$server_ip" && $info =~ Ack=([0-9]+) ]]; then
        ack=${BASH_REMATCH[1]}
        echo "Intentando calcular RTT para (Ack=$ack)"

        if [[ -n ${sent_packets["$ack"]} ]]; then
            time_sent=$(echo "${sent_packets[$ack]}" | tr -d '"')
            time_received=$(echo $time | tr -d '"')
            echo "Debug: time_sent=$time_sent, time_received=$time_received"

            if [[ -n $time_sent && -n $time_received ]]; then
                rtt=$(echo "scale=6; ($time_received - $time_sent) * 1000" | bc 2>/dev/null)
                echo "$time_sent,$time_received,$rtt" >> "$output_csv"
                echo "RTT calculado: Seq=$seq, RTT=$rtt ms"
                unset sent_packets["$ack"]
            else
                echo "Error: No se pudo calcular RTT. time_sent=$time_sent, time_received=$time_received"
            fi
        else
            echo "Advertencia: No se encontró tiempo para Seq=$ack"
        fi
    else
        echo "Línea no procesada:"
        echo "  Source: $source"
        echo "  Destination: $destination"
        echo "  Info: $info"
    fi
done < <(tail -n +2 "$input_csv") # Saltar encabezado del archivo CSV

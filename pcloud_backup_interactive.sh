#!/bin/bash

# pCloud Interactive Backup Script using rclone
# Author: Isaac Mateo
# Description: Interactive backup script for pCloud to Synology NAS

REMOTE="pCloud your.email@example.com"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_BASE="$SCRIPT_DIR/pCloud"

echo "=== BACKUP INTERACTIVO pCloud ==="
echo "Destino: $DEST_BASE"

# Get list of root folders from pCloud
mapfile -t FOLDERS < <(rclone lsd "$REMOTE:" --tpslimit 2 | awk '{$1=$2=$3=$4=""; print substr($0,5)}' | sed 's/^[ \t]*//')

echo "Carpetas disponibles:"
for i in "${!FOLDERS[@]}"; do
    echo "[$i] ${FOLDERS[$i]}"
done

echo "Introduce numeros (ej: 0 2 5):"
read selection

# Process selection
declare -a SELECTED=()
for num in $selection; do
    if [[ $num =~ ^[0-9]+$ ]] && [ $num -lt ${#FOLDERS[@]} ]; then
        SELECTED+=("${FOLDERS[$num]}")
    fi
done

echo "Carpetas seleccionadas:"
printf '%s\n' "${SELECTED[@]}"

read -p "Continuar? (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "Backup cancelado"
    exit 0
fi

# Create destination directory
mkdir -p "$DEST_BASE"

# Start backup process
echo "Iniciando backup..."
for folder in "${SELECTED[@]}"; do
    echo "======================"
    echo "Sincronizando: '$folder'"
    echo "Origen: $REMOTE:/$folder"
    echo "Destino: $DEST_BASE/$folder"
    echo "======================"
    
    rclone sync "$REMOTE:/$folder" "$DEST_BASE/$folder" \
        --progress \
        --tpslimit 2 \
        --retries 3 \
        --stats 30s \
        --stats-one-line \
        --verbose
    
    if [ $? -eq 0 ]; then
        echo "✓ Completada: $folder"
    else
        echo "✗ Error en: $folder"
    fi
done

echo "=============================="
echo "Backup completado en: $DEST_BASE"
echo "=============================="

#!/bin/bash

# pCloud Interactive Backup Script using rclone
# Author: Isaac Mateo
# Description: Interactive backup script for pCloud with optimized rate limits

REMOTE="pCloud your.email@example.com"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_BASE="$SCRIPT_DIR/pCloud"

echo "=================================================================="
echo "                  BACKUP INTERACTIVO pCloud"
echo "=================================================================="
echo "Destino: $DEST_BASE"
echo "=================================================================="

# Get list of root folders from pCloud
mapfile -t FOLDERS < <(rclone lsd "$REMOTE:" --tpslimit 3 | awk '{$1=$2=$3=$4=""; print substr($0,5)}' | sed 's/^[ \t]*//')

echo ""
echo "Carpetas disponibles:"
for i in "${!FOLDERS[@]}"; do
    echo "[$i] ${FOLDERS[$i]}"
done

echo ""
echo "Introduce numeros (ej: 0 2 5):"
read selection

# Process selection
declare -a SELECTED=()
for num in $selection; do
    if [[ $num =~ ^[0-9]+$ ]] && [ $num -lt ${#FOLDERS[@]} ]; then
        SELECTED+=("${FOLDERS[$num]}")
    fi
done

echo ""
echo "Carpetas seleccionadas:"
printf '%s\n' "${SELECTED[@]}"

echo ""
read -p "Continuar? (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "Backup cancelado"
    exit 0
fi

# Create destination directory
mkdir -p "$DEST_BASE"

# Start backup process with optimized settings
echo ""
echo "Iniciando backup con configuración optimizada..."
for folder in "${SELECTED[@]}"; do
    echo ""
    echo "=================================================================="
    echo "  SINCRONIZANDO: $folder"
    echo "------------------------------------------------------------------"
    echo "  Origen:  $REMOTE:/$folder"
    echo "  Destino: $DEST_BASE/$folder"
    echo "=================================================================="
    echo ""
    
    rclone sync "$REMOTE:/$folder" "$DEST_BASE/$folder" \
        --progress \
        --tpslimit 3 \
        --transfers 6 \
        --checkers 8 \
        --retries 10 \
        --low-level-retries 100 \
        --stats 15s \
        --stats-one-line \
        --stats-unit bytes \
        --human-readable \
        -v
    
    echo ""
    echo "=================================================================="
    if [ $? -eq 0 ]; then
        echo "  ✓ COMPLETADA: $folder"
    else
        echo "  ✗ ERROR EN: $folder"
    fi
    echo "=================================================================="
    echo ""
done

echo ""
echo "=================================================================="
echo "                     BACKUP COMPLETADO"
echo "=================================================================="
echo "  Ubicación: $DEST_BASE"
echo "=================================================================="

#!/bin/bash
# dev-mode.sh - Entwicklungs-Modus mit Hot Reload

# Farben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 KI-Wissenssystem Entwicklungs-Modus${NC}"
echo

# Prüfe ob Virtual Environment aktiv ist
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo -e "${YELLOW}⚠️  Aktiviere Virtual Environment...${NC}"
    source venv/bin/activate
fi

# Prüfe ob Docker Services laufen
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${YELLOW}⚠️  Starte Docker Services...${NC}"
    docker-compose up -d neo4j chromadb redis
    echo "Warte auf Services..."
    sleep 10
fi

echo -e "${GREEN}✅ Services bereit${NC}"
echo
echo -e "${BLUE}📋 Entwicklungs-Optionen:${NC}"
echo "1. API Server starten (Hot Reload)"
echo "2. Plugin Watch-Modus starten"
echo "3. Beide starten (empfohlen)"
echo "4. Nur Services prüfen"
echo

read -p "Auswahl (1-4): " choice

case $choice in
    1)
        echo -e "${BLUE}🔥 Starte API Server mit Hot Reload...${NC}"
        echo "Code-Änderungen werden automatisch übernommen!"
        echo "API Docs: http://localhost:8080/docs"
        echo
        export PYTHONPATH="${PYTHONPATH}:${PWD}"
        uvicorn src.api.main:app --reload --host 0.0.0.0 --port 8080
        ;;
    2)
        echo -e "${BLUE}👀 Starte Plugin Watch-Modus...${NC}"
        if [ -d "../obsidian-ki-plugin" ]; then
            cd ../obsidian-ki-plugin
            echo "Plugin-Änderungen werden automatisch gebaut!"
            echo "In Obsidian: Cmd+R zum Neuladen"
            npm run dev
        else
            echo -e "${YELLOW}⚠️  Plugin-Verzeichnis nicht gefunden${NC}"
        fi
        ;;
    3)
        echo -e "${BLUE}🔥👀 Starte API + Plugin Watch-Modus...${NC}"
        echo "Öffne neues Terminal für jeden Prozess:"
        echo
        echo -e "${GREEN}Terminal 1 (API):${NC}"
        echo "./dev-mode.sh → Option 1"
        echo
        echo -e "${GREEN}Terminal 2 (Plugin):${NC}"
        echo "./dev-mode.sh → Option 2"
        echo
        echo "Oder verwende tmux/screen für beide gleichzeitig."
        ;;
    4)
        echo -e "${BLUE}🔍 Service-Status:${NC}"
        docker-compose ps
        echo
        echo -e "${BLUE}🌐 URLs:${NC}"
        echo "API Docs:  http://localhost:8080/docs"
        echo "Neo4j:     http://localhost:7474"
        echo "ChromaDB:  http://localhost:8000"
        ;;
    *)
        echo -e "${YELLOW}⚠️  Ungültige Auswahl${NC}"
        ;;
esac 
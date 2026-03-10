#!/bin/bash
# Install script for NTFS macOS Driver
# Устанавливает зависимости: macFUSE и ntfs-3g

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Установка NTFS Driver for macOS${NC}"
echo ""

# Проверка macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Этот скрипт только для macOS${NC}"
    exit 1
fi

# Проверка Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}⚠️  Homebrew не установлен. Устанавливаю...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo -e "${BLUE}📦 Установка macFUSE...${NC}"
brew install --cask macfuse

echo -e "${BLUE}📦 Установка ntfs-3g...${NC}"
brew install ntfs-3g

echo -e "${BLUE}📦 Установка Python зависимостей...${NC}"
pip3 install --user -r requirements.txt 2>/dev/null || true

# Создание директории для программы
INSTALL_DIR="/usr/local/bin"
mkdir -p "$INSTALL_DIR"

# Копирование CLI
echo -e "${BLUE}📋 Установка CLI...${NC}"
cp src/ntfs-driver.py "$INSTALL_DIR/ntfs-driver"
chmod +x "$INSTALL_DIR/ntfs-driver"

# Проверка установки
echo ""
echo -e "${GREEN}✅ Установка завершена!${NC}"
echo ""
echo "Использование:"
echo "  ntfs-driver list              # Показать диски"
echo "  ntfs-driver mount disk2s1     # Монтировать NTFS"
echo "  ntfs-driver unmount disk2s1   # Размонтировать"
echo ""
echo -e "${YELLOW}⚠️  Важно: после установки macFUSE может потребоваться перезагрузка${NC}"

#!/bin/bash
# Launch script for NTFS Driver GUI

echo "🚀 Запуск NTFS Driver GUI..."

# Проверка наличия macFUSE
if [ ! -d "/Library/Frameworks/macFUSE.framework" ]; then
    echo "⚠️  ВНИМАНИЕ: macFUSE не установлен!"
    echo ""
    echo "Для работы приложения необходимо установить macFUSE:"
    echo "1. Откройте: https://github.com/osxfuse/osxfuse/releases"
    echo "2. Скачайте последнюю версию"
    echo "3. Установите и перезагрузите Mac"
    echo ""
    read -p "Продолжить без macFUSE? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Проверка наличия Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode не установлен. Установите Xcode из App Store."
    exit 1
fi

# Запуск через Xcode
cd "$(dirname "$0")/NTFSDriverGUI"
echo "📱 Открытие проекта в Xcode..."
open NTFSDriverGUI.xcodeproj

echo ""
echo "✅ Проект открыт в Xcode"
echo "Нажмите Cmd+R для запуска"

#!/bin/bash
# Build script - создаёт DMG для распространения

set -e

APP_NAME="NTFS Driver"
VERSION="1.0.0"
BUILD_DIR="build"
DMG_NAME="NTFS-Driver-${VERSION}.dmg"

echo "🔨 Сборка ${APP_NAME} v${VERSION}"

# Очистка
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Копирование файлов
cp -r src "$BUILD_DIR/"
cp -r scripts "$BUILD_DIR/"
cp README.md "$BUILD_DIR/"
cp requirements.txt "$BUILD_DIR/"
cp LICENSE "$BUILD_DIR/" 2>/dev/null || echo "LICENSE not found"

# Создание скрипта запуска
cat > "$BUILD_DIR/NTFS-Driver.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
python3 src/ntfs-driver.py "$@"
EOF
chmod +x "$BUILD_DIR/NTFS-Driver.command"

# Создание DMG (требует create-dmg через Homebrew)
if command -v create-dmg &> /dev/null; then
    echo "📦 Создание DMG..."
    create-dmg \
        --volname "NTFS Driver Installer" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --app-drop-link 450 185 \
        "$DMG_NAME" \
        "$BUILD_DIR"
    echo "✅ Создан: $DMG_NAME"
else
    echo "⚠️  create-dmg не установлен. Установите: brew install create-dmg"
    echo "📁 Собрано в папке: $BUILD_DIR"
fi

echo "✅ Сборка завершена!"

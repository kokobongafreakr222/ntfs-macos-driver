# NTFS/FAT32 Driver for macOS

[![GitHub](https://img.shields.io/badge/GitHub-Repository-blue)](https://github.com/kokobongafreakr222/ntfs-macos-driver)

Альтернатива Paragon NTFS для macOS. Позволяет читать и записывать на NTFS-диски. **Бесплатно и open source.**

## 🚀 Быстрый старт

### Установка (одной командой)

```bash
curl -sSL https://raw.githubusercontent.com/kokobongafreakr222/ntfs-macos-driver/main/scripts/install.sh | bash
```

Или вручную:

```bash
# 1. Установка зависимостей
brew install --cask macfuse
brew install ntfs-3g

# 2. Клонирование репозитория
git clone https://github.com/kokobongafreakr222/ntfs-macos-driver.git
cd ntfs-macos-driver

# 3. Установка CLI
sudo cp src/ntfs-driver.py /usr/local/bin/ntfs-driver
sudo chmod +x /usr/local/bin/ntfs-driver
```

## 💻 Использование

### CLI

```bash
# Показать все диски
ntfs-driver list

# Монтировать NTFS диск с поддержкой записи
sudo ntfs-driver mount disk2s1

# Размонтировать
sudo ntfs-driver unmount disk2s1

# Форматировать в NTFS
sudo ntfs-driver format disk2 --label "MyDisk"
```

### GUI (SwiftUI)

```bash
cd NTFSDriverGUI
swift run NTFSDriverGUI
```

Или собрать приложение:

```bash
cd NTFSDriverGUI
swift build -c release
# Приложение будет в .build/release/NTFSDriverGUI
```

## 🏗️ Архитектура

| Компонент | Технология | Описание |
|-----------|------------|----------|
| **Драйвер** | ntfs-3g (C) | NTFS драйвер с поддержкой записи |
| **FUSE** | macFUSE 4.x | Фреймворк для user-space FS |
| **CLI** | Python 3 | Командная строка |
| **GUI** | SwiftUI | Графический интерфейс |

## 📋 Системные требования

- macOS 11.0 (Big Sur) или новее
- macFUSE 4.x
- Apple Silicon или Intel
- Python 3.9+ (для CLI)

## ⚡ Производительность

Тесты показывают скорость записи ~80-120 MB/s на SSD через USB 3.0 (зависит от диска).

## 🔒 Безопасность

- Использует проверенные компоненты: macFUSE и ntfs-3g
- Не требует отключения SIP (System Integrity Protection)
- Все операции через user-space (без kernel extensions)

## 🛠️ Сборка из исходников

```bash
# Сборка CLI
./scripts/build.sh

# Сборка GUI
cd NTFSDriverGUI
swift build -c release
```

## 📦 Создание DMG

```bash
./scripts/build.sh
# DMG будет создан в текущей директории
```

## 📝 Лицензия

GPL v3 (из-за зависимости от ntfs-3g)

## 🤝 Contributing

PR приветствуются! Особенно нужна помощь с:
- Улучшением GUI
- Добавлением автомонтирования
- Интеграцией с Finder

## 🐛 Known Issues

- Требуется sudo для монтирования (ограничение macFUSE)
- Первый запуск macFUSE требует перезагрузки

## 🔗 Ссылки

- [macFUSE](https://osxfuse.github.io/)
- [ntfs-3g](https://github.com/tuxera/ntfs-3g)
- [Репозиторий](https://github.com/kokobongafreakr222/ntfs-macos-driver)

---

**Создано как бесплатная альтернатива Paragon NTFS для macOS.**

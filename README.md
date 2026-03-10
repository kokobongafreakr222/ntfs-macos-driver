# NTFS/FAT32 Driver for macOS

Альтернатива Paragon NTFS для macOS. Позволяет читать и записывать на NTFS-диски.

## Быстрый старт

```bash
# Установка через Homebrew
brew install --cask macfuse
brew install ntfs-3g

# Запуск драйвера
./ntfs-driver mount /dev/disk2s1 /Volumes/MyDisk
```

## Архитектура

- **ntfs-3g** - драйвер NTFS с поддержкой записи
- **macFUSE** - фреймворк для user-space файловых систем
- **SwiftUI GUI** - интерфейс для управления
- **CLI** - командная строка для автоматизации

## Системные требования

- macOS 11.0 (Big Sur) или новее
- macFUSE 4.x
- Apple Silicon или Intel

## Лицензия

GPL v3 (из-за ntfs-3g)

## Автор

Created for personal use as Paragon NTFS alternative.

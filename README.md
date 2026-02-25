# xOneCloud / UnlockUserT — Instaladores

Instaladores multiplataforma para o xOneCloud (UnlockUserT).

## Download

Binários disponíveis via [GitHub Releases](https://github.com/luizfcaleffi/tools-installer/releases):

| Plataforma | Arquivo | Arquitetura |
|-----------|---------|-------------|
| Windows | `unlockusert-setup-2.6.1-x64.exe` | x64 |
| Linux (Debian) | `unlockusert-setup-2.6.1-x64.deb` | x64 |
| macOS | `xone-setup-2.6.1-osx-arm64.pkg` | Apple Silicon |
| macOS | `xone-setup-2.6.1-osx-x64.pkg` | Intel |

## Verificação de integridade

Cada release inclui um arquivo `checksums.sha256`. Após o download:

```bash
# Linux/macOS
sha256sum -c checksums.sha256

# PowerShell
Get-FileHash <arquivo> -Algorithm SHA256
```

## Plataformas suportadas

- **Windows** 10/11 (x64)
- **Linux** Debian/Ubuntu (x64)
- **macOS** 12+ (Apple Silicon e Intel)

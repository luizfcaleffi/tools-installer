# xOneCloud — Serviço de Eficiência Digital

Scripts de instalação multiplataforma e documentação de processos para o xOne Cloud (UnlockUserT) na MadeiraMadeira.

**Parque-alvo:** ~800 seats | **SOs:** Windows, Linux, macOS | **Versão atual:** 2.6.1

---

## Scripts de instalação

| SO | Script | Mecanismo |
|----|--------|-----------|
| Windows | `windows/install_unlock_web.bat` | GPO startup script |
| Linux | `linux/install-unlockusert.sh` | ScreenConnect (sudo) |
| macOS | `macos/install-unlockusert.sh` | ScreenConnect + aprovação do usuário |

Todos os scripts incluem validação automática dos processos do agente ao final da instalação.

## Binários

Disponíveis via [GitHub Releases](https://github.com/luizfcaleffi/tools-installer/releases):

| Plataforma | Arquivo | Arquitetura |
|-----------|---------|-------------|
| Windows | `unlockusert-setup-2.6.1-x64.exe` | x64 |
| Linux (Debian) | `unlockusert-setup-2.6.1-x64.deb` | x64 |
| macOS | `xone-setup-2.6.1-osx-arm64.pkg` | Apple Silicon |
| macOS | `xone-setup-2.6.1-osx-x64.pkg` | Intel |

Cada release inclui `checksums.sha256` para verificação de integridade.

## Plataformas suportadas

- **Windows** 10/11 (x64)
- **Linux** Debian/Ubuntu (x64)
- **macOS** 12+ (Apple Silicon e Intel)

---

## Documentação

| Documento | Descrição |
|-----------|-----------|
| [Processo de Implantação](docs/processo-implantacao.md) | Waves, fluxo por SO, validação, governança |
| [Serviço de Eficiência Digital](docs/servico-eficiencia-digital.md) | Arquitetura de processos, RACI, domínios |
| [Runbook Suporte L1](docs/runbook-suporte-l1.md) | Situações comuns, escalação, template de ticket |
| [Extensão Chrome — Linux](docs/chrome-extension-linux.md) | Deploy via GWS policy + fallback script |
| [Bug: token debconf](docs/bug-token-debconf.md) | Token vazio via debconf no Linux |
| [Instalador macOS](docs/install-unlockusert.md) | TCC, testes, histórico |

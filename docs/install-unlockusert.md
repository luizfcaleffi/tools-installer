# install-unlockusert.sh (macOS)

## Descrição

Script Shell para instalação silenciosa do xOne Agent (UnlockUserT) em estações macOS.
Utiliza o instalador nativo `.pkg` e injeta o token via arquivo temporário `/tmp/.xone_token`,
que é o mecanismo esperado pelo postinstall do pacote.

## Pré-requisitos

| Requisito | Detalhe |
|-----------|---------|
| **macOS** | 13+ (Ventura, Sonoma, Sequoia) |
| **Permissão** | Execução como root (`sudo`) |
| **Pacote .pkg** | Download automático ou disponível em `/tmp/` (ou via `--pkg`) |
| **Internet** | Necessária para download automático do `.pkg` |
| **Arquiteturas** | Apple Silicon (`arm64`) e Intel (`x86_64`) |

## Uso

```bash
# Instalação padrão (detecta .pkg em /tmp/ e usa token embutido)
sudo ./scripts/install-unlockusert.sh

# Token customizado
sudo ./scripts/install-unlockusert.sh --token "TOKEN_JWT_AQUI"

# Pacote .pkg em caminho específico
sudo ./scripts/install-unlockusert.sh --pkg /caminho/local/xone-setup.pkg

# Combinando opções
sudo ./scripts/install-unlockusert.sh --token "TOKEN" --pkg /Users/admin/Downloads/xone-setup-2.6.1-osx-arm64.pkg
```

## Parâmetros

| Parâmetro | Obrigatório | Padrão | Descrição |
|-----------|:-----------:|--------|-----------|
| `--token` | Não | Token embutido no script | Token JWT customizado |
| `--pkg` | Não | Auto-detecta em `/tmp/` | Caminho local do pacote `.pkg` |
| `--help` | — | — | Exibe ajuda e sai |

## Etapas de execução

1. **Localiza ou baixa o .pkg** — procura em `/tmp/` pelo padrão `xone-setup-*-osx-{arch}.pkg`; se não encontrar, baixa automaticamente do repositório [`tools-installer`](https://github.com/luizfcaleffi/tools-installer)
2. **Configura o token** — escreve o token JWT em `/tmp/.xone_token` (o postinstall do .pkg lê deste arquivo)
3. **Instala silenciosamente** — executa `installer -pkg ... -target /`
4. **Limpeza e verificação** — remove o arquivo de token, verifica se o diretório do agente existe e se os processos estão rodando
5. **Remove o .pkg** — apaga o pacote baixado de `/tmp/` (se foi download automático)

## Mecanismo do token (macOS vs Linux)

| Plataforma | Mecanismo | Detalhe |
|------------|-----------|---------|
| **macOS** | Arquivo temporário | Token escrito em `/tmp/.xone_token`, lido pelo postinstall do .pkg |
| **Linux** | Variável de ambiente | `TOKEN="..." dpkg -i pacote.deb`, lido pelo postinst do .deb |

No macOS, o instalador `.pkg` não suporta variáveis de ambiente no postinstall da mesma forma que o Linux.
O mecanismo oficial é gravar o token em `/tmp/.xone_token` antes de executar o `installer`.

## Detecção de arquitetura

O script detecta automaticamente a arquitetura via `uname -m`:

| `uname -m` | Arquitetura | Pacote esperado |
|-------------|-------------|-----------------|
| `arm64` | Apple Silicon (M1/M2/M3/M4) | `xone-setup-*-osx-arm64.pkg` |
| `x86_64` | Intel | `xone-setup-*-osx-x64.pkg` |

## Arquivos e diretórios

| Caminho | Descrição |
|---------|-----------|
| `/tmp/.xone_token` | Arquivo temporário do token (removido após instalação) |
| `/tmp/unlockusert_install.log` | Log da instalação |
| `/Library/xone-agent/` | Diretório de instalação do agente |
| `/Library/xone-agent/uninstall.sh` | Script de desinstalação |

## Desinstalação

```bash
sudo bash /Library/xone-agent/uninstall.sh
```

## Permissões TCC (sem MDM)

O macOS possui o sistema **TCC** (Transparency, Consent, and Control) que exige consentimento explícito do usuário para certas permissões. Como **não temos MDM** (Jamf, Mosyle, Intune, etc.), não é possível pré-aprovar permissões via perfil PPPC.

**Impacto prático:**

| O que funciona silencioso | O que precisa de aprovação manual |
|---------------------------|-----------------------------------|
| Instalação do `.pkg` via `sudo installer` | Accessibility (interação com sessão do usuário) |
| Token gravado via `/tmp/.xone_token` | Full Disk Access (se o agente precisar) |
| Serviços iniciados via LaunchDaemon | Screen Recording (se capturar tela) |

Após a instalação, o **usuário verá um popup** no macOS pedindo para aprovar permissões em:
**System Settings > Privacy & Security > Accessibility**

Sem essa aprovação manual, o agente pode não funcionar completamente (monitoramento de sessão, lock de tela, etc.).

> **Nota:** Com um MDM, seria possível enviar um perfil PPPC pré-aprovando o app e tornando o deploy 100% silencioso.

## Repositório de instaladores

Os pacotes `.pkg` são hospedados no repositório público [`tools-installer`](https://github.com/luizfcaleffi/tools-installer) via Git LFS.

| Arquivo | Plataforma | Tamanho |
|---------|------------|---------|
| `xone-setup-2.6.1-osx-arm64.pkg` | macOS Apple Silicon | ~55 MB |
| `xone-setup-2.6.1-osx-x64.pkg` | macOS Intel | ~56 MB |
| `unlockusert-setup-2.6.1-x64.deb` | Linux (Debian/Ubuntu) | ~23 MB |
| `unlockusert-setup-2.6.1-x64.exe` | Windows | ~137 MB |

O script baixa automaticamente o `.pkg` correto para a arquitetura detectada. Se o pacote já existir em `/tmp/`, o download é pulado.

## Testes realizados

### 2026-02-18 — MM-NB-D20GVYQKL9 (Apple Silicon M4)

| Etapa | Resultado |
|-------|-----------|
| Download do .pkg | OK — `xone-setup-2.6.1-osx-arm64.pkg` baixado automaticamente |
| Token | OK — gravado em `/tmp/.xone_token` |
| Instalação | OK — `installer -pkg` concluído com sucesso |
| Agente instalado | OK — `/Library/xone-agent/` presente |
| Token no config | OK — verificado |
| Reportou na console | OK — máquina apareceu na console xOne Cloud |

### 2026-02-18 — MM-NB-CM9D95XMQF (Apple Silicon M4)

| Etapa | Resultado |
|-------|-----------|
| Download do .pkg | OK — `xone-setup-2.6.1-osx-arm64.pkg` baixado automaticamente |
| Token | OK — gravado em `/tmp/.xone_token` |
| Instalação | OK — `installer -pkg` concluído com sucesso |
| Agente instalado | OK — `/Library/xone-agent/` presente |
| Token no config | OK — verificado |
| Reportou na console | OK — máquina apareceu na console xOne Cloud |

> Ambos os testes realizados via ferramenta de acesso remoto, executando o script em background. Arquitetura `arm64` detectada automaticamente.

## Observações

- O script baixa o `.pkg` automaticamente se não encontrar em `/tmp/` (ou pode ser informado via `--pkg`)
- O `.pkg` baixado é removido de `/tmp/` após a instalação
- O script remove o arquivo de token por segurança — o JWT não fica exposto após a instalação
- Sem MDM, o usuário precisará aprovar permissões de Accessibility manualmente no macOS

## Histórico

| Data | Alteração |
|------|-----------|
| 2026-02-18 | Criação do script com detecção automática de arquitetura e token via `/tmp/.xone_token` |
| 2026-02-18 | Adicionado download automático do `.pkg` a partir do repo `tools-installer` |
| 2026-02-18 | Versão atualizada de 2.5.5 para 2.6.1 (alinhada com Linux/Windows) |
| 2026-02-18 | Documentada limitação de permissões TCC sem MDM (Accessibility requer aprovação manual) |
| 2026-02-18 | Repo `tools-installer` criado como público — clone do `tallysonMM/nova_iniciativa` com `.pkg` do macOS adicionados |
| 2026-02-18 | URL de download alterada de GitHub Releases para raw (funciona com LFS em repo público) |
| 2026-02-18 | URL do `linux-scripts` migrada de `tallysonMM/nova_iniciativa` para `tools-installer` |
| 2026-02-18 | Teste em 2 Macs M4 (MM-NB-D20GVYQKL9, MM-NB-CM9D95XMQF) — instalação e token OK |

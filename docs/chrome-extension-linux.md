# Extensao Chrome — xOne xTension (Linux only)

A extensao **xOne xTension** e responsavel por capturar URLs acessadas no navegador.
No Windows o agente captura URLs por outro mecanismo — a extensao e obrigatoria **apenas no Linux**.

## Dados da extensao

| Campo | Valor |
|-------|-------|
| Nome | xOne xTension |
| Chrome Web Store ID | `ofgdpbaonocecajlocljjeigbfnjleii` |
| Funcao | Captura de URLs do navegador para o agente xOne |
| Plataforma | Linux (obrigatoria), Windows (desnecessaria) |

## Deploy via Google Workspace (metodo principal)

Gerenciado centralmente via Google Admin Console — aplica automaticamente para membros do grupo.

### Grupo de seguranca

| Campo | Valor |
|-------|-------|
| Grupo | `unlock-chrome-extension@madeiramadeira.com.br` |
| Escopo | Usuarios Linux com agente xOne instalado |
| Gerenciar membros | `admin.google.com` > Directory > Groups |

### Configuracao da policy

1. `admin.google.com` > **Devices** > **Chrome** > **Apps & extensions**
2. Aba **Users & browsers**
3. No painel esquerdo, secao **Groups** > selecionar `unlock-chrome-extension`
4. Clicar **+** (botao amarelo) > **Add from Chrome Web Store**
5. Buscar pelo ID: `ofgdpbaonocecajlocljjeigbfnjleii`
6. Configurar:

| Opcao | Valor | Motivo |
|-------|-------|--------|
| **Installation policy** | **Force install** | Instala automaticamente, usuario nao pode remover |
| **Version pinning** | Nao fixar | Deixar atualizar automaticamente |
| **Incognito mode** | Off | Coleta de URL nao precisa funcionar em incognito |
| **Chrome Web Store Recommended** | Off | Ja e forcada, nao precisa recomendar |
| **Permissions and URL access** | Default | Usa as permissoes declaradas no manifest |
| **Blocked/Allowed hosts** | Vazio | Precisa capturar URLs de qualquer site |

7. Salvar

### Validacao

Apos aplicar a policy, validar que a extensao foi instalada:

**Via Admin Console:**
- **Reporting > Audit and investigation > Admin log events**
  - Event name: Chrome app or extension installation
  - Filtrar por data
- **Devices > Chrome > Managed browsers** (se Chrome Browser Cloud Management ativo)
  - Buscar pelo hostname (ex: `MM-NB-3VDH7W3`)
  - Aba Extensions > verificar xOne xTension

**Via maquina do usuario:**
- `chrome://extensions/` — extensao aparece como "installed by your organization"
- `chrome://policy/` — extensao listada em `ExtensionInstallForcelist`

### Adicionar novos usuarios Linux

1. Instalar o agente xOne via `install-unlockusert.sh`
2. Adicionar o email do usuario ao grupo `unlock-chrome-extension@madeiramadeira.com.br`
3. Extensao sera instalada automaticamente no proximo sync do Chrome

## Deploy via script (fallback)

Para maquinas que nao estao logadas na conta corporativa ou como fallback.

### Instalacao completa (agente + extensao)

```bash
sudo bash install-unlockusert.sh
```

A etapa [5/5] do script cria a policy local em `/etc/opt/chrome/policies/managed/xone_xtension.json`.
Pode ser pulada com `--skip-chrome` se a extensao ja foi aplicada via GWS.

### Apenas extensao (maquinas com xOne ja instalado)

```bash
sudo bash fix-chrome-extension.sh
```

Cria a mesma policy local. Util para maquinas que ja tinham o agente mas faltava a extensao.

### Como funciona a policy local

O script cria o arquivo `/etc/opt/chrome/policies/managed/xone_xtension.json`:

```json
{
  "ExtensionInstallForcelist": [
    "ofgdpbaonocecajlocljjeigbfnjleii;https://clients2.google.com/service/update2/crx"
  ]
}
```

O Chrome le policies JSON deste diretorio ao iniciar. A extensao e baixada da Chrome Web Store automaticamente.

**Limitacao:** so funciona com Chrome instalado via .deb (nao Snap). A policy via GWS nao tem essa limitacao.

## Referencia

- [Guia xOne - Download e Instalacao (PDF)](https://xonecloud.com.br/wp-content/uploads/2025/03/Guia-Download-e-Instalacao-do-xOne.pdf) — pagina 36
- [Chrome Enterprise - Force install extensions](https://support.google.com/chrome/a/answer/6306504)
- [Chrome policies no Linux](https://chromeenterprise.google/policies/)

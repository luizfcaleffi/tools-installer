# Bug: Token vazio na instalação silenciosa do xOne Agent

## Resumo

Instalações silenciosas do xOne Agent via `DEBIAN_FRONTEND=noninteractive` resultavam em **token vazio**, fazendo com que o agente não reportasse na console xOne Cloud.

## Causa raiz

O `postinst` do pacote xone (`/var/lib/dpkg/info/xone.postinst`) possui dois caminhos para receber o token:

```sh
# Caminho 1: variável de ambiente (funciona)
if [ -n "$TOKEN" ]; then
  USER_INPUT="$TOKEN"
else
  # Caminho 2: debconf (NÃO funciona em modo silencioso)
  db_fset xone/token seen false
  db_set xone/token ""          # <-- ZERA o valor antes de ler!
  db_input high xone/token
  db_go
  db_get xone/token
  USER_INPUT="$RET"
fi
```

O script original usava `debconf-set-selections` para pré-configurar o token e depois `DEBIAN_FRONTEND=noninteractive dpkg -i`. Porém o postinst **zera o debconf** (`db_set xone/token ""`) antes de exibir o dialog, descartando o valor que setamos.

Com `DEBIAN_FRONTEND=noninteractive`, o dialog é pulado e o token fica vazio.

## Correção no script

Usar a **variável de ambiente** `TOKEN=` ao invés de `debconf-set-selections`:

```bash
# Errado (token vazio)
echo "xone xone/token string $TOKEN" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg -i pacote.deb

# Correto (token aplicado)
TOKEN="$TOKEN" DEBIAN_FRONTEND=noninteractive dpkg -i pacote.deb
```

Corrigido no commit `ecd5c4f` em 2026-02-18.

## Onde o token é gravado

O postinst salva o token em:

```
/usr/local/etc/xone-agent.config
```

No campo `AgentToken`:

```json
{
  "AgentToken": "eyJhbGci...",
  "InstallPath": "/usr/local/xone-agent",
  ...
}
```

## Reparo em máquinas já instaladas com token vazio

Para máquinas que já foram instaladas com o bug (token vazio), executar **4 comandos** via acesso remoto:

### 1. Salvar o token num arquivo temporário

```bash
echo 'SEU_TOKEN_AQUI' > /tmp/xone_token
```

### 2. Injetar o token no config

```bash
sudo python3 -c "import json;t=open('/tmp/xone_token').read().strip();f='/usr/local/etc/xone-agent.config';d=json.load(open(f));d['AgentToken']=t;json.dump(d,open(f,'w'),indent=2)"
```

### 3. Limpar possíveis quebras de linha (ferramentas remotas podem inserir \n)

```bash
sudo python3 -c "import json;f='/usr/local/etc/xone-agent.config';d=json.load(open(f));d['AgentToken']=d['AgentToken'].replace('\n','').replace(' ','');json.dump(d,open(f,'w'),indent=2)"
```

### 4. Reiniciar os serviços

```bash
sudo systemctl restart xOneLicenseManager xOneHeartBeat xOneEventSender
```

### Validação

```bash
cat /usr/local/etc/xone-agent.config
```

O campo `AgentToken` deve conter o token JWT completo, sem espaços ou quebras de linha. Após o restart, a máquina deve aparecer na console xOne Cloud.

## Observações

- O `sed` não é confiável para injetar o token via ferramentas remotas com limite de caracteres (o token JWT tem ~600 chars e o comando é truncado)
- A abordagem `echo > arquivo` + `python3` é mais robusta para ferramentas com restrição de output
- Ferramentas de acesso remoto (tipo xOne Locker) podem inserir `\n` em strings longas — o passo 3 limpa isso

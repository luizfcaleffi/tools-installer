# Processo de Implantação xOne — 800 Seats / 3 SOs

**Versão:** 1.0 | **Data:** Abr 2026
**Parque total:** 1.500 equipamentos | **Meta:** ~800 seats ativos
**SOs suportados:** Windows, Linux, macOS

---

## 1. Elegibilidade

### Critério base
Colaboradores com cargo **IC Analista ou IC Especialista** recebem o xOne por padrão.

### Exclusões (não instalar)
- Cargos com baixa aderência digital (operacional de campo, logística física, etc.)
- Equipamentos compartilhados sem usuário fixo
- Dispositivos em processo de descomissionamento

### Ação necessária
Cruzar headcount RH (1.500) com lista de cargos elegíveis → gerar **inventário-alvo (~800 equipamentos)** como base das waves.

---

## 2. Situação atual e transição dos 200 existentes

Os 200 usuários atuais da POC precisam ser revisados antes da expansão:

| Status | Ação |
|--------|------|
| Elegível (critério acima) | Manter — nenhuma ação necessária |
| Não elegível | Remover licença e desinstalar agente |
| Máquina ativa mas agente offline | Verificar no console e reinstalar se necessário |

A lista de "manter / remover" deve ser gerada antes de iniciar a Wave 1 da expansão.

---

## 3. Waves de implantação

| Wave | Escopo sugerido | Est. máquinas | Critério |
|------|----------------|---------------|----------|
| 0 — Revisão POC | Usuários atuais (200) | ~200 | Manter elegíveis, remover demais |
| 1 — TI + CSC + Finance | Áreas próximas do time de Infra | ~150 | Validação rápida, suporte facilitado |
| 2 — Revenue + Guide Shop | Alto volume de chamados de acesso | ~200 | ROI mais visível |
| 3 — Supply Chain + CX | Operação distribuída | ~150 | Pode exigir mais suporte mac/linux |
| 4 — Restante elegível | Completar cobertura | ~100 | Mop-up final |

**Ritmo sugerido:** 1 wave a cada 2–3 semanas, dependendo da capacidade do time.

---

## 4. Fluxo de instalação por SO

### Windows
```
Infra adiciona GPO (startup script)
  → install_unlock_web.bat executa no próximo login/boot
  → Download do binário via GitHub Releases
  → Instalação silenciosa com token JWT
  → [6] Validação automática dos processos
  → Log gravado em C:\temp\xone\install.log
```

### Linux
```
Infra acessa via ScreenConnect
  → Executa install-unlockusert.sh (sudo)
  → Instala dependências (dotnet, xdotool, xorg, jq)
  → Download do .deb via GitHub Releases
  → Instalação com token JWT via env
  → Configura extensão Chrome (policy local)
  → [6] Validação automática dos processos
  → Log gravado em /var/log/unlockusert_install.log
```

### macOS
```
Infra agenda janela com o usuário (e-mail)
  → Usuário confirma disponibilidade
  → Infra executa install-unlockusert.sh via ScreenConnect
  → Usuário aprova controles de privacidade (Acessibilidade / Full Disk Access)
    ⚠ Sem esse passo o agente instala mas não funciona
  → Infra confirma aprovação antes de encerrar a sessão
  → Validação dos processos
```

---

## 5. Validação pós-instalação

Após cada instalação, verificar:

| Check | Como | Critério |
|-------|------|----------|
| Processos do agente | Script automático (step 6/6) | 5+ processos ativos |
| Token gravado | Config file / log | AgentToken preenchido |
| Agente no console xOne | Console web | Status "online" em até 5 min |
| Extensão Chrome (Linux) | Policy em `/etc/opt/chrome/policies/managed/` | Arquivo presente |
| Aprovação privacidade (macOS) | Confirmar com usuário | Acessibilidade e FDA habilitados |

A instalação só é contabilizada como **concluída** quando todos os checks passam.

---

## 6. Governança e monitoramento contínuo

### Alerta de agente offline
- **Threshold:** 5 dias sem heartbeat → alerta para Infra revisar
- **Exceções (não alertar automaticamente):**
  - Colaborador em férias registradas no RH
  - Atestado médico ativo
  - Equipamento em manutenção documentada
- **Verificação:** exportar relatório do console xOne semanalmente; cruzar offline > 5 dias com exceções listadas

### Dashboard de cobertura
Métricas a acompanhar:

| Métrica | Fonte | Frequência |
|---------|-------|-----------|
| % parque instalado | Console xOne ÷ inventário-alvo | Semanal |
| % agentes online | Console xOne | Semanal |
| Tickets de instalação/falha | Jira SPN | Por wave |
| MTTR chamados unlock/reset | Jira SPN (antes vs depois) | Mensal |

### Atualização de versão
- Novo release → atualizar URL + hash SHA256 nos 3 scripts
- Testar em 1 máquina por SO antes de propagar via GPO/ScreenConnect
- Documentar versão ativa no README

### Renovação do token JWT
- Token tem validade — administradores da ferramenta geram novo token
- Processo: admin xOne gera → Infra atualiza nos scripts → redeployment nas próximas instalações
- **Atenção:** máquinas já instaladas usam o token gravado no config local, não o dos scripts

---

## 7. Impacto em Suporte

### Responsabilidades

| Atividade | Responsável |
|-----------|------------|
| Instalação (Windows via GPO) | Infra — automático |
| Instalação (Linux / macOS via ScreenConnect) | Infra |
| Agendamento de janela macOS | Infra → notifica usuário por e-mail |
| Dúvidas do colaborador pós-install | Suporte L1 (runbook disponível) |
| Falhas e reinstalações | Infra L2 |
| Desinstalação (offboarding) | Infra |

### Volume esperado de tickets por wave
- ~5–10% das instalações podem gerar ticket (dúvida, falha, mac sem aprovação)
- Wave 1 (~150 máquinas) → estimar 8–15 tickets de suporte

---

## 8. Comunicação

### Para o colaborador (antes da instalação)
Enviar e-mail com:
- O que será instalado e por quê
- O que ele vai ver acontecendo
- O que ele precisa fazer (especialmente macOS)
- Canal de suporte em caso de dúvida

### Para gestores (antes de cada wave)
- Aviso de quando a instalação acontece na área
- Expectativa de impacto (mínimo, se processar em horário fora do expediente)

---

## 9. Checklist por instalação

```
[ ] Colaborador consta no inventário-alvo
[ ] SO identificado
[ ] macOS: janela agendada com usuário
[ ] Script executado com sucesso (exit 0)
[ ] 5+ processos validados no log
[ ] Agente online no console xOne
[ ] macOS: aprovação de privacidade confirmada
[ ] Registro na planilha de controle da wave
```

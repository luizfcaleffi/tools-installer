# Serviço de Eficiência Digital — Arquitetura de Processos

**Versão:** 1.0 | **Data:** Abr 2026
**Ferramenta:** xOne Cloud (UnlockUserT)
**Parque-alvo:** ~800 seats | 3 SOs (Windows, Linux, macOS)

---

## Visão Geral

O Serviço de Eficiência Digital é composto por quatro domínios de processo que, juntos, garantem a operação sustentável da plataforma xOne — desde a entrega do agente nas máquinas até a governança dos dados gerados.

```
┌─────────────────────────────────────────────────────────────────┐
│                  SERVIÇO DE EFICIÊNCIA DIGITAL                  │
├───────────────┬───────────────┬───────────────┬─────────────────┤
│  1. APLICAÇÃO │  2. DADOS &   │  3. PESSOAS & │  4. GOVERNANÇA  │
│  & INFRA      │  PLATAFORMA   │  COMUNICAÇÃO  │  & COMPLIANCE   │
└───────────────┴───────────────┴───────────────┴─────────────────┘
```

---

## Domínio 1 — Aplicação & Infraestrutura

> **Dono:** Infra Estrutura
> **Impacto direto em Suporte e Infra:** ✅ Alto

### Processos

| Nº | Processo | Gatilho | Responsável | Suporte | Infra |
|----|----------|---------|-------------|:-------:|:-----:|
| 1.1 | Instalação dos aplicativos nas máquinas | Wave / onboarding | Infra | ✅ L1 pós-install | ✅ execução |
| 1.2 | Desinstalação dos aplicativos nas máquinas | Offboarding / inelegibilidade | Infra | — | ✅ execução |
| 1.3 | Atualização dos aplicativos nas máquinas | Novo release xOne | Infra | ✅ possível impacto | ✅ testes + rollout |
| 1.4 | Monitoramento dos aplicativos nas máquinas | Contínuo | Infra | ✅ alertas offline | ✅ investigação |

### Subprocessos de instalação por SO

| SO | Mecanismo | Ponto de atenção |
|----|-----------|-----------------|
| Windows | GPO startup script | Automático — log em `C:\temp\xone\install.log` |
| Linux | ScreenConnect + shell | Dependências apt, extensão Chrome, validação de processos |
| macOS | ScreenConnect + agendamento | **Requer aprovação do usuário** (Privacidade / Acessibilidade) |

### Critério de validação pós-instalação
Instalação considerada **concluída** apenas quando:
- 5+ processos do agente ativos (`HeartBeat`, `EventSender`, `LicenseManager`, `ProcessRunner`, `UpdateManager`)
- Agente aparece online no console xOne em até 5 minutos
- macOS: aprovação de privacidade confirmada com o usuário

---

## Domínio 2 — Dados & Plataforma

> **Dono:** People Analytics
> **Impacto direto em Suporte e Infra:** ⚠ Indireto (Infra é informada)

### Processos

| Nº | Processo | Descrição | Responsável | Infra |
|----|----------|-----------|-------------|:-----:|
| 2.1 | Desenvolvimento da API de Extração | Extração automática dos dados gerados pela plataforma via API | People Analytics | I |
| 2.2 | Desenvolvimento da API de Input de dados do colaborador | Alimentação de dados do colaborador na plataforma | People Analytics | — |
| 2.3 | Definição dos KPIs | Mapeamento dos KPIs de produtividade — não apenas plataforma, também dados internos | People Analytics | — |
| 2.4 | Classificação dos dados | Avaliação dos tipos de dado conforme LGPD (pessoal, sensível, anônimo) | People Analytics + SI | — |
| 2.5 | Desenvolvimento do Dashboard | Consolidação e visualização das métricas de eficiência | People Analytics | — |
| 2.6 | Cadastro das URLs Corporativas e Não Corporativas | Definir quais URLs são classificadas como corporativas | People Analytics | I |
| 2.7 | Cadastro dos Programas Corporativos e Não Corporativos | Definir classificação de aplicativos monitorados | People Analytics | I |
| 2.8 | Atualização das URLs e Programas | Manutenção contínua das listas de classificação | People Analytics | — |

---

## Domínio 3 — Pessoas & Comunicação

> **Dono:** People Analytics + HRBPs + Cultura & Colaboração
> **Impacto direto em Suporte e Infra:** ⚠ Indireto (alimenta o inventário-alvo)

### Processos

| Nº | Processo | Responsável | Observação |
|----|----------|-------------|-----------|
| 3.1 | Cadastro dos colaboradores na plataforma | People Analytics | Base do inventário-alvo |
| 3.2 | Monitoramento dos colaboradores | People Analytics | — |
| 3.3 | Inativação por desligamento | People Analytics | Gatilho para desinstalação (1.2) |
| 3.4 | Inativação por férias | People Analytics | Exceção ao alerta offline 5 dias |
| 3.5 | Cadastro e controle de permissões | People Analytics | Define quem acessa o quê |
| 3.6 | Cadastro de feriados e calendários | People Analytics | Contexto para análise de produtividade |
| 3.7 | Acompanhamento dos dados dos colaboradores | People Analytics | — |
| 3.8 | Garantir que as informações estejam corretas | People Analytics | Qualidade dos dados |
| 3.9 | Contrato de trabalho | HRBPs | Base legal do monitoramento |
| 3.10 | Cadastro das jornadas de trabalho | HRBPs | Contexto de horário para análise |
| 3.11 | Atualização das jornadas de trabalho | HRBPs | — |
| 3.12 | Comunicação aos colaboradores | Cultura & Colaboração | Infra é informada; essencial antes de cada wave |

---

## Domínio 4 — Governança & Compliance

> **Dono:** Segurança da Informação + Jurídico
> **Impacto direto em Suporte e Infra:** ⚠ Define regras que Infra deve seguir

### Processos

| Nº | Processo | Responsável | Observação |
|----|----------|-------------|-----------|
| 4.1 | Classificação dos dados coletados (LGPD) | SI (consultada) | Limita o que pode ser coletado/exibido |
| 4.2 | Gestão do token JWT | Admins xOne + Infra | Token com validade — processo de renovação definido |
| 4.3 | Alerta de agente offline > 5 dias | Infra | Exceções: férias e atestados registrados |
| 4.4 | Gestão de licenças (seats, expansão) | Infra + People Analytics | Trimestral ou por demanda |
| 4.5 | Revisão trimestral do serviço | Todos os donos | Ajuste de KPIs, processos e cobertura |

---

## Mapa de impacto — Suporte e Infra

### Time de Suporte (L1)
Afetado diretamente pelos processos do **Domínio 1**:

| Situação | Processo de origem | Ação Suporte |
|----------|--------------------|-------------|
| Usuário com dúvida pós-instalação | 1.1 | Orientar com runbook |
| Usuário Mac sem aprovação de privacidade | 1.1 | Escalar para Infra |
| Usuário relata lentidão após instalação | 1.1 / 1.3 | Triagem → escalar se persistente |
| Usuário não sabe o que é o xOne | 3.12 | Explicar e tranquilizar |
| Usuário com agente que parou de funcionar | 1.4 | Escalar para Infra com log |

### Time de Infra
Dono completo do Domínio 1. Impactado indiretamente pelos Domínios 2, 3 e 4:

| Gatilho externo | Domínio de origem | Ação Infra |
|----------------|-------------------|-----------|
| Novo colaborador elegível | 3.1 / 3.3 | Instalar agente (1.1) |
| Desligamento | 3.3 | Desinstalar agente (1.2) |
| Férias registradas | 3.4 | Marcar exceção no alerta offline |
| Nova classificação de URL/Programa | 2.6 / 2.7 | Informada — sem ação técnica |
| Novo release xOne | 1.3 | Testar + atualizar scripts + rollout |
| Token JWT próximo do vencimento | 4.2 | Solicitar renovação, atualizar scripts |
| API de extração publicada | 2.1 | Informada — pode apoiar integração |

---

## Fluxo de dependências entre domínios

```
HRBPs (3.9–3.11)          People Analytics (3.1–3.8)
Jornadas + Contratos   →   Cadastro + Monitoramento colaboradores
                                        ↓
                           Inativação por desligamento/férias
                                        ↓
                      Infra: instala / desinstala / marca exceção
                                        ↓
                       xOne coleta dados nas máquinas
                                        ↓
                       People Analytics: API extração (2.1)
                                        ↓
                       Dashboard de eficiência (2.5)
```

---

## RACI resumida

| Processo | People Analytics | Infra | Segurança da Info | Cultura & Collab | HRBPs | Gestores | Jurídico |
|----------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Instalação / Desinstalação / Atualização / Monitoramento | — | **R** | — | — | — | — | — |
| API de Extração | **R** | I | C | — | — | — | — |
| API de Input + KPIs + Classificação dados | **R** | — | C | — | — | — | — |
| Dashboard | **R** | — | — | — | — | — | — |
| Cadastro e monitoramento de colaboradores | **R** | — | — | — | I | — | — |
| Inativação (desligamento / férias) | **R** | I | — | — | — | — | — |
| URLs e Programas corporativos | **R** | I | — | — | — | — | — |
| Comunicação aos colaboradores | I | I | — | **R** | — | — | — |
| Contratos e jornadas de trabalho | — | — | — | — | **R** | — | — |
| Token JWT e licenças | — | **R** | — | — | — | — | — |
| Compliance LGPD | C | — | **R** | — | — | — | A |

---

## Apêndice — Processos Sugeridos (backlog)

> Não necessariamente serão implementados — listados como referência para evolução do serviço.

### 🔴 Alta relevância

| Processo | Domínio | Descrição |
|----------|---------|-----------|
| Gestão de exceções formais | 1 — Infra | Política explícita para equipamentos que não recebem o xOne: quiosques, máquinas compartilhadas, BYOD, restrição legal/médica |
| Reposição e troca de equipamento | 1 — Infra | Fluxo para reinstalação quando colaborador troca de máquina ou muda de SO (ex: Linux → Mac) |
| Retorno de licença prolongada | 1 — Infra | Processo de reativação para colaboradores que retornam de licença maternidade/afastamento — agente pode estar offline, desatualizado ou com token expirado |
| Rollback documentado | 1 — Infra | Critério e autorização para reverter para versão anterior do agente em caso de atualização problemática |

### 🟡 Relevância média

| Processo | Domínio | Descrição |
|----------|---------|-----------|
| Gestão de acesso ao console xOne | 4 — Governança | Formalizar quem tem acesso de admin vs leitura; revisão periódica para remover acessos de desligados |
| Integração com AD / sistema de RH | 2 — Dados | Automatizar cadastro/inativação no xOne a partir de eventos de admissão e desligamento no RH |
| Gestão do fornecedor (xOne Cloud) | 4 — Governança | Cadência de reuniões, SLA contratual (disponibilidade, suporte), acompanhamento de roadmap |
| Treinamento e capacitação | 3 — Pessoas | Onboarding de novos membros de Infra nos scripts; revisão periódica do runbook L1; treinamento de gestores no dashboard |

### 🟢 Governança avançada

| Processo | Domínio | Descrição |
|----------|---------|-----------|
| Contestação de dados pelo colaborador (LGPD) | 4 — Governança | Fluxo para o titular solicitar acesso, correção ou exclusão dos próprios dados coletados |
| Auditoria periódica do serviço | 4 — Governança | Verificar se o que está sendo coletado condiz com a classificação aprovada; revisar URLs e programas corporativos (sugerido: semestral) |
| Relatório executivo (C-level) | 2 — Dados | Formato de apresentação para liderança: ROI, redução de chamados, cobertura de parque |
| Avaliação de novas funcionalidades | 4 — Governança | Processo para avaliar e aprovar ativação de features novas do xOne antes de impactar os usuários |

# Runbook — xOne Agent | Suporte L1

## O que é o xOne

O xOne (UnlockUserT) é uma ferramenta corporativa de gestão de identidade instalada nas estações de trabalho da MadeiraMadeira. Permite que colaboradores realizem operações como desbloqueio de conta e reset de senha de forma autônoma, sem precisar acionar o Suporte.

A instalação é feita pela equipe de Infraestrutura — o colaborador não instala por conta própria.

---

## Processos normais do agente

Após a instalação, o xOne roda de 6 a 7 processos em segundo plano. Isso é **esperado e normal**:

| Processo | Função |
|----------|--------|
| XOne Agent HeartBeat | Mantém conexão ativa com o servidor (sinal de vida) |
| XOne Agent EventSender | Envia eventos e ações para a nuvem |
| XOne Agent LicenseManager | Gerencia a licença corporativa |
| XOne Agent ProcessRunner | Executa ações sob demanda do servidor |
| XOne Agent UpdateManager | Verifica e aplica atualizações automáticas |
| XOne Agent UserActivityCollector | Coleta atividade do usuário logado (quando há sessão ativa) |
| XOne Agent HardwareCollector | Coleta informações de hardware (apenas Windows) |

---

## Situações comuns e o que fazer

### "Apareceu um processo estranho / pode ser vírus?"
- Tranquilizar o colaborador: processos com o nome "XOne Agent" são legítimos, instalados pela TI
- Confirmar que o nome começa exatamente com **"XOne Agent"**
- Não escalar — apenas orientar

### "O computador ficou lento depois da instalação"
1. Perguntar se a lentidão é constante ou aconteceu só logo após a instalação
2. Se for constante: pedir print do gerenciador de tarefas mostrando CPU/memória dos processos xOne
3. Se CPU > 10% constante por mais de 15 minutos → abrir ticket para Infra com o print
4. Se for passageiro (primeiros minutos) → orientar que é comportamento normal na inicialização

### "Apareceu uma janela pedindo permissão (macOS)"
- Isso é **obrigatório no macOS** — sem aprovação, o agente não funciona
- Instruir: Configurações do Sistema → Privacidade e Segurança → Acessibilidade → habilitar xOne
- Se o usuário não souber fazer sozinho → agendar atendimento presencial/remoto com Infra
- **Não fechar a janela sem aprovar** — se fechou, Infra precisa ser acionada

### "Recebi um e-mail da TI sobre o xOne / comunicado de instalação"
- Confirmar que é comunicação legítima (remetente `@madeiramadeira.com.br`, não links externos suspeitos)
- Orientar que faz parte do projeto corporativo de EUC
- Dúvidas técnicas → ticket para Infra

### "O xOne não funciona / não consigo usar"
1. Confirmar o SO (Windows / Linux / macOS)
2. Pedir print dos processos em execução (Gerenciador de Tarefas / Activity Monitor / `ps aux`)
3. Verificar se há processos com nome "XOne Agent" rodando
4. Com ou sem processos → abrir ticket para Infra com os dados abaixo

---

## Quando escalar para Infra (SPN)

| Situação | Prioridade sugerida |
|----------|-------------------|
| Processos do agente ausentes após instalação | Alta |
| Falha na instalação reportada pelo usuário | Alta |
| macOS: usuário não consegue aprovar privacidade | Alta |
| Consumo anormal de CPU/memória persistente | Média |
| Agente instalado mas ferramenta não responde | Média |
| Dúvida sobre o xOne (sem problema técnico) | Baixa |

---

## Template de ticket para escalonamento

```
Tipo: xOne Agent — [Falha na instalação / Processo ausente / Outro]
Usuário: [nome completo]
E-mail corporativo: [email@madeiramadeira.com.br]
SO: [Windows / Linux / macOS — versão se souber]
Descrição: [o que o usuário relatou]
Processos xOne rodando: [Sim / Não / Parcial]
Anexo: [print do gerenciador de tarefas]
```

---

## Contato Infra

Tickets via Jira — fila **SPN**

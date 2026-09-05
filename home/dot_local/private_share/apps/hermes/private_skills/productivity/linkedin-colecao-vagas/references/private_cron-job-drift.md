# Cron Job Drift de Configuração — Diagnóstico e Solução

## Problema

Cron jobs criados com provider/model antigos podem falhar quando o ambiente muda. O sistema Hermes bloqueia execução para evitar gasto não intencional.

### Sintoma

```
RuntimeError: Skipped to prevent unintended spend: global inference config drifted 
since this job was created (provider 'custom' -> 'nous'; model 'omniroute/agents' -> 
'upstage/solar-pro4:free'), and this job is unpinned. No inference call was made. 
To run on the new config, pin it explicitly: `cronjob action=update job_id=<ID> 
provider=<provider> model=<model>` (or pin the original values to keep them). 
See #44585.
```

### Causa Raiz

1. O cron job foi criado com `provider=custom` e `model=omniroute/agents`
2. O ambiente evoluiu: provider mudou para `nous`, model para `upstage/solar-pro4:free`
3. O cron job está " Unpinned" (não tem provider/model fixos)
4. O sistema detecta o drift e bloqueia a execução para prevenir gasto

## Solução A — Recriar o Cron Job (Recomendado)

```bash
# 1. Remover o cron job com drift
cronjob action=remove job_id=<JOB_ID>

# 2. Criar novo com provider/model atuais
cronjob action=create \
  --name "Nome do Job" \
  --prompt "<prompt completo>" \
  --schedule "0 16 * * *" \
  --deliver "telegram:644615401:14880" \
  --skills "job-process"
```

**Vantagem:** garante que o novo cron job foi criado com os valores corretos do ambiente atual.

## Solução B — Tentar Update de Provider/Model

```bash
cronjob action=update \
  job_id=<JOB_ID> \
  provider=nous \
  model=upstage/solar-pro4:free
```

**Limitação:** pode retornar "No updates provided" se o sistema considerar que provider/model já estão corretos. Nesse caso, usar Solução A.

## Prevenção

### Testar cron job imediatamente após criação

Sempre executar `cronjob action=run job_id=<JOB_ID>` logo após criar um novo cron job para confirmar que o provider/model estão alinhados e a execução funciona antes de confiar na execução automática futura.

### Verificar provider/model antes de criar

```bash
# Verificar ambiente atual
# (consulta implícita: qual provider/model o sistema está usando atualmente?)
# Criar cron job com valores que sabemos serem válidos
```

## Relação com Outros Problemas

- **Token truncado:** erro separado, ocorre quando o NOTION_API_KEY está truncado no .env. Solução: garantir que o .env está completo e o token está correto.
- **Camofox offline:** erro de conexão do browser, não relacionado ao cron drift. Causa: Camofox não está rodando no VPS.

## Histórico desta Sessão

Na sessão de 2026-09-01, o cron job `8e3afc5b8543` (Monitoramento de Mensagens LinkedIn) apresentou drift:

- Criado com: `provider=custom`, `model=omniroute/agents`
- Ambiente atual: `provider=nous`, `model=upstage/solar-pro4:free`
- Erro: "Skipped to prevent unintended spend"
- Solução aplicada: removeu-se o cron antigo e criou-se novo com `job_id=7e36833b059e`
- Resultado: novo cron job criado e executado com sucesso

## Referências

- `colecao-workflow-passos.md` — workflow completo de coleta
- `SKILL.md` — skill principal

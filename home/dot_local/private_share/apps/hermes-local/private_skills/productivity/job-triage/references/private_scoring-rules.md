# Regras Detalhadas de Scoring

## Critérios e Pesos

| Critério | Peso | Max Pts | Como Calcular |
|----------|------|---------|---------------|
| **Stack Match** | 30% | 30 | Node.js/NestJS = 10, Java/Spring Boot = 10, Python/Django = 10. Se tem ≥2 = 30, se tem 1 = 15 |
| **Contrato/Remoto** | 25% | 25 | PJ + 100% remoto = 25, PJ + híbrido Londrina = 20, CLT remoto = 10, outro = 0 |
| **Senioridade** | 20% | 20 | Tech Lead/Lead = 20, Arquiteto/Architect = 18, Sênior/Senior = 15, Pleno = 5, Júnior = 0 |
| **Fintech/Pagamentos** | 15% | 15 | Menção a pagamentos/gateway/PCI-DSS/fintech = 15, banco/financeiro = 10, outro = 0 |
| **IA/LLMs** | 10% | 10 | LLMs/Generative AI/Langfuse/agentes = 10, ML/AI genérico = 5, sem menção = 0 |

## Regras de Negócio

1. **Hard Requirements** (se faltar, score = 0):
   - Não ser CLT presencial fora de Londrina
   - Não ser júnior/pleno sem menção de liderança

2. **Boosts** (adicionais ao score base):
   - Empresa conhecida/grande = +5
   - Salário/range público compatível = +5
   - Recrutador direto (não hunting) = +3

3. **Penalties**:
   - Stack completamente diferente (ex: PHP, C#, mobile only) = -20
   - Híbrido obrigatório fora de Londrina = -30
   - Inglês fluente obrigatório (perfil tem intermediário) = -10

## Thresholds Finais

| Score | Ação | Etapa Atual (Notion) | Status Geral |
|-------|------|---------------------|--------------|
| 85-100 | Auto-aplicar urgente | Candidatura enviada | Enviado |
| 70-84 | Auto-aplicar | Preparar candidatura | Pra enviar |
| 50-69 | Notion + Telegram (perguntar) | Aguardando análise | Aguardando retorno |
| 30-49 | Arquivar log | Não aderente | Não aderente |
| 0-29 | Ignorar silenciosamente | - | - |

## Implementação no Código

```python
SCORING_CONFIG = {
    "weights": {
        "stack_match": 0.30,
        "contract_remote": 0.25,
        "seniority": 0.20,
        "fintech": 0.15,
        "ai_llm": 0.10
    },
    "thresholds": {
        "auto_apply": 70,
        "ask_user": 50,
        "archive": 30
    },
    "hard_requirements": {
        "no_onsite_clt_outside_londrina": True,
        "no_junior_without_leadership": True
    }
}
```
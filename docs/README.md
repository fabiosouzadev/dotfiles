# Documentação

Documentação técnica do repositório de dotfiles. Para instalação rápida, perfis e visão geral, veja o [README principal](../README.md).

| Documento | Conteúdo |
|-----------|----------|
| [Arquitetura](arquitetura.md) | Camadas, fluxo do `chezmoi apply`, abstrações principais, tratamento de erros |
| [Estrutura](estrutura.md) | Mapa de diretórios, onde fica cada coisa, onde adicionar algo novo |
| [Stack e integrações](stack-e-integracoes.md) | Linguagens, ferramentas, serviços da VPS e integrações externas |
| [Convenções e testes](convencoes-e-testes.md) | Padrões de nomes, estilo dos scripts, estado atual de validação e testes |
| [Pontos de atenção](pontos-de-atencao.md) | Dívida técnica, bugs conhecidos, riscos de segurança e lacunas, por prioridade |

> O diretório `docs/` fica na raiz do repositório, fora de `home/` (o source state definido em `.chezmoiroot`), então não é aplicado no `$HOME`.

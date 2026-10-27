# Contribuindo para este fork

Este é o fork do Chatwoot mantido pela [Sancar](https://sancar.space).

## Fluxo de trabalho

1. **Abra uma issue** descrevendo o que você quer mudar ou corrigir
2. **Crie um branch** a partir de `develop`: `git checkout -b feat/minha-mudanca develop`
3. **Faça suas alterações** seguindo as convenções do projeto
4. **Abra um Pull Request** para `develop` com uma descrição clara

## Convenções

- Mensagens de commit em inglês seguindo Conventional Commits: `feat(scope): descrição`
- Código Ruby: siga as regras do RuboCop (`bundle exec rubocop -a`)
- Código Vue/JS: siga o ESLint (`pnpm eslint:fix`)
- Não edite arquivos de tradução além de `en.yml` e `en.json` — outros idiomas são sincronizados via Crowdin

## Sincronizando com o upstream

Para trazer atualizações do Chatwoot upstream:

```bash
git remote add upstream https://github.com/chatwoot/chatwoot
git fetch upstream
git merge upstream/develop
```

Resolva conflitos preservando as customizações Sancar (especialmente em `deploy/` e variáveis de ambiente Baileys).

## Contribuindo com os templates n8n

Os workflows n8n ficam no repositório dedicado: [sancar-space/n8n-automatizando-chatwoot](https://github.com/sancar-space/n8n-automatizando-chatwoot)

## Documentação do upstream

Para contribuições no core do Chatwoot (não específicas da Sancar), consulte também o [guia de contribuição oficial](https://www.chatwoot.com/docs/contributing-guide).

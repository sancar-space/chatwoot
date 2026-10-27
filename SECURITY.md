# Política de Segurança

A Sancar valoriza o trabalho de pesquisadores de segurança que ajudam a manter este projeto e seus usuários seguros. Se você encontrou uma vulnerabilidade, queremos saber.

## Reportando uma Vulnerabilidade

Utilizamos o GitHub para rastrear problemas de segurança neste projeto.

Se você acredita ter encontrado uma vulnerabilidade, por favor divulgue de forma responsável via:

**[GitHub Security Advisories](https://github.com/sancar-space/chatwoot/security/advisories/new)**

Isso nos permitirá revisar a vulnerabilidade, corrigi-la rapidamente e reconhecer sua contribuição.

Para dúvidas sobre o processo (não para divulgação de vulnerabilidades): **contato@sancar.space**

> **Importante:** Não abra issues públicas no GitHub nem publique em redes sociais antes de entrar em contato conosco. A divulgação responsável protege todos os usuários.

## Versões Suportadas

| Versão | Suportada |
|--------|----------|
| latest | ✅ |
| versões anteriores | ❌ |

## Vulnerabilidades que Analisamos

> Não realize testes contra instâncias em produção. Use uma **instância própria** para testes.

- Execução remota de comandos (RCE)
- Injeção de SQL
- Bypass de autenticação
- Escalação de privilégios
- Cross-site scripting (XSS)
- Ações administrativas sem autorização
- CSRF

## Fora de Escopo

Os itens abaixo geralmente não são considerados vulnerabilidades reportáveis:

- Headers de segurança HTTP ausentes
- SPF/DKIM incompleto ou ausente
- Relatórios de ferramentas automatizadas sem exploração comprovada
- Ataques teóricos sem prova de exploração
- Engenharia social
- Ataques de negação de serviço (DoS)
- Ataques de força bruta
- Algoritmos SSL/TLS fracos
- Ataques que requerem acesso físico ao dispositivo

Em caso de dúvida sobre o escopo, abra um [Security Advisory](https://github.com/sancar-space/chatwoot/security/advisories/new).

---

Obrigado por ajudar a manter este projeto seguro.

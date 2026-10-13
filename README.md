# Provisionamento automatizado de Windows

Solução automatizada de provisionamento de equipamentos Windows utilizando **Autounattend.xml** e **scripts .bat**. O processo automatizava a instalação do sistema operacional e dos aplicativos corporativos a partir de arquivos locais, padronizando a configuração dos equipamentos e reduzindo o tempo de preparação com mínima intervenção manual.

Projeto desenvolvido por iniciativa própria durante meu estágio na Zallpy Digital.

## Como funciona

1. O instalador do Windows lê o `Autounattend.xml` e faz a instalação sem perguntas (idioma, disco, conta e configurações iniciais).
2. No primeiro login, os scripts `.bat` são executados automaticamente.
3. Os scripts instalam os aplicativos corporativos a partir de arquivos locais, em modo silencioso.
4. A máquina fica padronizada e pronta para envio.

## Estrutura

```
Autounattend.xml      respostas da instalação do Windows
scripts/              scripts .bat de instalação dos aplicativos
```

## Tecnologias

Windows · Autounattend.xml · Batch Script · Automação

## Observação

Chaves de produto, senhas, instaladores e nomes internos da empresa foram removidos. Este repositório mostra a estrutura e a lógica da solução.

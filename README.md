# Automação Windows 11

Provisionamento automatizado de equipamentos Windows com **Autounattend.xml** e **scripts .bat**. Um pendrive instala o Windows 11 Pro em português e os aplicativos corporativos a partir de arquivos locais, deixando a máquina padronizada e pronta para envio, com mínima intervenção manual.

Baseado em um projeto que desenvolvi por iniciativa própria no meu estágio de infraestrutura na Zallpy Digital. Esta é uma versão reconstruída para portfólio, sem nenhum dado interno da empresa. Como exemplo, ela instala o navegador Brave.

## Como funciona

1. **Instalação do Windows sem perguntas:** o instalador lê o `Autounattend.xml` e define idioma, teclado ABNT2, fuso horário, particionamento do disco e edição (Windows 11 Pro).
2. **Cópia dos arquivos:** durante a instalação, os scripts e os instaladores são copiados do pendrive para `C:\Windows\Setup\Scripts`.
3. **Instalação dos aplicativos:** no fim da instalação, o Windows executa o `SetupComplete.cmd` como SYSTEM, que roda cada script da pasta `apps` e grava um log.
4. **Conta do usuário:** na tela inicial, quem prepara a máquina cria a conta e a senha. Os instaladores copiados são apagados para liberar espaço.

## Estrutura

```
Autounattend.xml            respostas da instalação do Windows
scripts/
  SetupComplete.cmd         executado pelo Windows no fim da instalação
  instalar-apps.bat         roda todos os apps\instalar-*.bat e conta as falhas
  apps/
    instalar-brave.bat      instala o Brave para todos os usuários, sem perguntas
instaladores/               instaladores offline (não vão para o GitHub)
```

Para adicionar um programa, basta criar um novo `scripts\apps\instalar-<programa>.bat` e colocar o instalador na pasta `instaladores`.

## Segurança: nenhuma senha no pendrive

Um pendrive de instalação pode ser perdido ou copiado, então ele **não guarda credenciais**:

- **Sem usuário e senha de administrador no `Autounattend.xml`.** A conta é criada na hora, na tela inicial.
- **Por que não "esconder" a senha?** O `Autounattend.xml` só aceita a senha em texto puro ou codificada em Base64, que qualquer pessoa reverte em segundos. Não existe opção de hash, porque o Windows precisa da senha original para criar a conta. E, no Windows, até o hash da senha é sensível: ele pode ser usado diretamente em ataques do tipo *pass-the-hash*.
- **Sem chave de ativação.** O arquivo usa apenas a chave genérica pública da Microsoft, que escolhe a edição mas não ativa o Windows. A ativação vem da licença gravada na placa-mãe ou do licenciamento da empresa.
- **Em produção**, a senha do administrador local deve ser gerenciada pelo **Windows LAPS** (senha única por máquina, guardada no Active Directory ou no Entra ID e trocada automaticamente).

## Como usar

1. Crie um pendrive de instalação do Windows 11 (pela Ferramenta de Criação de Mídia da Microsoft, por exemplo).
2. Copie para a **raiz** do pendrive o `Autounattend.xml`, a pasta `scripts` e a pasta `instaladores`.
3. Baixe o instalador offline do Brave (`BraveBrowserStandaloneSilentSetup.exe`, no GitHub oficial do Brave) e coloque na pasta `instaladores`.
4. Inicie a máquina pelo pendrive.

> **Atenção:** o `Autounattend.xml` **apaga todo o disco 0** da máquina. Teste antes numa máquina virtual (Hyper-V ou VirtualBox).

O log da instalação dos aplicativos fica em `C:\Windows\Temp\provisionamento.log`.

## Limitações conhecidas

- O Windows não executa o `SetupComplete.cmd` quando a instalação usa uma chave de produto OEM. Nesse caso, rode `scripts\instalar-apps.bat` manualmente como administrador.
- Os scripts esperam instaladores offline com modo silencioso. Cada programa novo precisa ser testado.

## Tecnologias

Windows 11 · Autounattend.xml · Batch Script · Automação

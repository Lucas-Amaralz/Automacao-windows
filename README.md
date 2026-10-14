# Automação Windows 11

Provisionamento automatizado de equipamentos Windows com **Autounattend.xml**, **PowerShell** e **scripts .bat**. Um pendrive instala o Windows 11 Pro em português, deixa o sistema enxuto para uso corporativo (pensado para máquinas fracas) e entrega na área de trabalho uma pasta que instala os aplicativos da empresa com dois cliques.

Baseado em um projeto que desenvolvi por iniciativa própria no meu estágio de infraestrutura na Zallpy Digital. Esta é uma versão reconstruída para portfólio, sem nenhum dado interno da empresa. Como exemplo, ela instala o navegador Brave.

## Como funciona

1. **Instalação do Windows sem perguntas:** o instalador lê o `Autounattend.xml` e define idioma, teclado ABNT2, fuso horário, particionamento do disco e edição (Windows 11 Pro).
2. **Pasta na área de trabalho:** durante a instalação, a pasta `instalacao` do pendrive é copiada para a área de trabalho de todos os usuários.
3. **Windows enxuto:** ainda durante a instalação, antes de existir qualquer usuário, o `otimizar-windows.ps1` remove os apps e recursos inúteis para o trabalho (veja abaixo).
4. **Direto para a área de trabalho:** as telas da configuração inicial são puladas e o Windows entra sozinho, uma única vez, numa conta temporária **"Tecnico"**. Um aviso explica os próximos passos.
5. **Aplicativos com dois cliques:** o técnico abre a pasta **Instalacao** e dá dois cliques em **`INSTALAR.bat`**. Ele pede permissão de administrador sozinho, instala os programas sem perguntas e mostra o resultado na tela.
6. **Conta definitiva:** o técnico cria a conta de administrador definitiva e apaga a conta temporária.

## Estrutura

```
Autounattend.xml                respostas da instalação do Windows
instalacao/                     vai para a área de trabalho da máquina
  INSTALAR.bat                  dois cliques: instala todos os programas da pasta apps
  otimizar-windows.ps1          deixa o Windows enxuto (roda sozinho durante a instalação)
  apps/
    instalar-brave.bat          instala o Brave para todos os usuários, sem perguntas
  instaladores/                 instaladores offline (não vão para o GitHub)
```

Para adicionar um programa, basta criar um novo `instalacao\apps\instalar-<programa>.bat` e colocar o instalador na pasta `instaladores`.

## Windows enxuto para uso corporativo

Pensado para máquinas fracas: só fica o que serve para trabalhar.

**Removido:**
- **Jogos e Xbox:** Solitaire, Xbox, Game Bar e gravação de jogos em segundo plano.
- **Apps de consumidor:** Notícias, Clima, Mapas, Clipchamp, Vincular ao Celular, Pessoas, Dicas, Hub de Comentários, Obter Ajuda, Mail e Calendário antigos, Teams pessoal, Dev Home, Copilot, Cortana, o atalho "Microsoft 365 (Office)" e o "Novo Outlook".
- **Propaganda e sugestões:** apps que se instalam sozinhos, sugestões no Iniciar, dicas, ID de anúncios e Widgets.
- **Recursos pesados:** transparência, animações, hibernação (libera no disco o tamanho da RAM), Recall e o Edge rodando em segundo plano.
- **Barra de tarefas:** sem Widgets e Visão de Tarefas, pesquisa como ícone e sem sugestões da Bing.

**Mantido (útil no trabalho):** Edge, Loja, OneDrive, Assistência Rápida (suporte remoto), Calculadora, Bloco de Notas, Paint, Fotos, Ferramenta de Captura, Notas Autoadesivas, To Do, Terminal e Media Player.

**Também:** extensões de arquivo visíveis (ajuda o usuário a perceber golpes como `fatura.pdf.exe`), telemetria no mínimo permitido no Windows Pro e atualizações compartilhadas só pela rede local.

## Segurança: nenhuma senha no pendrive

Um pendrive de instalação pode ser perdido ou copiado, então ele **não guarda credenciais**:

- **Nenhuma senha no `Autounattend.xml`.** Para a instalação ir direto até a área de trabalho, o arquivo cria uma conta temporária **"Tecnico" sem senha**, com login automático uma única vez. Logo no primeiro login, ela passa a **exigir uma senha nova** (`net user Tecnico /logonpasswordchg:yes`), então não fica aberta depois. O técnico cria a conta de administrador definitiva e apaga a temporária.
- **Por que não "esconder" a senha?** O `Autounattend.xml` só aceita a senha em texto puro ou codificada em Base64, que qualquer pessoa reverte em segundos. Não existe opção de hash, porque o Windows precisa da senha original para criar a conta. E, no Windows, até o hash da senha é sensível: ele pode ser usado diretamente em ataques do tipo *pass-the-hash*.
- **Sem chave de ativação.** O arquivo usa apenas a chave genérica pública da Microsoft, que escolhe a edição mas não ativa o Windows. A ativação vem da licença gravada na placa-mãe ou do licenciamento da empresa.
- **Em produção**, a senha do administrador local deve ser gerenciada pelo **Windows LAPS** (senha única por máquina, guardada no Active Directory ou no Entra ID e trocada automaticamente).

## Como usar

1. **Crie o pendrive de instalação do Windows 11** normalmente, com a Ferramenta de Criação de Mídia da Microsoft ou com o Rufus.
   - No **Rufus**, quando aparecer a janela de personalização do Windows (remover requisitos, criar conta local etc.), **desmarque todas as opções**. Elas fazem o Rufus gerar um `Autounattend.xml` próprio, que entra em conflito com este.
2. **Baixe o instalador offline do Brave** (`BraveBrowserStandaloneSilentSetup.exe`, no GitHub oficial do Brave) e coloque dentro de `instalacao\instaladores`.
3. **Copie para a raiz do pendrive**, ao lado dos arquivos do Windows, o `Autounattend.xml` e a pasta `instalacao`. Não coloque nada dentro das pastas do instalador do Windows:

   ```
   PENDRIVE (E:)
   ├── boot\                (do instalador do Windows, não mexer)
   ├── efi\                 (do instalador do Windows, não mexer)
   ├── sources\             (do instalador do Windows, não mexer)
   ├── setup.exe            (do instalador do Windows, não mexer)
   ├── Autounattend.xml     <- deste projeto, obrigatoriamente na raiz
   └── instalacao\          <- deste projeto
   ```

   O instalador do Windows procura o `Autounattend.xml` sozinho na raiz do pendrive, e a cópia procura a pasta `instalacao` na raiz de qualquer unidade.
4. **Inicie a máquina pelo pendrive** (menu de boot da placa-mãe) e espere chegar na área de trabalho.
5. **Abra a pasta Instalacao** na área de trabalho e dê dois cliques em **`INSTALAR.bat`**.

> **Atenção:** o `Autounattend.xml` **apaga todo o disco 0** da máquina. Teste antes numa máquina virtual (Hyper-V ou VirtualBox).

Logs: `C:\Windows\Temp\otimizacao.log` (otimização) e `instalacao.log` dentro da pasta Instalacao (programas).

## Tecnologias

Windows 11 · Autounattend.xml · PowerShell · Batch Script · Automação

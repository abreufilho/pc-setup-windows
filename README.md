# PC Setup Windows 11

Setup pessoal, idempotente e auditável para preparar uma instalação limpa do
Windows 11 depois de uma restauração pela nuvem.

O projeto instala os programas escolhidos, configura WSL 2, remove o OneDrive,
executa uma limpeza agressiva de aplicativos de consumo e deixa o OpenSSH ativo
somente para a rede local. O alvo é uma máquina recém-formatada, não um Windows
em uso com dados e preferências acumuladas.

## Início rápido após a formatação

Conclua primeiro a configuração inicial do Windows, conecte-se à internet e abra
o **Windows PowerShell**. Execute:

```powershell
$p = "$env:TEMP\pc-setup-bootstrap.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/abreufilho/pc-setup-windows/main/bootstrap.ps1" -OutFile $p
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $p
```

O bootstrap baixa uma cópia nova em `C:\Users\<usuario>\pc-setup-windows` e abre
`setup.bat`. O launcher solicita elevação pelo UAC sem alterar permanentemente a
política de execução do PowerShell.

Também é possível baixar o ZIP pelo GitHub, extrair e dar duplo clique em
`setup.bat`.

## Configuração recomendada

No menu, escolha **Executar configuração recomendada**. A ordem é:

1. Instalar e iniciar o OpenSSH Server.
2. Restringir a porta 22 à sub-rede local e instalar a chave pública configurada.
3. Criar um ponto de restauração, quando o Windows permitir.
4. Desativar e desinstalar o OneDrive, preservando eventuais arquivos locais.
5. Remover apps de consumo e seu provisionamento para todos os usuários.
6. Instalar programas pelo WinGet.
7. Instalar ou atualizar WSL 2 com Ubuntu.
8. Aplicar tema, desempenho conservador, privacidade e barra de tarefas.
9. Configurar o avatar do usuário.

Para executar o preset sem abrir o menu:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1 -Preset Recommended
```

O preset pode ser executado novamente. Programas já presentes são ignorados,
valores de registro são reaplicados e regras existentes são atualizadas.

## Acesso SSH

A chave pública dedicada está em `config/setup.psd1`. A chave privada permanece
somente na máquina controladora em:

```text
~/.ssh/pc_setup_windows
```

Depois que a etapa SSH mostrar o IPv4 e o fingerprint do servidor, conecte-se da
máquina controladora com:

```bash
ssh -i ~/.ssh/pc_setup_windows USUARIO_DO_WINDOWS@IP_DO_WINDOWS
```

A regra criada aceita conexões na porta 22 apenas de `LocalSubnet`. O script
desativa a regra ampla criada automaticamente pelo Windows, valida o
`sshd_config`, restringe o arquivo de chaves aos SIDs de Administradores e SYSTEM
e testa a porta local antes de reportar sucesso. Não exponha a porta 22 no
roteador.

## OneDrive

`scripts/remove-onedrive.ps1`:

- bloqueia a sincronização por política local;
- remove a inicialização automática;
- encerra o processo;
- tenta desinstalar pelo WinGet e usa o instalador do Windows como fallback;
- nunca apaga `C:\Users\<usuario>\OneDrive`.

Se essa pasta existir, o script apenas emite um aviso para que os arquivos possam
ser revisados manualmente.

## Programas

Os pacotes ficam declarados em `config/setup.psd1`, separados em `Core`,
`Development` e `Personal`:

- Git, Visual Studio Code, KeePassXC e Google Chrome;
- Docker Desktop e DBeaver;
- Obsidian, Google Drive, Discord e WhatsApp.

É possível instalar somente um grupo:

```powershell
.\scripts\install-programs.ps1 -Group Core
.\scripts\install-programs.ps1 -Group Development
.\scripts\install-programs.ps1 -Group Personal
```

O instalador usa identificador exato, fonte explícita, aceitação dos contratos e
validação de código de saída do WinGet.

## WSL 2

O script usa o fluxo atual `wsl --install`, instala Ubuntu sem abri-lo durante o
setup e não reinicia o computador sozinho. Quando solicitado:

1. termine as demais etapas;
2. reinicie o Windows;
3. abra Ubuntu e crie o usuário Linux;
4. abra Docker Desktop.

Documentação oficial: [instalar WSL](https://learn.microsoft.com/windows/wsl/install).

## Limpeza pós-formatação

A limpeza agressiva faz parte do preset e não pede confirmação porque essa é a
finalidade explícita do repositório. Ela remove, para contas existentes e futuras,
itens como Clipchamp, Outlook, Teams, Copilot, Bing, Phone Link, Xbox, Dev Home,
Power Automate, apps de comunicação e outros pacotes listados em
`config/setup.psd1`.

Continuam protegidos Windows Security, Store, App Installer/WinGet, Start,
Calculator, Notepad, Photos, Paint, Snipping Tool e Camera, além de Defender,
Windows Update, Edge WebView, pesquisa e serviços essenciais. Essa fronteira evita
transformar “debloat” em quebra do sistema.

Os antigos tweaks globais de paginação, cache, rede e serviços foram removidos.
O plano de energia padrão é `Balanced`; a preferência pode ser alterada em
`config/setup.psd1`.

## Estrutura

```text
.
├── bootstrap.ps1               # baixa e abre uma cópia nova do setup
├── setup.bat                   # launcher elevado para duplo clique
├── setup.ps1                   # menu e orquestração
├── config/
│   └── setup.psd1              # preferências e pacotes
├── scripts/
│   ├── lib/Setup.Common.psm1   # validação, registro e comandos nativos
│   └── *.ps1                   # uma responsabilidade por script
└── tests/
    └── Invoke-StaticAnalysis.ps1
```

Cada execução grava um transcript em `logs/`; essa pasta não é versionada.

## QA local

Execute no Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Invoke-StaticAnalysis.ps1
```

O QA valida sintaxe, configuração, scripts referenciados, IDs duplicados e a
reintrodução de alterações destrutivas conhecidas. O projeto não usa GitHub
Actions; a validação é intencionalmente local e manual.

## Requisitos e segurança

- Windows 11 com Windows PowerShell 5.1.
- Internet para WinGet, WSL, avatar e OpenSSH.
- Conta com permissão de administrador.
- Reinicialização depois do WSL quando indicada.

O OpenSSH é instalado pelo recurso opcional oficial do Windows e configurado como
serviço automático. Consulte a [documentação oficial do OpenSSH para
Windows](https://learn.microsoft.com/windows-server/administration/openssh/openssh_install_firstuse).

## Referências de engenharia

O projeto [ChrisTitusTech/winutil](https://github.com/ChrisTitusTech/winutil)
serviu como referência para ponto de restauração, ACL por SID e validação do
fluxo SSH. O código deste repositório permanece independente e deliberadamente
não incorpora bypasses de instalação, desativação de serviços essenciais ou
limpeza de dados residuais do OneDrive oferecidos pelo WinUtil.

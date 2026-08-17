# Scripts de Configuração do Windows 11

Uma coleção de scripts PowerShell para automatizar a configuração e personalização do Windows 11.

Repositório no GitHub: [pc-setup-windows](https://github.com/abreufilho/pc-setup-windows)

---

## Objetivo

Esses scripts ajudam a configurar rapidamente uma nova instalação do Windows 11, economizando tempo e garantindo configurações consistentes. Siga as instruções deste README para preparar seu sistema.

---

## Pré-requisitos

Antes de começar, certifique-se de que você possui:

1. Uma instalação nova do Windows 11.
2. PowerShell 5.1 ou superior (pré-instalado no Windows 11).
3. Privilégios de administrador para executar os scripts.

---

## Início Rápido

1. Acesse o repositório no GitHub após a instalação do Windows 11:
   [pc-setup-windows](https://github.com/abreufilho/pc-setup-windows)
2. Clone ou baixe o repositório:
   - **Clonar**: Use o comando `git clone https://github.com/abreufilho/pc-setup-windows` (requer Git).
   - **Baixar**: Clique em **Code** → **Download ZIP**.
3. Extraia o arquivo ZIP baixado (se aplicável).
4. Dê duplo clique em **`setup.bat`**.
5. Confirme a solicitação de administrador do Windows e escolha uma opção no menu.

O launcher desbloqueia os arquivos baixados com `Unblock-File` e executa cada script
em um processo PowerShell com `ExecutionPolicy Bypass`. A política de execução do
Windows não é alterada permanentemente.

---

## Visão Geral dos Scripts

### **install-programs.ps1**
- Instala aplicativos comuns usando o `winget`.
- Inclui:
  - Aplicativos regulares (VSCode, Git, Chrome, etc.).
  - Aplicativos da Microsoft Store (WhatsApp).

### **customization-screen.ps1**
- Personaliza a aparência do Windows 11:
  - Ajusta o escalonamento de exibição.
  - Ativa o modo escuro.
  - Configura a barra de tarefas (alinhamento à esquerda, ícones pequenos).
  - Define uma cor sólida como plano de fundo.

### **install-wsl.ps1**
- Instala e configura o WSL2 (Subsistema do Windows para Linux):
  - Ativa os recursos necessários do Windows.
  - Define o WSL2 como versão padrão.
  - Instala a distribuição Ubuntu.

### **performance-optimize.ps1**
- Otimiza o Windows para melhor desempenho:
  - Ajusta efeitos visuais.
  - Configura prioridades de CPU e gerenciamento de memória.
  - Define o plano de energia de alto desempenho.

### **privacy-enhancement.ps1**
- Melhora as configurações de privacidade do Windows:
  - Desativa a telemetria e coleta de dados.
  - Configura diagnósticos e rastreamento de aplicativos.
  - Desativa o ID de publicidade.

### **taskbar-cleanup.ps1**
- Remove itens indesejados da barra de tarefas:
  - Desativa notícias e interesses.
  - Remove widgets.
  - Limpa itens de entrega de conteúdo.

### **user-avatar.ps1**
- Faz download e define o avatar do GitHub como a imagem de perfil do Windows.

### **debloat.ps1**
- Remove aplicativos e recursos desnecessários do Windows:
  - Desinstala bloatwares pré-instalados.
  - Desativa serviços e tarefas agendadas não essenciais.
  - Melhora o desempenho ao reduzir recursos não utilizados.

---

## Instalação

1. Clone este repositório ou baixe os scripts:
   - **Clonar**: Use o comando `git clone https://github.com/abreufilho/pc-setup-windows` no PowerShell.
   - **Baixar**: Use a opção **Download ZIP** no GitHub.
2. Extraia o arquivo ZIP baixado, se aplicável.
3. Navegue até a pasta extraída.
4. Execute `setup.bat` e confirme a solicitação de administrador.

O menu também permite abrir um PowerShell elevado, já posicionado na pasta do
repositório e com a liberação válida apenas para aquela sessão.

---

## Uso

### **Configuração Básica (Ordem Recomendada)**

```powershell
# 1. Primeiro, instale os programas básicos
.\scripts\install-programs.ps1

# 2. Instale o WSL2 (se necessário)
.\scripts\install-wsl.ps1

# 3. Aplique as personalizações visuais
.\scripts\customization-screen.ps1

# 4. Otimize o desempenho
.\scripts\performance-optimize.ps1

# 5. Melhore a privacidade
.\scripts\privacy-enhancement.ps1

# 6. Remova aplicativos indesejados
.\scripts\debloat.ps1

# 7. Limpe a barra de tarefas
.\scripts\taskbar-cleanup.ps1

# 8. Defina o avatar do GitHub como imagem de perfil
.\scripts\user-avatar.ps1
```

> O script do WSL pode solicitar uma reinicialização. Nesse caso, reinicie o
> computador e execute `setup.bat` novamente para continuar as demais etapas.

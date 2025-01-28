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
4. Abra o PowerShell como Administrador na pasta extraída.
5. Siga os passos na seção **Configuração Básica** abaixo.

---

## Visão Geral dos Scripts

### **install-programs.ps1**
- Instala aplicativos comuns usando o `winget`.
- Inclui:
  - Aplicativos regulares (VSCode, Git, Chrome, etc.).
  - Aplicativos da Microsoft Store (WhatsApp).

### **visual-customize.ps1**
- Personaliza a aparência do Windows 11:
  - Define o escalonamento de exibição para 100%.
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

### **privacy-enhance.ps1**
- Melhora as configurações de privacidade do Windows:
  - Desativa a telemetria e coleta de dados.
  - Configura diagnósticos e rastreamento de aplicativos.
  - Desativa o ID de publicidade.

### **taskbar-cleanup.ps1**
- Remove itens indesejados da barra de tarefas:
  - Desativa notícias e interesses.
  - Remove widgets.
  - Limpa itens de entrega de conteúdo.

### **github-avatar.ps1**
- Faz download e define o avatar do GitHub como a imagem de perfil do Windows.

### **customization-screen.ps1**
- Personaliza configurações de tela do Windows:
  - Configura o brilho e a resolução da tela.
  - Ajusta a taxa de atualização, se aplicável.
  - Permite configuração rápida para monitores múltiplos.

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
4. Clique com o botão direito no script desejado.
5. Selecione **Executar com PowerShell como Administrador**.

---

## Uso

### **Configuração Básica (Ordem Recomendada)**

```powershell
# 1. Primeiro, instale os programas básicos
.\install-programs.ps1

# 2. Instale o WSL2 (se necessário)
.\install-wsl.ps1

# 3. Aplique as personalizações visuais
.\visual-customize.ps1

# 4. Configure a tela
.\customization-screen.ps1

# 5. Otimize o desempenho
.\performance-optimize.ps1

# 6. Melhore a privacidade
.\privacy-enhance.ps1

# 7. Remova aplicativos indesejados
.\debloat.ps1

# 8. Limpe a barra de tarefas
.\taskbar-cleanup.ps1

# Defina o avatar do GitHub como imagem de perfil
.\github-avatar.ps1

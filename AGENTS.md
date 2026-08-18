# Diretrizes do repositório

- Compatibilidade mínima: Windows 11 e Windows PowerShell 5.1.
- Scripts devem ser idempotentes e retornar código diferente de zero em falhas.
- Executáveis nativos devem ter `$LASTEXITCODE` validado.
- Preferências ficam em `config/setup.psd1`; lógica reutilizável fica em
  `scripts/lib/Setup.Common.psm1`.
- Não desativar Windows Update, Microsoft Defender, Windows Security, firewall,
  pesquisa ou serviços essenciais.
- Não adicionar GitHub Actions. Execute o QA local com
  `powershell.exe -File .\tests\Invoke-StaticAnalysis.ps1`.


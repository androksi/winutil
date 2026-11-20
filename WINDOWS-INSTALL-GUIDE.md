# Guia: instalação limpa do Windows 11 com o WinUtil

Passo a passo para formatar e deixar o Windows pronto, usando o seu WinUtil
(`androksi/winutil`).

---

## Antes de formatar

### 1. Backup
- [ ] Copie seus arquivos (Documentos, Área de Trabalho, Downloads, Imagens) para um HD externo ou para a nuvem.
- [ ] Exporte senhas e favoritos do navegador, ou confirme que a sincronização está ativa.
- [ ] Anote ou exporte o que for preciso de programas importantes (licenças, configurações de jogos, chaves SSH etc.).
- [ ] Se o disco usa **BitLocker**, salve a **chave de recuperação** (Configurações → Privacidade e segurança → Criptografia do dispositivo).

### 2. Salve a sua configuração do WinUtil
Se você já tem o WinUtil configurado do seu jeito, exporte para reaplicar tudo depois com um comando:

1. Abra o WinUtil (PowerShell como Administrador):
   ```powershell
   irm https://androksi.github.io/winutil/win | iex
   ```
2. Marque os tweaks, toggles, apps, AppX e fontes que você quer.
3. Menu ⚙️ → **Export** → salve o `.json` **no pendrive ou na nuvem**, não no disco que vai ser formatado.

### 3. Drivers
- [ ] Baixe do site do fabricante o driver de **rede** (Wi-Fi ou cabo) da placa-mãe ou do notebook e guarde no pendrive. Sem rede, o resto não baixa.
- [ ] Opcional: o driver da placa de vídeo, para não depender do Windows Update.

### 4. Gere o pendrive com o Win11 Creator
1. Baixe a **ISO oficial do Windows 11** no site da Microsoft.
2. No WinUtil, aba **Win11 Creator** → **Browse** → selecione a ISO.
3. Escolha a **edição** (Pro) e, se for formatar **o mesmo PC**, marque **Inject current system drivers**. Isso evita ficar sem rede ou sem disco na instalação.
4. **Run Windows ISO Modification and Creator**.
5. **Write Directly to a USB Drive** → escolha o pendrive (8 GB ou mais) → **Erase & Write to USB**. Isso apaga tudo no pendrive.

O que a ISO já faz sozinha: pula a conta Microsoft (conta local), ignora requisitos de TPM e CPU, remove apps inúteis, desliga telemetria e sugestões, e desinstala o OneDrive no primeiro login.

> A ISO também remove o **Paint** e o **Media Player**. Se quiser algum deles de volta, reinstale pelo **AppX Removal → Install Selected** ou pela Microsoft Store.

---

## Durante a instalação

1. Dê boot pelo pendrive (tecla de boot do BIOS: F12, F11, F8 ou Esc, depende da placa).
2. Na tela de discos, **apague as partições do disco onde o Windows estava** e instale no espaço não alocado. Cuidado para não apagar o disco de dados, se tiver mais de um.
3. Siga a instalação. A conta local é criada sem pedir conta Microsoft.
4. No primeiro login, uma janela roda os scripts de configuração e **reinicia o PC sozinha** no fim. **Não feche essa janela.**

---

## Depois de instalar

### 1. Rede e atualizações
- [ ] Se estiver sem internet, instale o driver de rede do pendrive.
- [ ] **Configurações → Windows Update** → procure atualizações e instale tudo. Reinicie e repita até não sobrar nenhuma.
- [ ] Em **Configurações → Windows Update → Opções avançadas → Atualizações opcionais**, veja se há drivers.

### 2. Rode o WinUtil
Abra o PowerShell **como Administrador**.

**Se você exportou a configuração** (passo 2 de antes), um comando faz tudo:
```powershell
& ([ScriptBlock]::Create((irm https://androksi.github.io/winutil/win))) -Config "D:\minha-config.json"
```
Troque o caminho pelo do seu arquivo e pule para o passo 4.

**Se não exportou**, abra a interface:
```powershell
irm https://androksi.github.io/winutil/win | iex
```

### 3. Configurações recomendadas (manual)

**Aba Tweaks → Essential Tweaks** (marque e clique em **Run Tweaks**):
- [ ] Restore Point - Create (marque primeiro, vale como seguro)
- [ ] Activity History - Disable
- [ ] ConsumerFeatures - Disable (impede LinkedIn, Adobe Express e similares de voltarem)
- [ ] Telemetry - Disable
- [ ] Services - Set to Manual
- [ ] Windows Tips and Ads - Disable
- [ ] Delivery Optimization - Disable
- [ ] WPBT - Disable
- [ ] Prevent Device Companion Apps
- [ ] End Task With Right Click - Enable
- [ ] Temporary Files - Remove

**Aba Tweaks → Advanced** (só o que fizer sentido para você):
- [ ] Windows AI - Disable
- [ ] Windows Spotlight - Disable
- [ ] Debloat dos navegadores que você usa (Edge, Chrome, Firefox, Brave)
- [ ] File Explorer Home and Gallery - Disable
- [ ] Right-Click Menu Previous Layout - Enable
- [ ] Taskbar Pinned Apps - Remove / Start Menu Pinned Apps - Remove
- [ ] DNS - escolha um provedor (por exemplo, Cloudflare ou Quad9)

**Aba Tweaks → Customize Preferences** (toggles, aplicam na hora):
- Dark Theme, File Explorer File Extensions, Hidden Files, Sticky Keys desligado, Start Menu Recommendations desligado, Fast Startup desligado (se usa dual boot)

**AppX Removal** (botão na aba Tweaks):
- [ ] **Default** → confira a seleção → **Remove Selected**
- [ ] Não joga jogos da Microsoft Store/Game Pass? Clique no título **Xbox & Gaming** para marcar tudo e remova.

**Aba Install:**
- [ ] Marque os seus programas (navegador, 7-Zip, VLC, Discord etc.) → **Install/Upgrade Applications**

**Aba Config → Fonts:**
- [ ] Marque as fontes que usa → **Install Fonts**

**Aba Config → Features:**
- [ ] Só o que você precisa: WSL, Windows Sandbox, .NET Framework, Hyper-V

### 4. Finalização
- [ ] Reinicie o PC.
- [ ] Instale o driver da placa de vídeo do fabricante, se ainda não instalou.
- [ ] Ative o Windows (Configurações → Sistema → Ativação). Se o Windows já estava ativado nesse PC, a ativação volta sozinha.
- [ ] Restaure seus arquivos do backup.
- [ ] Monte de novo a seleção no WinUtil e use **Export** para salvar a configuração atualizada para a próxima formatação.

---

## Se algo der errado

- **Um tweak causou problema:** marque o tweak → **Undo Selected Tweaks**. Os toggles se desfazem só desligando.
- **Algo grave:** Configurações → Sistema → Recuperação → **Restaurar o sistema** para o ponto criado pelo WinUtil.
- **Log do WinUtil:** `%LocalAppData%\winutil\logs\` (arquivo `winutil_*.log` mais recente).
- **Log da instalação pela ISO:** `C:\Windows\Setup\Scripts\FirstLogon.log` e `WinUtil-PostInstall.log`.

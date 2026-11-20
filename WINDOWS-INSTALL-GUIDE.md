# Guia: instalação limpa do Windows 11 com o WinUtil

Passo a passo para formatar com a mídia oficial da Microsoft e depois deixar o
Windows pronto com o seu WinUtil (`androksi/winutil`).

---

## Antes de formatar

### 1. Backup
- [ ] Copie seus arquivos (Documentos, Área de Trabalho, Downloads, Imagens) para um HD externo ou para a nuvem.
- [ ] Exporte senhas e favoritos do navegador, ou confirme que a sincronização está ativa.
- [ ] Anote ou exporte o que for preciso de programas importantes (licenças, configurações de jogos, chaves SSH etc.).
- [ ] Se o disco usa **BitLocker** ou **Criptografia do dispositivo**, salve a **chave de recuperação** (Configurações → Privacidade e segurança → Criptografia do dispositivo).

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
- [ ] Em notebooks e PCs Intel recentes, baixe também o driver **Intel RST / VMD** (armazenamento). Sem ele, a instalação pode não mostrar o disco.
- [ ] Opcional: o driver da placa de vídeo, para não depender do Windows Update.

### 4. Crie o pendrive oficial
1. Baixe a **Ferramenta de Criação de Mídia do Windows 11** no site da Microsoft.
2. Rode a ferramenta, escolha idioma e edição e selecione **Unidade flash USB** (pendrive de 8 GB ou mais). Isso apaga tudo no pendrive.
3. Copie para o pendrive os drivers do passo 3 e o `.json` do WinUtil.

---

## Durante a instalação

1. Dê boot pelo pendrive (tecla de boot do BIOS: F12, F11, F8 ou Esc, depende da placa).
2. Se a lista de discos aparecer vazia, clique em **Carregar driver** e aponte para o driver de armazenamento (Intel RST/VMD) do pendrive.
3. Na tela de discos, **apague as partições do disco onde o Windows estava** e instale no espaço não alocado. Cuidado para não apagar o disco de dados, se tiver mais de um.
4. Na configuração inicial, o Windows pede internet e conta Microsoft. Entre com a sua conta; dá para trocar para conta local depois em **Configurações → Contas → Suas informações** (se a opção aparecer na sua versão).
5. Nas telas de privacidade, desmarque tudo (localização, diagnóstico opcional, anúncios, experiências personalizadas etc.).

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
- [ ] Microsoft OneDrive - Remove (se não usa)
- [ ] Debloat dos navegadores que você usa (Edge, Chrome, Firefox, Brave)
- [ ] File Explorer Home and Gallery - Disable
- [ ] Right-Click Menu Previous Layout - Enable
- [ ] Taskbar Pinned Apps - Remove / Start Menu Pinned Apps - Remove
- [ ] DNS - escolha um provedor (por exemplo, Cloudflare ou Quad9)

**Aba Tweaks → Customize Preferences** (toggles, aplicam na hora):
- Dark Theme, File Explorer File Extensions, Hidden Files, Sticky Keys desligado, Start Menu Recommendations desligado, Fast Startup desligado (se usa dual boot)

**AppX Removal** (botão na aba Tweaks):
- [ ] **Default** → confira a seleção → **Remove Selected** (inclui Teams, Outlook novo, Copilot, LinkedIn, Adobe Express, Solitaire e outros)
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
- [ ] Confira a ativação (Configurações → Sistema → Ativação). Se o Windows já estava ativado nesse PC, a ativação volta sozinha.
- [ ] Criptografia do dispositivo: com conta Microsoft, o Windows pode ligar sozinho e guardar a chave na sua conta. Mantenha ligado, ou desligue em **Configurações → Privacidade e segurança → Criptografia do dispositivo** se preferir.
- [ ] Restaure seus arquivos do backup.
- [ ] Monte de novo a seleção no WinUtil e use **Export** para salvar a configuração atualizada para a próxima formatação.

---

## Alternativa sem pendrive: Restaurar este PC

Em **Configurações → Sistema → Recuperação** há duas opções:

**Restaurar o PC** (reinstala o Windows do zero)
1. **Restaurar o PC** → **Remover tudo** → **Download na nuvem**.
2. O Windows baixa uma cópia nova da Microsoft e reinstala, sem pendrive.
3. Depois, siga a seção **Depois de instalar** deste guia.

- Use **Download na nuvem**, não **Reinstalação local**: a local usa a imagem guardada no PC, que pode trazer de volta os apps do fabricante.
- Só formata o disco do Windows; outros discos não são apagados.
- Faça o **backup** antes, como numa formatação normal.

**Corrigir problemas usando o Windows Update** (não é formatação)
- Reinstala o Windows **mantendo seus arquivos e programas**. Serve para consertar um Windows com problema sem perder nada.

---

## Se algo der errado

- **Um tweak causou problema:** marque o tweak → **Undo Selected Tweaks**. Os toggles se desfazem só desligando.
- **Algo grave:** volte ao ponto de restauração criado pelo WinUtil: aba **Config → Legacy Windows Panels → Windows Restore** (ou Win+R → `rstrui`).
- **Log do WinUtil:** `%LocalAppData%\winutil\logs\` (arquivo `winutil_*.log` mais recente).

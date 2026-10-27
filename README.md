# NixOS — @madd4

Meu flake pessoal com **flake-parts**, **import-tree** e **Home Manager**.

## 1. Preparar o novo computador

Instale primeiro o **NixOS 26.05** normalmente e inicialize o sistema. Use o usuário correspondente ao perfil escolhido:

| Perfil | Usuário | Hostname atual |
| --- | --- | --- |
| `desktop` | `mad` | `tarnished` |
| `laptop` | `mathias` | `nixos` |

> Ao reutilizar um perfil em outro PC, confira usuário, hostname, drivers, discos e bootloader nos arquivos de `hosts/` e `modules/`.

## 2. Configurar GitHub (SSH)

Se Git/OpenSSH ainda não estiverem instalados, abra um ambiente temporário com `nix-shell -p git openssh`.

```sh
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

Cadastre **a chave pública** em [GitHub → SSH keys](https://github.com/settings/keys), como uma *Authentication Key*. Depois teste e clone:

```sh
ssh -T git@github.com
git clone git@github.com:mathiasdavilaa/nixos.git ~/nixos
```

Se tiver um backup seguro da chave SSH, também pode restaurá-la no lugar de gerar outra. **Nunca coloque a chave privada no Git.**

## 3. Adaptar o hardware

No NixOS já instalado **no novo computador**, escolha `desktop` ou `laptop` e gere a configuração de hardware correspondente:

```sh
sudo nixos-generate-config --show-hardware-config > ~/nixos/hosts/laptop/hardware-configuration.nix
```

Troque `laptop` por `desktop` quando necessário. Confira também as configurações específicas em `hosts/<perfil>/default.nix` (GPU, Secure Boot/Limine, montagem de discos etc.). **Não reutilize cegamente a configuração de hardware de outro computador.**

## 4. Aplicar o flake

```sh
cd ~/nixos
git add -A
sudo nixos-rebuild switch --flake .#laptop
```

Troque `laptop` por `desktop`, se for o caso. Se flakes ainda estiverem desabilitados na instalação inicial, execute o rebuild assim: `sudo env NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake .#laptop`. Reinicie e entre novamente na sessão após a primeira aplicação.

## Comandos do dia a dia

| Comando | Ação |
| --- | --- |
| `nrs` | Reconstrói o host atual (de acordo com o hostname). |
| `nru` | Atualiza os inputs do flake. |
| `fc` | Faz commit (`flake commit`) e push. |
| `fc "mensagem"` | Faz commit com mensagem personalizada e push. |

> `nrs`, `nru` e `fc` são funções/aliases do Fish e ficam disponíveis depois que o Home Manager é aplicado. O `nrs` reconhece os hostnames configurados em `modules/home/fish.nix`.

**Depois de reinstalar:** entre novamente nas contas de aplicativos (Codex, Claude etc.) e restaure outros segredos pessoais fora do repositório.

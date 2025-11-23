## Pour débuter

# Depuis votre machine Ubuntu 24.04

```bash
sudo -s + mot de passe
whoami
pwd
apt update
apt install openssh-server
service ssh status (pour quitter saisir :q)
service ssh start
service ssh enable
service ssh status
```

# Récupérer l'adresse IP qui correpond à la deuxième carte enp0s8

```bash
ip a
```

Je note l'addresse devant la ligne inet


# Depuis votre machine windows
- Ouvrir un termainl cmd

```bash
ssh username@IP
```

exemple

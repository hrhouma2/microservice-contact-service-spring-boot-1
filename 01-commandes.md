## Pour débuter

# 01 - Depuis votre machine Ubuntu 24.04

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

- Je note l'addresse devant la ligne inet.
- Exemple:

<img width="881" height="152" alt="image" src="https://github.com/user-attachments/assets/eef66665-c39e-48d7-92b3-51d870317755" />



# 02 - Depuis votre machine windows
- Ouvrir un termainl cmd

```bash
ssh username@IP
```

## exemple

<img width="761" height="72" alt="image" src="https://github.com/user-attachments/assets/8f4baa00-783d-4662-9dd4-b7f09d21b9ea" />


# 03 - connectez-vous comme administrateur 


<img width="722" height="178" alt="image" src="https://github.com/user-attachments/assets/cbd4c866-b7a7-4729-9dea-2ed18488f90a" />


# 04 - manipulations



```bash
apt install git
git clone  https://github.com/hrhouma2/microservice-contact-service-spring-boot-1.git
cd microservice-contact-service-spring-boot-1
ls
```

### Commandes à Exécuter (Copier-Coller)

```bash
# 1. Aller dans le Bureau
cd /home/eleve/Bureau

# 2. Cloner le projet
git clone https://github.com/hrhouma2/microservice-contact-service-spring-boot-1.git

# 3. Entrer dans le dossier
cd microservice-contact-service-spring-boot-1/scripts

# 4. Rendre les scripts exécutables
chmod +x *.sh

# 5. Vérifier les prérequis
bash 00-verifier-prerequis.sh

# 6. Lancer l'installation complète
sudo bash 00-installation-complete.sh
```


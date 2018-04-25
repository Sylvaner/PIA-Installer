# PIA-Installer
Script d'installation pour la solution PIA (serveur back-end)

Outil fournit par la CNIL pour faciliter la mise en place de la RGPD : https://www.cnil.fr/fr/outil-pia-telechargez-et-installez-le-logiciel-de-la-cnil

_"Le logiciel open source PIA facilite la conduite et la formalisation d’analyses d’impact sur la protection des données telles que prévues par le RGPD."_

Dépôt GitHub du projet : https://github.com/LINCnil/pia-back

# Prérequis

Le script est fonctionnel sur une distribution Debian 9 Stretch nouvellement installé.

# Installation

Le script doit être lancé en root.

```
wget https://raw.githubusercontent.com/Sylvaner/PIA-Installer/master/install-pia.sh --no-check-certificate
chmod +x install-pia.sh
./install-pia.sh
```

# Configuration

Une fois le logiciel lancé, allez et renseignez l'adresse du serveur.

Exemple : http://MON_IP:3000

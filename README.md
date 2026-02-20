# ShieldX - Anticheat FiveM (base complète)

> Ressource FiveM orientée protection serveur + menu staff in-game.

## Fonctionnalités incluses

### Anticheat (client + server)
- Détection godmode, invisibilité, super jump, speedhack, téléport suspecte.
- Détection de blacklists d'armes, véhicules, peds, explosions.
- Limitation du spam d'events/trigger.
- Détection vision thermique/nocturne forcée.
- Détection modification anormale des dégâts et munitions.
- Logging Discord webhook pour violations + actions staff.
- Sanction automatique (DropPlayer) configurable.

### Menu staff in-game
- Ouvrir via `F10` (ou commande `/shieldx`).
- Noclip AZERTY fonctionnel (Z/S/Q/D + Q/E vertical, Shift accélération).
- Freecam avec mouvement caméra.
- TP waypoint.
- Gestion météo / heure globale.
- Spawn véhicule.
- Give weapon.
- Revive / freeze.

## Installation
1. Copiez ce dossier dans vos resources (ex: `resources/[admin]/shieldx`).
2. Ajoutez `ensure shieldx` dans votre `server.cfg`.
3. Configurez `shared/config.lua` :
   - `StaffIdentifiers`
   - blacklists
   - permissions ACE
   - webhooks Discord

## Permission recommandée (server.cfg)

```cfg
add_ace group.admin shieldx.menu allow
add_principal identifier.license:VOTRE_LICENSE group.admin
```

## Notes
- Cette base est volontairement modulaire pour que vous puissiez la connecter à ESX/QBCore.
- Pour des actions SQL (give money/items/jobs), ajoutez vos callbacks serveur framework.
- Testez chaque détection avant de passer en production pour éviter les faux positifs.

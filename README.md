# ShieldX + PulseLite RP (FiveM)

> Base RP légère et optimisée, inspirée des serveurs citylife modernes (économie + jobs + besoins + inventaire), combinée à l'anticheat ShieldX.

## ⚠️ Important
Cette base est **inspirée** du gameplay RP populaire, mais ne copie pas de code propriétaire externe.

## Modules inclus

### 1) Anticheat ShieldX
- Détections client + serveur (godmode, invisibilité, speedhack, explosions, armes/veh blacklists, rapid fire, etc.).
- Logs webhook Discord.
- Menu staff (noclip, freecam, météo, heure, revive/freeze, spawn véhicule).

### 2) PulseLite RP (nouveau)
- **Profil joueur persistant** (KVP): cash, banque, besoins, job, inventaire, dernière position.
- **Économie optimisée**: opérations atomiques, limitations de transfert, paie périodique selon le job.
- **Jobs/grades** configurables dans `shared/rp_config.lua`.
- **Inventaire poids** + objets utilisables (`/useitem water`, `bread`, `bandage`, `repairkit`).
- **HUD RP minimal** (cash, banque, job, faim/soif/stress) avec `/hudrp`.
- **Commandes utiles**:
  - `/rpstats`
  - `/pay [id] [montant]`
  - `/setjob [id] [job] [grade]` (ACE admin)

## Architecture
- `shared/config.lua` -> anticheat + staff
- `shared/rp_config.lua` -> réglages RP (jobs, items, limites)
- `server/rp_core.lua` -> logique serveur RP (save, paie, transfert, inventaire)
- `client/rp_core.lua` -> HUD + sync besoins + usage objets

## Installation
1. Placez la ressource dans vos resources.
2. Ajoutez dans `server.cfg`:

```cfg
ensure anticheat-byTekaz
add_ace group.admin shieldx.menu allow
```

3. Éditez `shared/config.lua` et `shared/rp_config.lua` selon votre ville.

## Conseils optimisation
- L'écriture disque est **batchée** via `Dirty` + intervalle `SaveIntervalMs`.
- Les syncs serveur sont intervalées (besoins/position toutes les 15s).
- L'usage des state bags peut être coupé (`UseStateBags = false`) si vous avez déjà un système custom.

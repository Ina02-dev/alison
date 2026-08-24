# Alison → TestFlight (Codemagic)

| | |
|---|---|
| Bundle ID | `al.alison.app` |
| Repo | [Ina02-dev/alison](https://github.com/Ina02-dev/alison) |
| Workflow | `Alison TestFlight` |

## Para build-it

1. **App Store Connect** → My Apps → **+** → iOS app me bundle ID **`al.alison.app`**
2. Codemagic → Developer Portal API key me emrin **`Alison`**
3. Fetch **App Store** certificate + profile për **`al.alison.app`**
4. **Start new build** → branch `main` → workflow **Alison TestFlight**

Pas suksesit: App Store Connect → **Alison** → TestFlight.

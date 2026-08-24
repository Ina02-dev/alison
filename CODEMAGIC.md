# Alison → TestFlight (Codemagic)

| | |
|---|---|
| Bundle ID | `al.alison.app` |
| App Store Connect Apple ID | `6804735818` |
| App name | Alison1 |
| Repo | [Ina02-dev/alison](https://github.com/Ina02-dev/alison) |
| Workflow | `Alison TestFlight` |

## Para build-it

1. Codemagic → Developer Portal API key me emrin **`Alison`**
2. Fetch **App Store** certificate + profile për **`al.alison.app`**
   - Nëse Fetch dështon: te [developer.apple.com](https://developer.apple.com/account/resources/profiles/list) krijo **App Store** profile për `al.alison.app`, pastaj Upload në Codemagic
3. **Start new build** → branch `main` → **Alison TestFlight**

Pas suksesit: App Store Connect → **Alison1** → TestFlight.

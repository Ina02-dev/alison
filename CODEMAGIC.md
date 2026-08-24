# Alison → I'Dea Shop TestFlight

Për momentin Alison ngarkohet **si build i ri i I'Dea Shop** (jo app i ri).

| | |
|---|---|
| Bundle ID | `al.ideashop.app` |
| App Store Connect ID | `6804282383` |
| Apple ID (EAS) | `ina.laraku02@gmail.com` |

> **Kujdes:** testerët që instalojnë “I'Dea Shop” nga TestFlight do të marrin këtë build (ring try-on), jo shop-in Expo, derisa të ngarkosh përsëri build-in e shop-it.

## Hapat

1. Krijo/lidh repo Git për folderin `alison` dhe shtoje në [Codemagic](https://codemagic.io)
2. Team → **Developer Portal** → API key me emrin **`Alison`** (ose ndrysho emrin në `codemagic.yaml`)
3. Fetch **App Store** certificate + profile për `al.ideashop.app` (i njëjti si shop-i)
4. **Start new build** → workflow **Alison → I'Dea Shop TestFlight**

Pas ~10–20 min: App Store Connect → **I'Dea Shop** → TestFlight → build i ri.

## Kur të ndash app-et

Kthe bundle ID-në e Alison në diçka si `al.ideashop.alison` / `com.alison.ringtryon` dhe krijo app të ri në App Store Connect.

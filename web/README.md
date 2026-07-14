# Tathmfy web

Static marketing site and lender verification portal for **tathmfy.com**.

| Path | Purpose |
|------|---------|
| `index.html` | Landing page |
| `verify/` | Live credential validation |
| `privacy/` | Privacy policy |
| `config.js` | Verify endpoint configuration |
| `assets/` | Favicons and OG image |

## Local preview

```bash
npx serve .
```

## Deploy

Hosted on Vercel. Verify backend: Supabase (credential metadata only — no transaction ledger).

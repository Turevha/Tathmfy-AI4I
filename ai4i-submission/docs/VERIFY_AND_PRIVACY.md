# Verification and privacy

## Product promise

The borrower owns their financial ledger. Lenders receive **proof**, not **data**.

## Share flow

1. User builds score on-device from logged and scanned activity.
2. App signs a credential with a device-held key (Secure Enclave / CryptoKit).
3. User shares a verification code (e.g. `TMF-694-A7X2`) and optional PDF.
4. Lender opens https://tathmfy.com/verify and enters the code.
5. Verify service validates signature and returns **only the fields on the credential**.

## Server-side storage (Supabase)

The verify store holds **metadata**, not a credit ledger:

- Credential code
- Public verification material
- Issue and expiry timestamps
- Status (active / revoked)

No transaction amounts, categories, or raw statements are stored server-side.

## Data Protection Act alignment

| Principle | How architecture supports it |
|-----------|-------------------------------|
| Data minimisation | Ledger stays on device |
| Consent | Per-share; user initiates every credential |
| Purpose limitation | No central behavioural warehouse to repurpose |
| Storage limitation | Verify DB is credentials only |

## Revocation

Users can revoke credentials from the app. Verification checks status before returning fields.

## Lender integration

Current: zero-integration browser portal.  
Roadmap: REST batch verify API with audit logging (documented in proposal appendix).

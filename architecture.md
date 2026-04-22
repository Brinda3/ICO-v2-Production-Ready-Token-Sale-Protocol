# ICO v2 — Architecture

---

##  System Topology


                ┌───────────────────────────┐
                │        PARTICIPANT        │
                │   (Investor / User)       │
                └────────────┬──────────────┘
                             │
                             ▼
                ┌───────────────────────────┐
                │     KYC VERIFICATION      │
                │  Signature + Nonce Check  │
                └────────────┬──────────────┘
                             │
                             ▼
                ┌───────────────────────────┐
                │       SALE ENGINE         │
                │  Round Logic + Pricing    │
                └────────────┬──────────────┘
                             │
                             ▼
             ┌──────────────────────────────────────────┐
             ▼                                          ▼
         ┌───────────────────────────┐ ┌───────────────────────────┐
         │     REFERRAL ENGINE       │ │     PRICE ORACLE LAYER    │
         │   Reward Distribution     │ │   External Price Feeds    │
         └────────────┬──────────────┘ └────────────┬──────────────┘
                   
                └───────────────┬───────────────────────┘
                                ▼
                    ┌───────────────────────────┐
                    │   TOKEN ALLOCATION        │
                    │   State Update + Transfer │
                    └───────────────────────────┘

## Execution Flow

                  [1] User initiates purchase
                              │
                              ▼
                  [2] KYC Signature Submitted
                              │
                              ▼
                  [3] Signature + Nonce Validation
                              │
                              ▼
                  [4] Fetch Latest Price (Oracle)
                              │
                              ▼
                  [5] Determine Active Sale Round
                              │
                              ▼
                  [6] Calculate Token Allocation
                              │
                              ▼
                  [7] Process Referral Rewards
                              │
                              ▼
                  [8] Update State + Emit Events

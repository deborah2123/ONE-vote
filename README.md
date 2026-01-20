# ONE-vote: Simple On-Chain YES/NO Voting Smart Contract

A beginner-friendly Clarity smart contract for a basic on-chain voting system. Each address can vote exactly once, choosing either YES or NO. Results are publicly readable and the contract is intentionally verbose for educational purposes.

## Features

- **One vote per address:** Prevents double voting using a `voters` map.
- **YES/NO voting:** Users can vote either YES (`true`) or NO (`false`).
- **Publicly readable results:** Anyone can query the current vote totals.
- **Beginner-friendly:** Well-commented and easy to understand.

## Contract Overview

- **Global State:**
  - `yes-count`: Total number of YES votes.
  - `no-count`: Total number of NO votes.
- **Voters Map:**
  - Tracks which addresses have already voted.
- **Error Codes:**
  - `u100`: User has already voted.

## Public Functions

### `vote (choice: bool)`

Allows a user to vote YES (`true`) or NO (`false`).

- **Rules:**
  - Caller must not have voted before.
  - Vote is permanently recorded.
- **Returns:**
  - `(ok true/false)` on success.
  - `(err u100)` if user already voted.

### `get-results`

Returns the current vote totals.

```clarity
(ok { yes: (var-get yes-count), no: (var-get no-count) })
```

### `has-voted (who: principal)`

Checks whether a given address has already voted.

- **Returns:** `true` if already voted, `false` otherwise.

## Usage

1. **Deploy the contract** using [Clarinet](https://docs.stacks.co/write-smart-contracts/clarinet).
2. **Call `vote`** with your choice (`true` for YES, `false` for NO).
3. **Query `get-results`** to see the current vote counts.
4. **Check `has-voted`** to verify if an address has already voted.

## Example

```clarity
;; Cast a YES vote
(vote true)

;; Cast a NO vote
(vote false)

;; Get current results
(get-results)

;; Check if an address has voted
(has-voted 'SP2C2...XYZ)
```

## File Structure

- `contracts/ONE-vote.clar` – Main smart contract
- `tests/ONE-vote.test.ts` – Test cases (if provided)
- `Clarinet.toml`, `package.json`, etc. – Project configuration

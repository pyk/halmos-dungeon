# Halmos Dungeon

Welcome to my Halmos Dungeon! This repository contains a series of smart
contract challenges I created while learning Halmos. Follow along as I use
symbolic execution to hunt for the hidden dragon 🐲 (vulnerability) in each
level!

## Halmos & Foundry Version

```shell
% forge --version
forge Version: 1.0.0-stable
Commit SHA: e144b82070619b6e10485c38734b4d4d45aebe04
Build Timestamp: 2025-02-13T20:02:34.979686000Z (1739476954)
Build Profile: maxperf

% halmos --version
halmos 0.2.6
```

## Level 1: SimpleKnob

I've created this SimpleKnob contract as a simple test case for Halmos.
Initially, the public `property` is set to 1 ether.

The contract includes three functions: `one()`, `two()`, and `three()`.
The functions `two()` and `three()` have checks (`revert`) intended to control
the state transitions, requiring `one()` to be called before `two()`, and both
`one()` and `two()` to be called before `three()` can successfully execute and
modify the `property`.

The goal is for Halmos to analyze this contract and discover the specific sequence
of external calls (`one()`, then `two()`, then `three()`) that successfully
bypasses the revert conditions and leads to a state where the invariant
`property == 1 ether` no longer holds, ultimately setting property to 3 ether.
Halmos should identify this state transition path as a way to alter the contract's
intended initial property value.

```shell
% halmos --contract SimpleKnobTest --early-exit -st
[⠊] Compiling...
No files changed, compilation skipped

Running 1 tests for test/L1_SimpleKnob.t.sol:SimpleKnobTest
setup: 0.01s (decode: 0.00s, run: 0.00s)
Counterexample: ∅
[FAIL] check_invariant() (paths: 4, time: 0.28s (paths: 0.28s, models: 0.00s), bounds: [])
Symbolic test result: 0 passed; 1 failed; time: 0.29s

[time] total: 0.64s (build: 0.22s, load: 0.13s, tests: 0.29s)
```

## Level 2: HookTakeover

In this challenge, the HookTakeOver contract guards access to its `execute()`
function, which sets the exploited flag to `true`. Initially, only a specific
hook address (provided during deployment) is authorized.

My goal is to learn how to write symbolic test that can find a sequence of interactions
involving `toggle()` and `setHook()` that allows an unauthorized caller to eventually
gain the necessary permissions and call `execute()`, thus breaking the
`exploited == false` invariant.

```shell
% halmos --contract HookTakeoverTest --early-exit -st
[⠊] Compiling...
No files changed, compilation skipped

Running 1 tests for test/L2_HookTakeover.sol:HookTakeoverTest
setup: 0.01s (decode: 0.00s, run: 0.01s)
Counterexample:
    p_caller_address_5cf5c44_00 = 0x00
    p_newHook_address_56f65a7_12 = 0x00
[FAIL] check_invariant(address) (paths: 7, time: 0.53s (paths: 0.53s, models: 0.00s), bounds: [])
Symbolic test result: 0 passed; 1 failed; time: 0.54s

[time] total: 0.90s (build: 0.22s, load: 0.14s, tests: 0.54s)
```

## Level 3: PiggyBank

In this level, I'm trying to wrap my head around Halmos's behavior concerning
symbolic execution and state assumptions.

My initial expectation was that the test would fail because:

- The test setup **did not** explicitly fund the actor's token balance.
- The test setup **did not** explicitly approve the target contract to spend the actor's tokens.

However, the test passed. This occurred because:

- Using `vm.assume` on the balance forced Halmos to consider only execution paths where the actor's initial balance was already sufficient for the transfer. It filters possibilities rather than creating state.
- We did not constrain the token allowance state (e.g., using `vm.assume` or by setting it explicitly). Halmos was therefore free to explore scenarios where the allowance was sufficient.
- Consequently, because a possible symbolic state existed where:
  - the balance met the `vm.assume` condition,
  - and the allowance was sufficient (being unconstrained), the transferFrom could succeed and the final assertions held true. As a result, Halmos could not find a counterexample under these specific test conditions and reported `[PASS]`.

```shell
% halmos --contract PiggyBankTest --early-exit -st
[⠊] Compiling...
[⠑] Compiling 1 files with Solc 0.8.28
[⠘] Solc 0.8.28 finished in 584.23ms
Compiler run successful!

Running 1 tests for test/L3_PiggyBank.t.sol:PiggyBankTest
setup: 0.03s (decode: 0.01s, run: 0.03s)
[PASS] check_deposit() (paths: 2, time: 0.20s (paths: 0.09s, models: 0.11s), bounds: [])
Symbolic test result: 1 passed; 0 failed; time: 0.24s

[time] total: 1.32s (build: 0.93s, load: 0.15s, tests: 0.24s)
```

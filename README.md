# Halmos Playground

My personal halmos playground.

```shell
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

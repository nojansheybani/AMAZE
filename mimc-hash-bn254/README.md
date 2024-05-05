# mimc-hash

FPGA implementation of MiMC operations.

## Project structure

```
project-root
├── README.md (This file)
├── src
│   ├── top (Assembled hardware modules)
│   └── base (Hardware modules)
├── tb (Testbenches for hardware modules)
├── data (Hardcoded data files)
└── modelsim (Intel ModelSim project files)
    ├── load.do (Library loader script)
    ├── run_test (Testbench runner script)
    ├── work (NOT pushed)
    └── transcript (NOT pushed)
```

## How to run a Testbench

1.  Switch to the `modelsim` directory:
    ```sh
    cd modelsim
    ```

1.  Use the `run_test` script to run any testbench:
    ```sh
    ./run_test tb_mimc
    ```

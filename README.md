# td3-fpid-lfc

TD3-based parameter design of a fuzzy-PID (FPID) load frequency controller for a nonlinear renewable-integrated two-area power system.

The repository contains the Simulink models, the TD3 training script, the trained agents, and the learned FPID parameters.

## Requirements

MATLAB and Simulink R2025b with the Reinforcement Learning Toolbox, Deep Learning Toolbox and Fuzzy Logic Toolbox.

## Structure

```
td3-fpid-lfc/
├── run_extract_parameters.m   fixed FPID parameter vector of the trained agents
├── run_offline_FPID.m         simulation with the extracted parameters
├── plot_training_curves.m     training curves
├── run_train_TD3_FPID.m       training of new agents (optional)
├── models/                    Simulink models and fuzzy inference system
├── src/                       plant parameters, environment, networks, training live script
```

## License

Released under the MIT License (see `LICENSE`).

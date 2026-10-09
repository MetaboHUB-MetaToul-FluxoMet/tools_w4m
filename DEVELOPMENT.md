## Development Setup

This guide covers the tooling used to work on the fluxomics tools and their Galaxy wrappers. For running the local Galaxy instance, see the [README](README.md).

### Development Environment

The development tools (planemo, pytest, shellcheck, and jq for `tool_wrappers/run_tests.sh`) live in their own conda environment, separate from Galaxy's virtualenv:

```bash
mamba env create -f environment-dev.yml
conda activate tools_w4m-dev
```

After changing `environment-dev.yml`, update the environment with `mamba env update -f environment-dev.yml`.

### Galaxy Wrappers: the tools-metabolomics Submodule

The wrappers published on Workflow4Metabolomics live in [workflow4metabolomics/tools-metabolomics](https://github.com/workflow4metabolomics/tools-metabolomics). The `tools-metabolomics` submodule is a fork of that repository.

The repository is large (about 1.8 GB), so initialise the submodule as a partial clone that only checks out the fluxomics tools:

```bash
git submodule init tools-metabolomics
git clone --filter=blob:none --sparse https://github.com/llegregam/tools-metabolomics.git tools-metabolomics
git -C tools-metabolomics sparse-checkout set tools/physiofit tools/physiofit_manager tools/influx_data_manager tools/influx_si tools/skyline2isocor tools/isoplot .github
git submodule absorbgitdirs tools-metabolomics
git submodule update tools-metabolomics
```

**Note:** A plain `git submodule update --init` also works, but downloads the whole repository.

Then add the upstream repository as a second remote. The two `config` lines keep fetches from upstream partial too; without them, the first fetch downloads about 100 MB:

```bash
cd tools-metabolomics
git remote add upstream https://github.com/workflow4metabolomics/tools-metabolomics.git
git config remote.upstream.promisor true
git config remote.upstream.partialclonefilter blob:none
git fetch upstream
```

### Contributing a Wrapper Change to W4M

1. Start a branch from upstream, not from the fork's `master`, so the fork's sync merges stay out of the pull request:

    ```bash
    cd tools-metabolomics
    git fetch upstream
    git switch -c <branch-name> upstream/master
    ```

2. Edit the wrapper under `tools/<tool>/`, bump its version suffix (`+galaxyN`), then lint and test it (see below).
3. Push the branch to the fork (`git push -u origin <branch-name>`) and open a pull request against `workflow4metabolomics/tools-metabolomics`. Its CI lints and tests the changed tools on Galaxy `release_26.0`, and deploys them to the ToolShed once merged.

To bring the fork up to date with upstream, use **Sync fork** on the fork's GitHub page, then update the submodule pointer:

```bash
git -C tools-metabolomics pull origin master
git add tools-metabolomics
git commit -m "Update tools-metabolomics submodule"
```

### Linting and Testing Wrappers

Run these from the repository root, with the `tools_w4m-dev` environment active.

Lint a wrapper the way the tools-metabolomics CI does:

```bash
planemo lint --fail_level warn tools-metabolomics/tools/physiofit
```

Run a wrapper's tests on the same Galaxy release as the CI, resolving its requirements with conda:

```bash
planemo test --galaxy_branch release_26.0 \
    --conda_dependency_resolution --conda_prefix ~/.planemo/conda --conda_auto_init --conda_auto_install \
    tools-metabolomics/tools/physiofit_manager
```

The first run downloads Galaxy and builds its environment, which takes several minutes. Tool environments are created under `~/.planemo/conda`, so neither your own conda installation nor the local Galaxy in `galaxy/` is modified. Results are written to `tool_test_output.html` and `tool_test_output.json` in the current directory.

# My Resume

This is the repo for my resume -- it's written using LaTeX, and built using github actions.

You can find the most recent build of my resume [here](https://github.com/znd4/personal_resume/releases/tag/latest).

## Building locally

The build is wired up through Nix; all TeX dependencies (tectonic + Liberation Sans) are pinned in `flake.nix`. With [Nix](https://nixos.org/download) installed:

```sh
nix run .#build    # one-shot build -> main.pdf
nix run .#watch    # rebuild on changes to main.tex / resume_config.cls
nix develop        # drop into a shell with tectonic + build/watch on $PATH
```

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

## Rotating the release token

The `release_pdf` job uses a fine-grained PAT stored as `GH_TOKEN` in the `main` environment (the job has `environment: main`, so env-scoped secrets shadow repo-scoped ones) (the built-in `GITHUB_TOKEN` could replace it, but this repo uses a PAT). Only required scope: **Contents: Read and write** on `znd4/personal_resume`.

1. Generate a new token — open this URL in a browser (fine-grained PAT creation isn't in the `gh` CLI):

   <https://github.com/settings/personal-access-tokens/new?name=personal_resume%20release&contents=write>

   This pre-fills the name and Contents=Read+Write. Still need to set manually:
   - **Resource owner**: `znd4`
   - **Repository access** → **Only select repositories** → `znd4/personal_resume`

   Copy the generated token to your clipboard.

2. Replace the secret and re-run the most recent failed release job:

   ```sh
   pbpaste | gh secret set GH_TOKEN --repo znd4/personal_resume --env main
   gh run list --repo znd4/personal_resume --workflow build-resume.yml --status failure --limit 1 \
     --json databaseId --jq '.[0].databaseId' \
     | xargs -I{} gh run rerun {} --repo znd4/personal_resume --failed
   ```

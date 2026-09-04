{
  description = "Personal resume build environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        fontDir = "${pkgs.liberation_ttf}/share/fonts/truetype";

        # Wraps `tectonic main.tex` to inject the Liberation font path so the
        # .cls can load it via `Path=` instead of relying on system font lookup
        # (which fails on macOS because tectonic uses CoreText there).
        #
        # The page check runs after main.pdf is in place, on purpose: a build
        # that overflows should still leave a PDF you can open to see what
        # spilled onto page 2.
        build = pkgs.writeShellApplication {
          name = "build";
          runtimeInputs = [ pkgs.tectonic pkgs.poppler_utils ];
          text = ''
            cd "''${RESUME_DIR:-$PWD}"
            { printf '\\def\\LiberationFontPath{%s/}\\input{main.tex}' "${fontDir}"; } \
              | tectonic - --outdir . "$@"
            mv ./texput.pdf ./main.pdf

            max_pages="''${RESUME_MAX_PAGES:-1}"
            pages="$(pdfinfo ./main.pdf | awk '/^Pages:/ { print $2 }')"
            if [ "$pages" -gt "$max_pages" ]; then
              echo "build: main.pdf is $pages pages, limit is $max_pages." >&2
              echo "build: cut content, or raise RESUME_MAX_PAGES." >&2
              exit 1
            fi
            echo "build: main.pdf written, $pages of $max_pages page(s) used."
          '';
        };

        watch = pkgs.writeShellApplication {
          name = "watch";
          runtimeInputs = [ pkgs.entr build ];
          text = ''
            cd "''${RESUME_DIR:-$PWD}"
            printf '%s\n' main.tex resume_config.cls | entr -c build
          '';
        };
      in
      {
        packages = {
          inherit build watch;
          default = build;
        };

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.tectonic pkgs.entr build watch ];
          LIBERATION_FONT_PATH = fontDir;
        };
      });
}

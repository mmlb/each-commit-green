{pkgs, ...}: {
  packages = with pkgs; [
    alejandra
  ];

  devcontainer.enable = true;
  difftastic.enable = true;

  languages.go.enable = true;
  languages.nix.enable = true;

  pre-commit.hooks = {
    alejandra.enable = true;
    prettier.enable = true;
    shfmt.enable = true;
    shellcheck.enable = true;
    gofumpt = {
      enable = true;
      name = "gofumpt";
      entry = "${pkgs.gofumpt}/bin/gofumpt";
      files = "go\\.(mod|sum)$";
      types = ["go"];
      language = "golang";
      pass_filenames = false;
    };
  };
}

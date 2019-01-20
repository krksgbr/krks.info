let
  # pin nixpkgs to a specific commit for ultimate reproducibility
  pkgs = import (builtins.fetchGit {
       name = "nixpkgs-pinned-2018-01-18";
       url = "https://github.com/NixOS/nixpkgs.git";
       ref = "master";
       rev = "eaa665e2435ab3dfc356d9799ba5938aabcd75d8";
  }){};


  # the generator
  generator = pkgs.haskellPackages.callPackage ./generator.nix {};


  # to deploy the site to netlify
  netlify-cli = (import ./netlify-cli/default.nix { inherit pkgs; }).netlify-cli;

  # other things we need to get stuff done
  extraBuildInputs = with pkgs; [
    imagemagick   # used for image manipulation by prepare-images.sh
    netlify-cli   # used for deploying our site
    cabal-install # project-specific cabal
  ];

  # script for image resizing
  prepareImages = ./prepare-images.sh;


  getEnvOrThrow = varName:
    let var = builtins.getEnv varName;
    in
      if var == ""
        then
          throw "${varName} not found in your environment."
        else
          var;

  # extend the environment of generator
  # used by nix-shell
  shell =
    let
      # netlify secrets
      NETLIFY_AUTH_TOKEN = getEnvOrThrow "NETLIFY_AUTH_TOKEN";
      NETLIFY_SITE_ID = getEnvOrThrow "NETLIFY_SITE_ID";
    in
    generator.env.overrideAttrs (oldAttrs: {
       buildInputs = oldAttrs.buildInputs ++ extraBuildInputs;
       shellHook = ''
       set -o vi
       export NETLIFY_AUTH_TOKEN=${NETLIFY_AUTH_TOKEN}
       export NETLIFY_SITE_ID=${NETLIFY_SITE_ID}
       alias prepareImages=${prepareImages}
       alias site='cabal run generator'
       alias watch='site watch'
       alias build='site build'
       alias rebuild='site rebuild'
       alias deploy='netlify deploy --prod --dir=_site'
       '';
    });

in
 # it doesn't make much sense to make this derivation,
 # because the site will probably always be built and deployed inside nix-shell
 # but keeping this here for future reference
 pkgs.stdenv.mkDerivation {
 name = "krks-info";
   inherit shell;
   inherit prepareImages;
   buildInputs = extraBuildInputs ++ [generator];
   src = ./content;
   phases = ["buildPhase"];
   buildPhase = ''
     # without this LOCALE stuff, generator would throw a runtime exception:
     # commitBuffer: invalid argument (invalid character)
     export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive";
     export LANG=en_US.UTF-8

     IN=$src OUT=$out generator build
   '';
 }

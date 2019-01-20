{ mkDerivation, base, filepath, hakyll, stdenv }:
mkDerivation {
  pname = "krks-info-generator";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base filepath hakyll ];
  license = stdenv.lib.licenses.bsd3;
}

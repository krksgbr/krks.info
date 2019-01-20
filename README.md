### [https://krks.info](https://krks.info)
My personal webpage made with nix and hakyll.

### Development
A development environment is provided through `nix-shell`.

Things made available in the development environment:
- ghc
- cabal
- hakyll
- netlify-cli
- a script to resize images
- some aliases to interact with hakyll

#### Special commands available in nix-shell

`prepareImages`
process images found at `content/raw-images`. save different sizes (for
`src-set`) to `content/images`

`watch`
Recompile when sources change and run development server

`build`
Build the site

`rebuild`
Remove `_cache` and `_site` and build site

`deploy`
Deploy site to netlify

#### Netlify secrets
The following netlify-specific variables need to be exported
before invoking nix-shell
- `NETLIFY_AUTH_TOKEN` (can be obtained [here](https://app.netlify.com/account/applications))
- `NETLIFY_SITE_ID` (can be found [here](https://app.netlify.com/sites/krks-info/settings/general#site-details))

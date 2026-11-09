{...}: let
  # Studio Ghibli inspired palette: forest greens, sky blues and warm sunset tones
  theme = {
    base00 = "#263a2e"; # bg - deep forest green (Totoro woods at dusk)
    base01 = "#33493d"; # dark moss
    base02 = "#44604f"; # moss green
    base03 = "#5c7a63"; # muted sage
    base04 = "#9fae8a"; # soft sage / khaki
    base05 = "#d8c9a3"; # warm sand
    base06 = "#eee3c8"; # fg - cream
    base07 = "#f7ecd0"; # light fg - parchment
    base08 = "#d1684e"; # terracotta red (rooftops, Calcifer embers)
    base09 = "#e0984f"; # warm amber (sunset, lanterns)
    base0A = "#e8c468"; # golden yellow (wheat fields)
    base0B = "#8aab6b"; # grass green (Totoro)
    base0C = "#6fb5ad"; # soft teal (Ponyo's sea)
    base0D = "#6d93b8"; # sky blue (Castle in the Sky)
    base0E = "#c98ea3"; # dusty pink (sakura, dusk sky)
    base0F = "#a9693f"; # earthy brown (tree trunk)
  };

  stripHash = str:
    if builtins.substring 0 1 str == "#"
    then builtins.substring 1 (builtins.stringLength str - 1) str
    else str;

  themeNoHash = builtins.mapAttrs (_: v: stripHash v) theme;
in {
  flake = {
    inherit theme themeNoHash;
  };
}

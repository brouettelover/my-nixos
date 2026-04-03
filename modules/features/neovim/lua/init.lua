require("opts")
require("filetype")
require("keymap")

vim.api.nvim_create_user_command('NixTemp', function()
    -- Récupère le nom du fichier sans l'extension
    local name = vim.fn.expand('%:t:r')
    
    local lines = {
        "{ inputs, self, ... }:",
        "",
        "{",
        "  # 1. LE PLAN (Ton module de configuration)",
        "  flake.wrapperModules." .. name .. " = { pkgs, ... }: {",
        "    # On définit ce que ce module doit produire",
        "    options." .. name .. ".package = pkgs.lib.mkOption {",
        "      type = pkgs.lib.types.package;",
        "    };",
        "",
        "    config." .. name .. ".package = pkgs.symlinkJoin {",
        "      name = \"" .. name .. "-tools\";",
        "      paths = [",
        "        ", -- Ligne 14 : Le curseur sera ici
        "      ];",
        "    };",
        "  };",
        "",
        "  # 2. L'USINE (Construction du paquet pour chaque système)",
        "  perSystem = { pkgs, ... }: {",
        "    packages." .. name .. " = (pkgs.lib.evalModules {",
        "      modules = [",
        "        self.wrapperModules." .. name,
        "        { _module.args.pkgs = pkgs; }",
        "      ];",
        "    }).config." .. name .. ".package;",
        "  };",
        "",
        "  # 3. LA LIVRAISON (Installation sur NixOS)",
        "  flake.nixosModules." .. name .. " = { pkgs, ... }: {",
        "    environment.systemPackages = [",
        "      self.packages.${pkgs.stdenv.hostPlatform.system}." .. name,
        "    ];",
        "  };",
        "}",
    }

    -- Remplit le fichier
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    
    -- Place le curseur à la ligne 14 (dans les crochets de 'paths')
    vim.api.nvim_win_set_cursor(0, {14, 8})
    
    -- Mode insertion automatique
    vim.cmd("startinsert!")
end, {})

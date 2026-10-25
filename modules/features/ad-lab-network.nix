{ self, ... }: {
  flake.nixosModules.ad_lab_network = { pkgs, ... }: {
    # Bridge isolé pour le lab AD : pas d'interface physique attachée,
    # seules les VMs quickemu (network="adlabbr0") et l'hôte s'y trouvent.
    networking.bridges.adlabbr0.interfaces = [ ];
    networking.interfaces.adlabbr0.ipv4.addresses = [
      { address = "10.10.10.1"; prefixLength = 24; }
    ];
    networking.firewall.trustedInterfaces = [ "adlabbr0" ];

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    # On active libvirtd uniquement pour obtenir le wrapper setuid
    # qemu-bridge-helper + /etc/qemu/bridge.conf : les VMs restent
    # gérées par quickemu, pas par libvirt.
    virtualisation.libvirtd.enable = true;
    virtualisation.libvirtd.allowedBridges = [ "virbr0" "adlabbr0" ];

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "adlab-internet-on" ''
        set -e
        WAN_IF="enp7s0f3u1u3c2"
        BR_IF="adlabbr0"
        SUBNET="10.10.10.0/24"
        IPT="${pkgs.iptables}/bin/iptables"
        sudo "$IPT" -t nat -C POSTROUTING -s "$SUBNET" -o "$WAN_IF" -j MASQUERADE 2>/dev/null \
          || sudo "$IPT" -t nat -I POSTROUTING -s "$SUBNET" -o "$WAN_IF" -j MASQUERADE
        sudo "$IPT" -C FORWARD -i "$BR_IF" -o "$WAN_IF" -j ACCEPT 2>/dev/null \
          || sudo "$IPT" -I FORWARD -i "$BR_IF" -o "$WAN_IF" -j ACCEPT
        sudo "$IPT" -C FORWARD -i "$WAN_IF" -o "$BR_IF" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null \
          || sudo "$IPT" -I FORWARD -i "$WAN_IF" -o "$BR_IF" -m state --state RELATED,ESTABLISHED -j ACCEPT
        echo "Internet ON pour le lab AD (adlabbr0 -> $WAN_IF)"
      '')
      (pkgs.writeShellScriptBin "adlab-internet-off" ''
        set -e
        WAN_IF="enp7s0f3u1u3c2"
        BR_IF="adlabbr0"
        SUBNET="10.10.10.0/24"
        IPT="${pkgs.iptables}/bin/iptables"
        sudo "$IPT" -t nat -D POSTROUTING -s "$SUBNET" -o "$WAN_IF" -j MASQUERADE 2>/dev/null || true
        sudo "$IPT" -D FORWARD -i "$BR_IF" -o "$WAN_IF" -j ACCEPT 2>/dev/null || true
        sudo "$IPT" -D FORWARD -i "$WAN_IF" -o "$BR_IF" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
        echo "Internet OFF pour le lab AD (adlabbr0 isolé)"
      '')
    ];
  };
}

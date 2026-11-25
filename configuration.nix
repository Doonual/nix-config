# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
	home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz;
in
{
	# Include the results of the hardware scan.
	imports = [
		./hardware-configuration.nix
		"${home-manager}/nixos"
	];
	
	# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	
	boot.kernelPackages = pkgs.linuxPackages_latest;# Use latest kernel.
	
	
	
	
	
	##################
	### Networking ###
	##################
	networking.hostName = "north"; # Define your hostname.
	networking.networkmanager.enable = true; # Configure network connections interactively with nmcli or nmtui.
	
	
	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
	
	
	# Select internationalisation properties.
	# i18n.defaultLocale = "en_US.UTF-8";
	# console = {
		#   font = "Lat2-Terminus16";
		#   keyMap = "us";
		#   useXkbConfig = true; # use xkb.options in tty.
	# };
	
	# Enable the X11 windowing system.
	# services.xserver.enable = true;
	
	
	# Set your time zone.
	time.timeZone = "Australia/Perth";
	
	
	# Configure keymap in X11
	services.xserver.xkb.layout = "us";
	# services.xserver.xkb.options = "eurosign:e,caps:escape";
	
	# Enable Plasma
	services = {
		desktopManager.plasma6.enable = true;
		
		# Default display manager for Plasma
		displayManager.plasma-login-manager.enable = true;
	};
	
	
	# Enable CUPS to print documents.
	# services.printing.enable = true;
	
	# Enable sound.
	# services.pulseaudio.enable = true;
	# OR
	# services.pipewire = {
		#   enable = true;
		#   pulse.enable = true;
	# };
	
	# Enable touchpad support (enabled default in most desktopManager).
	# services.libinput.enable = true;
	
	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.daniel = {
		isNormalUser = true;
		extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
		# packages = with pkgs; [
			#  tree systemd neovim git fastfetch
		#];
		shell = pkgs.bash;
		home = "/home/daniel";
	};
	
	
	
	home-manager.users.daniel = { pkgs, prev, config, ...}:
	let
		
		nixd-custom = pkgs.nixd.overrideAttrs (old: {
			postPatch = (old.postPatch or "") + ''
			sed -i 's/MaxCompletionSize = 30/MaxCompletionSize = 1000/' \
			$(find . -path '*Controller/Completion.cpp')
			sed -i 's/MaxItems = 30/MaxItems = 1000/' \
			$(find . -path '*Eval/AttrSetProvider.cpp')
			'';
		});
		
		discord = (pkgs.discord.override {
			commandLineArgs = [
				"--ozone-platform-hint=auto"
				# fallback if it's still the wrong size:
				"--force-device-scale-factor=1.0"
			];
		});
		
		
		
		
	in
	{
		
		
		nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
			"discord"
			"steam"
			"steam-unwrapped"
		];
		
		
		
		home.packages = with pkgs; [
			btop
			atool 
			httpie 
			cargo 
			neovim 
			git 
			fastfetch 
			systemd 
			tree
			nodejs_22
			nixd-custom
			nil
			pnpm
			typescript
			discord
			steam
			lazygit
		];
		
		
		
		programs.bash.enable = true;
		
		# programs.git.includes = [{ path = "./git-config"; }];
		# xdg.configFile."git/config".source = "./git-config";

		# To get git credentials working with GitHub, copy your public ssh key into GitHub
		# You can generate this key with
		# ssh-keygen -t ed25519- C "you@example.com"

		xdg.configFile."git/config".source = ./git-config;
		
		
		
		programs.ssh = {
			enableDefaultConfig = false;
			settings."*".enable = true;
			settings."*".addKeysToAgent = "yes";
		};
		
		
		# xdg.configFile."git/config".source = config.lib.file.mkOutOfStoreSymlink ./git-config;
		# programs.git.extraConfig.credential.helper = "libsecret";  # stores in KDE Wallet / GNOME Keyring
		
		xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/nvim;
		
		home.stateVersion = "26.05";
	};
	
	
	programs.firefox.enable = true;
	
	# List packages installed in system profile.
	# You can use https://search.nixos.org/ to find more packages (and options).
	# environment.systemPackages = with pkgs; [
		#   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		#   wget
		# ];
		
		# Some programs need SUID wrappers, can be configured further or are
		# started in user sessions.
		# programs.mtr.enable = true;
		# programs.gnupg.agent = {
			#   enable = true;
			#   enableSSHSupport = true;
		# };
		
		# List services that you want to enable:
		
		# Enable the OpenSSH daemon.
		# services.openssh.enable = true;
		
		# Open ports in the firewall.
		# networking.firewall.allowedTCPPorts = [ ... ];
		# networking.firewall.allowedUDPPorts = [ ... ];
		# Or disable the firewall altogether.
		# networking.firewall.enable = false;
		
		# Copy the NixOS configuration file and link it from the resulting system
		# (/run/current-system/configuration.nix). This is useful in case you
		# accidentally delete configuration.nix.
		# system.copySystemConfiguration = true;
		
		# This option defines the first version of NixOS you have installed on this particular machine,
		# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
		#
		# Most users should NEVER change this value after the initial install, for any reason,
		# even if you've upgraded your system to a new NixOS release.
		#
		# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
		# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
		# to actually do that.
		#
		# This value being lower than the current NixOS release does NOT mean your system is
		# out of date, out of support, or vulnerable.
		#
		# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
		# and migrated your data accordingly.
		#
		# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
		system.stateVersion = "26.05"; # Did you read the comment?
		
		
	}
	
	

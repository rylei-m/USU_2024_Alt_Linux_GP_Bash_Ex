#!/bin/bash

# Determine command type
cmd_type="ui"
if [ $# -gt 0 ]; then
    case $1 in
        --cli-only)
            cmd_type="cli-only";;
        --arm)
            cmd_type="arm";;
        --help)
	    ;&
        *)
            cmd_type="usage";;
    esac
fi

# Determine Linux Distro and Version
. /etc/os-release

if [ $ID == "ubuntu" ]; then
    linux_ver=${VERSION_ID:0:2}
elif [[ $ID == "rhel" || $ID == "centos" || $ID == "fedora" ]]; then
    linux_ver=${VERSION_ID:0:1}
fi

# Install resolvconf on Ubuntu only
if [ $ID == "ubuntu" ]; then
    sudo apt-get install -y resolvconf > /dev/null
fi

case $cmd_type in
    cli-only)
        # CLI Only Install
        case $ID in
            ubuntu)
                case $linux_ver in
                    14)
                        ;&
                    16)
                        ;&
                    18)
                        sudo -E apt-get install -y ./GlobalProtect_deb-*.deb;;
                     *)
                        sudo -E apt-get install -y ./GlobalProtect_focal_deb-*.deb;;
	        esac
                ;;
            rhel)
                ;&
            fedora)
                ;&
            centos)
                # Check if old GP package installed
                yum_output=$(yum list installed | grep globalprotect)
                if [[ $yum_output == *"globalprotect.x86"* ]]; then
                    echo "Older globalprotect detected...uninstalling..."
                    sudo yum -y remove globalprotect
                fi

                case $linux_ver in
                    7)
                        sudo -E yum -y install ./GlobalProtect_rpm-*;;
		    *)
                        sudo -E yum -y install ./GlobalProtect_focal_rpm-*;;
                esac
	        ;;
            *)
                echo "Error: Unsupported Linux Distro: $ID"
	        exit
                ;;
        esac
        ;;

    arm)
        # ARM Install
        case $ID in
            ubuntu)
                case $linux_ver in
                    14)
                        ;&
                    16)
                        ;&
                    18)
                        sudo -E apt-get install -y ./GlobalProtect_deb_arm*.deb;;
		    *)
                        sudo -E apt-get install -y ./GlobalProtect_focal_deb_arm*.deb;;
	        esac
                ;;
            rhel)
                ;&
            fedora)
                ;&
            centos)
                # Check if old GP package installed
                yum_output=$(yum list installed | grep globalprotect)
                if [[ $yum_output == *"globalprotect_arm.x86"* ]]; then
                    echo "Older globalprotect detected...uninstalling..."
                    sudo yum -y remove globalprotect_arm
                fi

                case $linux_ver in
                    7)
                        sudo -E yum -y install ./GlobalProtect_rpm_arm*;;
		    *)
                        sudo -E yum -y install ./GlobalProtect_focal_rpm_arm*;;
	            esac
	            ;;
            *)
                echo "Error: Unsupported Linux Distro: $ID"
	        exit
                ;;
        esac
        ;;

    ui)
        # UI Install
        case $ID in
            ubuntu)
                case $linux_ver in
                    14)
                        ;&
                    16)
                        ;&
                    18)
                        sudo -E apt-get install -y ./GlobalProtect_UI_deb*.deb;;
		    20)
                        sudo apt-get install -y gnome-tweak-tool gnome-shell-extension-top-icons-plus
                        gnome-extensions enable TopIcons@phocean.net
                        sudo -E apt-get install -y ./GlobalProtect_UI_focal_deb*.deb
                        ;;
		    22)
                        sudo apt-get install -y gnome-shell-extension-manager gnome-shell-extension-appindicator
                        sudo -E apt-get install -y ./GlobalProtect_UI_focal_deb*.deb
			;;
		    *)
                        sudo -E apt-get install -y ./GlobalProtect_UI_focal_deb*.deb;;
	        esac
                ;;
            rhel)
                ;&
            fedora)
                ;&
            centos)
                # Check if old GP package installed
                yum_output=$(yum list installed | grep globalprotect)
                if [[ $yum_output == *"globalprotect_UI.x86"* ]]; then
                    echo "Older globalprotect detected...uninstalling..."
                    sudo yum -y remove globalprotect_UI
                fi

                # RHEL Package Dependencies
                if [ "$ID" = "centos" ]; then
                    sudo yum -y install epel-release
                elif [ "$ID" = "rhel" ]; then
                    if [ "$linux_ver" = "7" ]; then
                        sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
                    elif [ "$linux_ver" = "8" ]; then
                        sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
                    elif [ "$linux_ver" = "9" ]; then
                        sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
                    else
                        echo "Error: Unsupported RHEL version: $linux_ver"
			exit
                    fi
                fi

                sudo yum -y install qt5-qtwebkit wmctrl

		# Gnome Shell Extensions Install
                if [ "$ID" = "rhel" ]; then
                    if [ "$linux_ver" = "8" ]; then
                        sudo yum -y install gnome-shell-extension-topicons-plus gnome-tweaks
                        gnome-shell-extension-tool -e TopIcons@phocean.net
                    elif [ "$linux_ver" = "9" ]; then
                        sudo yum -y install gnome-shell-extension-top-icons
                        gnome-extensions enable top-icons@gnome-shell-extensions.gcampax.github.com
                    fi
                elif [ "$ID" = "fedora" ]; then
                    sudo yum -y install gnome-shell-extension-appindicator gnome-tweaks
                    gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
                fi

                # Install
                case $linux_ver in
                    7)
                        sudo -E yum -y install ./GlobalProtect_UI_rpm-*
                        ;;
		    *)
                        sudo -E yum -y install ./GlobalProtect_UI_focal_rpm-*;;
	        esac
                ;;
            *)
                echo "Error: Unsupported Linux Distro: $ID";;
        esac
        ;;
    usage)
        ;&
    *)
        echo "Usage: $ ./gp_install [--cli-only | --arm | --help]"
        echo "  --cli-only: CLI Only"
        echo "  --arm:      ARM"
        echo "  default:    UI"
        echo " "
        echo "Note: Install script will need superuser access"
        ;;
esac

###############
##### TBD #####
###############
#if [[ $XDG_SESSION_TYPE == "wayland" ]]
#then
#    read -p "Do you want to switch from Wayland to X11? " -n 1 -r
#    echo
#    if [[ $REPLY =~ ^[Yy]$ ]]
#        then
#        # Wayland to X11
#        if [[ $ID == "ubuntu" ]]
#	then
#             sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false\nDefaultSession=gnome-xorg.desktop/' /etc/gdm3/custom.conf
#	else
#             sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false\nDefaultSession=gnome-xorg.desktop/' /etc/gdm/custom.conf
#        fi
#	echo "Please reboot to use X11 Window Manager."
#    fi
#fi

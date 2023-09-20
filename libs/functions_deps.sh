function buscar_distro () {
    grep ^ID= /etc/os-release | cut -d = -f 2
}
function install_sshpass () {
    case "$(buscar_distro)" in
        ubuntu) sudo apt-get install -y sshpass
        ;;
        debian) sudo apt-get install -y sshpass
        ;;
        fedora) yum install -y sshpass
        ;;
        ol) sudo yum install -y sshpass
        ;;
    esac
}
function _buscar_distro () {
    grep ^ID= /etc/os-release | cut -d = -f 2
}
function _install_sshpass () {
    case "$(_buscar_distro)" in
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
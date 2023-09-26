function _find_distribution () {
    #Maior parte das distros.
    if [ -f /etc/os-release ]; then
        grep ^ID= /etc/os-release | cut -d = -f 2
    else #RedHat...
        if [ -f /etc/redhat-release ]; then
            echo "rhel"
        else
            echo "other"
        fi
    fi
}

function _deps () {
    echo -e "\nPrecisamos configurar/instalar as dependências: \n"
}

function _error_deps () {
    echo -e "\nO programa não conseguiu instalar o sshpass, instale-o manualmente.\n" && exit 1
}

function _post_deps () {
    echo -e "\nDependências instaladas, execute novamente o programa." && exit 0
}

function _install_sshpass () {
    case "$(_find_distribution)" in
        ubuntu) _deps && sudo apt-get install -y sshpass && _post_deps || _error_deps
        ;;
        debian) _deps && sudo apt-get install -y sshpass && _post_deps || _error_deps
        ;;
        fedora) _deps && sudo yum install -y sshpass && _post_deps || _error_deps
        ;;
        ol) _deps && sudo yum install -y sshpass && _post_deps || _error_deps
        ;;
        rhel) _deps && sudo yum install -y sshpass && _post_deps || _error_deps
        ;;
        other) _error_deps
    esac
}
#!/usr/bin/env bash
#
# cachos_infracloud.sh - Automação de troubleshooting em cachOS.
#
# Autor:      Mateus Lippi
# Manutenção: Mateus Lippi
# ------------------------------------------------------------------------ #
#  Estre programa gera um relatório com as prnicipais estatísticas que
#  precisamos para uma análise de erro 50x em cachOS.  
#
# Exemplos:
#   $ ./cachos_infracloud --relatorio - Iniciará a solicitação de informações para
#       gerar o relatório .txt.
# ------------------------------------------------------------------------ #
# Testado em:
#   bash 5.1.16(1)-release
# ------------------------------------------------------------------------ #
# Histórico:
#    v1.0 07/09/2023, Mateus: Preparado para produção.
# ------------------------------------------------------------------------ #
# -----------------------VARIÁVEIS ---------------------------------------- #
SCRIPT_DIR="$( cd "$( dirname "$(readlink -f $"0")" )" && pwd )"
PROJECT_DIR="($basename "$SCRIPT_DIR")"
LIBS_DIR="$PROJECT_DIR/libs"
# -----------------------IMPORTS ---------------------------------------- #
source "$LIBS_DIR/functions_deps.sh"
source "$LIBS_DIR/functions_main.sh"
# ------------------------------- TESTES ---------------------------------- #
[ -z "$(which sshpass)" ] && _install_sshpass
# ------------------------------- FUNÇÕES --------------------------------- #
function trapped () {
    echo "Erro na linha $1."
    exit 1
}
trap 'trapped $LINENO' ERR
# ------------------------------- EXECUÇÃO --------------------------------- #
case "$1" in
    -h|--help)       _help                   ;;
    -r|--relatorio)  _run                    ;;
    *)               _error_parameter "$1"   ::
esac

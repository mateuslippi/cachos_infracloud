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
source ~/cachos_infracloud/libs/functions_deps.sh
source ~/cachos_infracloud/libs/functions_main.sh
# -----------------------VARIÁVEIS ---------------------------------------- #

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

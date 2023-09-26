#Basico
function _help () {
    echo "
    $(basename "$0") - [OPÇÕES]

        -h, --help - Menu de ajuda
        -r, --relatorio - Gera o relatório de troubleshooting do cachos

        Como usar: Basta executar o programa com o parâmetro \"-r\" e preencher a solicitação
        de hostname(Completo) e senha do cachOS. Desta forma, se não houver erros,
        o relatório deverá ser gravado no diretório $(pwd) em um arquivo.txt com a data atual e nome do host cachos. 
"
    exit 0
}

function _error () {
    echo -e "$1"
    exit 1
}

function _error_parameter () {
    echo "O parâmetro $1 não existe."
    _help
    exit 1
}

function _color_red () {
    echo -e "\e[35;1m"
}

function _color_end () {
    echo -e "\e[0m"
}

#Obtendo informações
function _varnish_service_status () {
    systemctl status varnish | head -n5
}

function _varnish_ncsa_logs () {
    systemctl is-active --quiet varnishncsa.service
    if [ $? -eq 0 ];then
        awk '{print $9"\t"$4"\t"$7}' /opt/logs/cachos/default_log | tr -d [ | grep -v -e '^[[:space:]]*$' | head -n25
    else
        systemctl restart varnishncsa.service
        if [ $? -eq 0 ];then
            echo "O serviço \"varnishncsa.service\" não estava ativo!! Portanto, o Varnish não estava gravando os logs em \"/opt/logs/cachos/default_log\".
                    Foi reiniciado com sucesso pela automação.
                
                logs com filtro: $(awk '{print $9"\t"$4"\t"$7}' /opt/logs/cachos/default_log | tr -d [ | grep -v -e '^[[:space:]]*$' | head -n25)"
        else
            _error "Houve um problema ao tentar reiniciar o serviço \"varnishncsa.service.\"Iniciar manualmente."
        fi
    fi
}

function _varnish_backend_fail () {
    varnishstat -1 | grep -i backend_fail
}

function _varnish_backend_list () {
    varnishadm backend.list
}

function _nginx_logs () {
    echo -e "\nIPS ofensores:\n"
    awk '{print "IP: " $3}' /opt/cachos/nginx-thanos/logs/cachos-thanos_access.log | sort | uniq -c | sort -nr | head -n 10
    echo -e "\nURL das homes com erro 50x:\n"
    awk '$12 ~ /^50/ {print $5}' /opt/cachos/nginx-thanos/logs/cachos-thanos_access.log | sort | uniq -c | sort -nr | head -n 10
    echo -e "\nURI das homes com erro 50x:\n"
    awk '$12 ~ /^50/ {print $9}' /opt/cachos/nginx-thanos/logs/cachos-thanos_access.log | sort | uniq -c | sort -nr | head -n 10
}

#Validações
function _host_icmp_test () {
    ping -c 1 $HOST_CACHOS > /dev/null 2>&1
    [ $? -ne 0 ] && _error "\n\n Host $HOST_CACHOS desconhecido/não alcançável. Investigar a causa."
}

function _host_ssh_test () {
    nc -z -w 5 $HOST_CACHOS 22 > /dev/null 2>&1
    [ $? -ne 0 ] && _error "\n\nNão foi possível estabelecer conexão com o host $HOST_CACHOS pela porta 22 (SSH). Investigar a causa."
}

function _host_ssh_know () {
    ssh-keyscan -p 22 $HOST_CACHOS >> ~/.ssh/known_hosts 2> /dev/null
    [ $? -ne 0 ] && _error "\nHouve um erro ao scanear o host $HOST_CACHOS. Por favor, tente acessá-lo manualmente e executar o script após isso."
}

#Montagem do relatório
function _estruture () {
    color_red_output="$(_color_red)"
    color_end_output="$(_color_end)"
    varnish_service_status_output="$(_varnish_service_status)"
    varnish_backend_fail_output="$(_varnish_backend_fail)"
    varnish_backend_list_output="$(_varnish_backend_list)"
    varnish_ncsa_logs_output="$(_varnish_ncsa_logs)"
    nginx_logs_output="$(_nginx_logs)"
    
    echo "
    $color_red_output------------------------------------------------------------------------  SERVIÇO DO VARNISH  ------------------------------------------------------------------------$color_end_output
            
                $varnish_service_status_output
        
    $color_red_output------------------------------------------------------------------------ VARNISHSTAT BACKEND FAIL --------------------------------------------------------------------$color_end_output

                $varnish_backend_fail_output

    $color_red_output------------------------------------------------------------------------ VARNISHSTAT BACKEND LIST --------------------------------------------------------------------$color_end_output

                $varnish_backend_list_output

    $color_red_output------------------------------------------------------------------------     VARNISH LOGS    -------------------------------------------------------------------------$color_end_output

                $varnish_ncsa_logs_output

    $color_red_output------------------------------------------------------------------------      NGINX LOGS    --------------------------------------------------------------------------$color_end_output

                $nginx_logs_output
                "
}

#Run
function _run () {
read -p "Digite o nome do host cachOS: " HOST_CACHOS
read -s -p "Digite a senha do host cachOS: " SENHA_CACHOS

if [[ "$HOST_CACHOS" == *".globoi.com" ]]; then
    local host_cachos_completo="$HOST_CACHOS"
else
    host_cachos_completo="$HOST_CACHOS.globoi.com"
fi

local host_log=$(echo $HOST_CACHOS | cut -d . -f 1)
local host_log_date="$host_log-$(date "+%Y-%m-%d_%H:%M:%S").txt"

_host_icmp_test
_host_ssh_test
_host_ssh_know

sshpass -p "$SENHA_CACHOS" ssh root@"$HOST_CACHOS" 'bash -s' << EOF > $HOME/cachos_infracloud/logs/$host_log_date
$(declare -f _color_red)
$(declare -f _color_end)
$(declare -f _varnish_service_status)
$(declare -f _varnish_backend_fail)
$(declare -f _varnish_backend_list)
$(declare -f _varnish_ncsa_logs)
$(declare -f _nginx_logs)
$(declare -f _estruture)
_estruture
EOF

local arquivo_log="$HOME/cachos_infracloud/logs/$host_log_date"
echo -e "\n\nGerado o arquivo de log: $arquivo_log\n"
less $arquivo_log
}
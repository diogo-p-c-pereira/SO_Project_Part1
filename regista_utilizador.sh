#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº: 110976   Nome: Diogo Pedro Cordeiro Pereira
## Nome do Módulo: regista_utilizador.sh
## Descrição/Explicação do Módulo:
## Descrito em linhas de comentário
##
###############################################################################

##### 1.1.1 ###### 
if [ $# -lt 3 ]; then       #Verificacao do numero de argumentos
    ./error 1.1.1           #Nao pode ser nem menor que 3 nem maior que 4
    exit
elif [ $# -gt 4 ]; then
    ./error 1.1.1
    exit
else
    ./success 1.1.1
fi

###### 1.1.2 ####### Verifica se o Nome corresponde a um aluno da lista de alunos de SO
if [[ $(cat  /etc/passwd | grep "$1" | awk -F ':' '{print $5}' | sed 's/,,,//') == "$1" ]]; then  
    ./success 1.1.2
else
    ./error 1.1.2
    exit
fi

####### 1.1.3 ####### Verifica se o saldo é um numero valido
if [[ "$3" =~ ^[0-9]*$ ]]; then   
    ./success 1.1.3
else
    ./error 1.1.3
    exit
fi

####### 1.1.4 ####### Verifica se foi inserido NIF, e caso sim verifica se este é valido e tem 9 digitos
if [ -n "$4" ]; then  
    if [[ "$4" =~ ^[0-9]{9}*$ ]]; then
        ./success 1.1.4
    else
        ./error 1.1.4
        exit
    fi
fi

###### 1.2.1  #######  Verifica se o ficheiro utilizadores.txt existe
if [ -f utilizadores.txt ]; then    
    ./success 1.2.1
    #Prosseguir p/ 1.2.3
else
    ./error 1.2.1
    ####### 1.2.2 ####### Cria o ficheiro utilizadores.txt
    touch utilizadores.txt     
    if [[ "$?" = "0" ]]; then 
        ./success 1.2.2
    else
        ./error 1.2.2
        exit
    fi
fi

####### 1.2.3 ######## Verifica se o utilizador já está registado
if [[ "$(cat utilizadores.txt | awk -F ':' '{print $2}' | grep "$1")" = "$1" ]]; then    
    ./success 1.2.3
    ######### 1.3.1  ######### Corresponde a senha inserida com a do utilizador selecionado
    if [[ "$(cat utilizadores.txt | grep "$1" | awk -F ':' '{print $3}')" = "$2" ]]; then  
        ./success 1.3.1
        ######  1.3.2 #######    Incrementa o saldo a adicionar aos dados do utilizador
        saldo=$(expr $(cat utilizadores.txt | grep "$1" |  awk -F ':' '{print $6}') + $3)    # Calcular Saldo
        #copiar para utilizadores.txt
        awk -F ':' -v name="$1" -v saldo=$saldo 'BEGIN {OFS=":"} $2 == name {$NF = saldo} 1' utilizadores.txt > tmp && mv tmp utilizadores.txt
        if [[ "$?" = "0" ]]; then 
            ./success 1.3.2 $saldo
        else
            ./error 1.3.2
            exit
        fi
    else
        ./error 1.3.1
        exit
    fi
else
    ./error 1.2.3
    ####### 1.2.4 ####### Valida se foi inserido o NIF para o novo utilizador
    if [ -n "$4" ]; then  
        ./success 1.2.4 
        ###### 1.2.5 #######   Verifica se o ficheiro utilizadores.txt tem conteudo, caso não, começa a contar o ID apartir de 1, caso tenha calcula o ID do novo utilizador
        if [ -s utilizadores.txt ]; then   
            a=1;
            for (( i=1; i <= $(cat utilizadores.txt | wc -l); i++ ))
            do
                if (( $a < $(cat utilizadores.txt | awk -v i=$i -F ':' 'NR==i {print $1}') )); then
                    a=$(cat utilizadores.txt | awk -v i=$i -F ':' 'NR==i {print $1}')
                fi 
            done
            ID_utilizador=$(expr $a + 1 )    
            ./success 1.2.5 $ID_utilizador
        else
            ./error 1.2.5
            ID_utilizador=1
        fi
        ######### 1.2.6 ########### Gera o email do novo utilizador
        pNome=$(echo "$1" | awk -F ' ' '{print $1}' | tr '[:upper:]' '[:lower:]')     
        uNome=$(echo "$1" | rev | awk -F ' ' '{print $1}' | rev | tr '[:upper:]' '[:lower:]')
        [ $pNome = $uNome ] && [[ "$?" = "0" ]] && ./error 1.2.6 && exit
        email=$pNome.$uNome@kiosk-iul.pt
        ./success 1.2.6 $email
        ######### 1.2.7 ###########  Regista os dados todos do novo utilizador numa nova linha do ficheiro
        echo "$ID_utilizador:$1:$2:$email:$4:$3" >> utilizadores.txt
        if [[ "$?" = "0" ]]; then 
            ./success 1.2.7 "$ID_utilizador:$1:$2:$email:$4:$3"
        else
            ./error 1.2.7
            exit
        fi
        ###########################
    else
        ./error 1.2.4
        exit
    fi
fi

########### 1.4.1 ################
# Cria o ficheiro saldos-ordenados.txt em que lista os utilizadores e os seu saldos por ordem decresente
cat utilizadores.txt | awk -F ':' '{print $6, $0}' | sort -r -V | sed 's/^\S* //' > saldos-ordenados.txt
if [[ "$?" = "0" ]]; then 
    ./success 1.4.1
else
    ./error 1.4.1
    exit
fi
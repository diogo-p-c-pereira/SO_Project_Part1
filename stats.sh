#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº: 110976   Nome: Diogo Pedro Cordeiro Pereira
## Nome do Módulo: stats.sh
## Descrição/Explicação do Módulo: 
## Descrito em linhas de comentário
##
###############################################################################

######### 4.1.1  ##########
if [[ $# == 2 ]]; then 
    if [[ $1 == "popular" ]]; then  ### Lista os produtos mais populares -> 4.2.2
        ./success 4.1.1
        ##################### 4.2.2 #########################
        echo "" > stats.txt
        for (( i=1; i <= $(cat produtos.txt | wc -l); i++ )); do  
            nCompras=0
            for (( j=1; j <= $(cat relatorio_compras.txt | wc -l); j++ )); do
                if [[ "$(cat produtos.txt | awk -v i=$i -F ':' 'NR==i {print $1}')" == "$(cat relatorio_compras.txt | awk -v j=$j -F ':' 'NR==j {print $1}' )" ]]; then
                    nCompras=$(($nCompras + 1))
                fi
            done
            if [[ $nCompras == 1 ]]; then
                echo $nCompras":"$(cat produtos.txt | awk -v i=$i -F ':' 'NR==i {print $1}')": "$nCompras" compra" >> stats.txt
                if [[ "$?" != "0" ]]; then 
                    ./error 4.2.2
                     exit
                fi
            elif [[ $nCompras != 0 ]]; then
                echo $nCompras":"$(cat produtos.txt | awk -v i=$i -F ':' 'NR==i {print $1}')": "$nCompras" compras" >> stats.txt
                if [[ "$?" != "0" ]]; then 
                    ./error 4.2.2
                     exit
                fi
            fi
        done
        cat stats.txt | sort -r -V | awk -F ':' '{print $2":"$3}' > stats.txt.tmp && mv stats.txt.tmp stats.txt
        tac stats.txt | tail -n +2 | tac > stats.txt.tmp && mv stats.txt.tmp stats.txt
        tac stats.txt | head -n +$2 | tac > stats.txt.tmp && mv stats.txt.tmp stats.txt
        ./success 4.2.2
        #######################################################
    else
        ./error 4.1.1
        exit
    fi
elif [[ $# == 1 ]]; then
    if [[ $1 == "listar" ]]; then    ### Lista o nº de compras por utilizador, por ordem descrescente -> 4.2.1
        ./success 4.1.1
        ################### 4.2.1 ###################     
        echo "" > stats.txt
        for (( i=1; i <= $(cat utilizadores.txt | wc -l); i++ )); do  
            nCompras=0
            for (( j=1; j <= $(cat relatorio_compras.txt | wc -l); j++ )); do
                if [[ $(cat utilizadores.txt | awk -v i=$i -F ':' 'NR==i {print $1}') == $(cat relatorio_compras.txt | awk -v j=$j -F ':' 'NR==j {print $3}' ) ]]; then
                    nCompras=$(($nCompras + 1))
                fi
            done
            if [[ $nCompras == 1 ]]; then
                echo $nCompras":"$(cat utilizadores.txt | awk -v i=$i -F ':' 'NR==i {print $2}')": "$nCompras" compra" >> stats.txt
                if [[ "$?" != "0" ]]; then 
                    ./error 4.2.1
                     exit
                fi
            elif [[ $nCompras != 0 ]]; then
                echo $nCompras":"$(cat utilizadores.txt | awk -v i=$i -F ':' 'NR==i {print $2}')": "$nCompras" compras" >> stats.txt
                if [[ "$?" != "0" ]]; then 
                    ./error 4.2.1
                     exit
                fi
            fi
        done
        cat stats.txt | sort -r -V | awk -F ':' '{print $2":"$3}' > stats.txt.tmp && mv stats.txt.tmp stats.txt
        tac stats.txt | tail -n +2 | tac > stats.txt.tmp && mv stats.txt.tmp stats.txt
        ./success 4.2.1
        ##################################################
    elif [[ $1 == "histograma" ]]; then     ### Cria um histograma com o nº de vendas de cada categoria de produto -> 4.2.3
        ./success 4.1.1
        ##################### 4.2.3 #####################
        cat relatorio_compras.txt | awk -F ':' '!x[$2]++ {print $2}' > stats.txt
        if [[ "$?" != "0" ]]; then 
            ./error 4.2.2
            exit
        fi
        touch stats.tmp
        for (( i=1; i <= $(cat stats.txt | wc -l); i++ )); do
            nAsteriscos=0
            for (( j=1; j <= $(cat relatorio_compras.txt | wc -l); j++ )); do
                if [[ "$(cat stats.txt | awk -v i=$i -F ':' 'NR==i {print $1}')" == "$(cat relatorio_compras.txt | awk -v j=$j -F ':' 'NR==j {print $2}' )" ]]; then
                    nAsteriscos=$(expr $nAsteriscos + 1 )
                fi
            done
            echo "$(cat stats.txt | awk -v i=$i -F ':' 'NR==i {print $1}')"     "$(awk -v i=$i -v nA=$nAsteriscos 'BEGIN {for (i=1; i<=nA; i++) printf "*"; printf "\n"}')" >> stats.tmp
        done
        mv stats.tmp stats.txt
        ./success 4.2.3
        ############################################
    else
        ./error 4.1.1
        exit
    fi
else
    ./error 4.1.1
    exit
fi




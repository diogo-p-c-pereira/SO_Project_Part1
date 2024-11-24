#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº: 110976   Nome: Diogo Pedro Cordeiro Pereira
## Nome do Módulo: refill.sh
## Descrição/Explicação do Módulo: 
## Descrito em linhas de comentário
##
###############################################################################

################################ 3.1 #############################

###### 3.1.1 ######
[ -f "produtos.txt" ] && [ -f "reposicao.txt" ] && ./success 3.1.1 || { ./error 3.1.1; exit; }  # Verifica a existencia dos ficheiros produtos.txt e reposicao.txt

###### 3.1.2 ######
for (( i=1; i < $(cat reposicao.txt | wc -l); i++ )); do    #3.1.2  Verifica se o produto da resposicao.txt existe no produtos.txt e valida se o valor da reposicao é um numero
    if [[ $(cat reposicao.txt | awk -v i=$i -F ':' 'NR==i {print $1}') != $(cat produtos.txt | awk -v i=$i -F ':' 'NR==i {print $1}') ]]; then
        ./error 3.1.2 $(cat reposicao.txt | awk -v i=$i -F ':' 'NR==i {print $1}')
        exit
    fi
    if [[ $(cat reposicao.txt | awk -v i=$i -F ':' 'NR==i {print $3}') =~ ^[^0-9]*$ ]]; then
        ./error 3.1.2 $(cat reposicao.txt | awk -v i=$i -F ':' 'NR==i {print $1}')
        exit
    fi
done
./success 3.1.2

########################### 3.2 ####################################

######## 3.2.1 ############
date=$(date '+%Y-%m-%d')  #Cria o ficheiro produtos-em-falta.txt de acordo com o enunciado e calcula a diferenca entre o stock atual e o maximo para saber quantos produtos estão em falta 
echo "**** Produtos em falta em "$date" ****" > produtos-em-falta.txt   
if [[ "$?" != "0" ]]; then 
    ./error 3.2.1
    exit
fi
for (( i=1; i <= $(cat produtos.txt | wc -l); i++ )); do
    falta=$(expr $(cat produtos.txt | awk -v i=$i -F ':' 'NR==i {print $NF}') - $(cat produtos.txt | awk -v i=$i -F ':' 'NR==i {print $4}') )
    if [[ "$falta" != "0" ]]; then 
         echo $(cat produtos.txt | awk -v i=$i -F ':' 'NR==i {print $1}'): $falta unidades >> produtos-em-falta.txt
    fi
done
./success 3.2.1

######## 3.2.2 ###########
for (( i=1; i <= $(cat reposicao.txt | wc -l); i++ )); do  # Atualiza o stock dos produtos no ficheiro produtos.txt
    produto=$(cat reposicao.txt | awk -v i=$i -F ':' 'NR==i {print $1}')
    if [[ "$(cat produtos.txt | grep "$produto" | awk -F ':' '{print $1}')" == "$produto" ]]; then
        reposicao=$(($(cat reposicao.txt | awk -v i=$i -F ':' 'NR==i {print $NF}')+$(cat produtos.txt | awk -F ':' '{print $1":"$4}' | grep "$produto" | awk -F ':' '{print $2}')))
        if (( $reposicao > $(cat produtos.txt | awk -F ':' '{print $1":"$NF}' | grep "$produto" | awk -F ':' '{print $2}') )); then
            reposicao=$(cat produtos.txt | awk -F ':' '{print $1":"$NF}' | grep "$produto" | awk -F ':' '{print $2}')
        fi
        awk -F ':' -v produto="$produto" -v reposicao=$reposicao 'BEGIN {OFS=":"} $1 == produto {$4 = reposicao} 1' produtos.txt > tmp && mv tmp produtos.txt
        if [[ "$?" != "0" ]]; then 
             ./error 3.2.2
             exit
        fi
    fi
done
./success 3.2.2

#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº: 110976   Nome: Diogo Pedro Cordeiro Pereira
## Nome do Módulo: compra.sh
## Descrição/Explicação do Módulo: 
## Descrito em linhas de comentário
##
###############################################################################

####################### 2.1 ####################################

###### 2.1.1 #######
[ -f "produtos.txt" ] && [ -f "utilizadores.txt" ] && ./success 2.1.1 || { ./error 2.1.1; exit; }  # Verifica se os produtos.txt e utilizadores.txt existem

echo ""

######### 2.1.2 #############
for (( i=0; i <= $(cat produtos.txt | wc -l); i++ )); do    # Print p/ a consola das opcoes para o utilizador selecionar
    if [[ $(cat produtos.txt | awk -v i=$i -F ':' 'NR==i {print $4}') > 0 ]]; then
        echo "$i: $(cat produtos.txt | awk -v i=$i -F ':' 'NR==i {print $1}'): $(cat produtos.txt | awk -v i=$i -F ':' 'NR==i {print $3}') EUR"
    fi
done
echo "0: Sair"
echo ""
read -p "Insira a sua opção: " input   # Input da opcao do utilizador

if [[ $input == 0 ]]; then   #Opção 0 - sair
    ./success 2.1.2
    exit
fi

if [[ $input =~ ^[^0-9]*$ ]]; then    #Erro caso o input não seja um numero
    ./error 2.1.2
    exit
fi

if (( $input > $i )); then   #Erro caso o numero seja maior que o da ultima opçao (produto não exista o out of stock)
    ./error 2.1.2
    exit
fi

for (( i=1; i <= $(cat produtos.txt | wc -l); i++ )); do      # Corresponde o nº da opcao selecionado pelo utilizador com o produto
    if [[ $(cat produtos.txt | awk -v i=$i -F ':' 'NR==i {print $4}') > 0 ]]; then
        if [ $i -eq $input ]; then
            product="$(cat produtos.txt | awk -v i=$i -F ':' 'NR==i {print $1}')"
        fi
    fi
done
./success 2.1.2 "$product"

##############

####### 2.1.3 #######
echo ""
read -p "Insira o ID do seu utilizador: " user_ID      ## Insercao do ID do utilizador
if [[ "$(cat utilizadores.txt | awk -F ':' '{print $1}' | grep "$user_ID")" = "$user_ID" ]]; then   # Verifica se o ID corresponde a um utilizador existente
    ./success 2.1.3 "$(cat utilizadores.txt | awk -F ':' '{print $1 ":" $2}' | grep $user_ID | awk -F ':' '{print $2}')"
else
    ./error 2.1.3
    exit
fi

####### 2.1.4 #######

echo ""
read -p "Insira a senha do seu utilizador: " user_PASS  # Input da senha pelo utilizador
if [[ "$(cat utilizadores.txt | awk -F ':' '{print $3":"$1}' | grep "$user_PASS:$user_ID")" = "$user_PASS:$user_ID" ]]; then   # Verifica se a senha corresponde 
    ./success 2.1.4                                                                                                            # com a senha gravada do utilizador selecionado
else
    ./error 2.1.4
    exit
fi

########################## 2.2  ###############################

####### 2.2.1 #######  Verifica se user tem saldo suficiente para efetuar a compra
user_NAME=$(cat utilizadores.txt | awk -F ':' '{print $1":"$2}' | grep $user_ID | awk -F ':' '{print $2}')
if (( $(cat utilizadores.txt | awk -F ':' '{print $2":"$6}' | grep "$user_NAME" | awk -F ':' '{print $NF}') >= $(cat produtos.txt | grep "$product" | awk -F ':' '{print $3}') )); then
    ./success 2.2.1 $(cat produtos.txt | grep "$product" | awk -F ':' '{print $3}') $(cat utilizadores.txt | awk -F ':' '{print $2":"$6}' | grep "$user_NAME" | awk -F ':' '{print $NF}')
else
    ./error 2.2.1 $(cat produtos.txt | grep "$product" | awk -F ':' '{print $3}') $(cat utilizadores.txt | awk -F ':' '{print $2":"$6}' | grep "$user_NAME" | awk -F ':' '{print $NF}')
    exit
fi

####### 2.2.2 ####### Subtrai o saldo do utilizador com o valor do produto e atualiza os dados no utilizadores.txt
saldo=$(expr $(cat utilizadores.txt | awk -F ':' '{print $2":"$6}' | grep "$user_NAME" | awk -F ':' '{print $NF}') - $(cat produtos.txt | grep "$product" | awk -F ':' '{print $3}'))
awk -F ':' -v name="$user_NAME" -v saldo=$saldo 'BEGIN {OFS=":"} $2 == name {$NF = saldo} 1' utilizadores.txt > tmp && mv tmp utilizadores.txt
if [[ "$?" = "0" ]]; then 
    ./success 2.2.2
else
    ./error 2.2.2
    exit
fi

####### 2.2.3 ####### Decrementa o stock do produto e atualiza o produtos.txt
stock=$(cat produtos.txt | awk -F ':' '{print $1":"$4}' | grep "$product" | awk -F ':' '{print $NF}')
newStock=$(( $stock - 1 ))
echo $newStock
awk -F ':' -v product="$product" -v stock=$newStock 'BEGIN {OFS=":"} $1 == product {$4 = stock} 1' produtos.txt > tmp && mv tmp produtos.txt
if [[ "$?" = "0" ]]; then 
    ./success 2.2.3
else
    ./error 2.2.3
    exit
fi

####### 2.2.4 #######  Regista os dados da compra no relatorio_compras.txt
date=$(date '+%Y-%m-%d')
categoria=$(cat produtos.txt | awk -F ':' '{print $1":"$2}' | grep "$product" | awk -F ':' '{print $NF}')
echo $product:$categoria:$user_ID:$date >> relatorio_compras.txt
if [[ "$?" = "0" ]]; then 
    ./success 2.2.4
else
    ./error 2.2.4
    exit
fi

####### 2.2.5 ########  Cria o ficheiro lista-compras-utilizador.txt com o historico de compras do utilizador atual
echo "**** "$date": Compras de ""$user_NAME"" ****" > lista-compras-utilizador.txt  
if [[ "$?" != "0" ]]; then 
    ./error 2.2.5
    exit
fi
for (( j=1; j <= $(cat relatorio_compras.txt | wc -l); j++ )); do
    if [[ $(cat relatorio_compras.txt | awk  -v j=$j  -F ':' 'NR==j {print $3}') == $user_ID ]]; then
        echo $(cat relatorio_compras.txt | awk -v j=$j  -F ':' 'NR==j {print $1}'),  $(cat relatorio_compras.txt | awk -F ':' -v j=$j 'NR==j {print $NF}') >> lista-compras-utilizador.txt
    fi
done
./success 2.2.5
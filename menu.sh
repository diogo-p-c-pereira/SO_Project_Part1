#!/bin/bash
export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº: 110976   Nome: Diogo Pedro Cordeiro Pereira
## Nome do Módulo: menu.sh
## Descrição/Explicação do Módulo: 
## Descrito em linhas de comentário
##
###############################################################################

a=0 # Variavel de condicao do ciclo while, para servir de saida
while [ $a -ne 1 ]; do 
    ### 5.1.1 ### Faz print do menu e das respectivas opcoes
    echo "MENU:"
    echo "1: Regista/Atualiza saldo utilizador"
    echo "2: Compra produto"
    echo "3: Reposição de stock"
    echo "4: Estatísticas"
    echo "0: Sair"
    ### 5.2.1 ### Pede e recebe o input do utilizador
    echo ""
    read -p "Opção: " input
    echo ""

    if [[ "$input" =~ ^[0-4]$ ]]; then  # Verifica se o input corresponde às opcoes apresentadas
        ./success 5.1.2 $input
        echo ""
    else
        ./error 5.1.2 $input
        echo ""
    fi

    if [[ "$input" == 0 ]]; then   # Faz exit do programa, altera a variavel de condicao para 0 para "fugir" do ciclo while  
        a=1
    fi

    ######### 5.2.2 ###############

    ### 5.2.2.1 ### Pede ao utilizador os dados para lancar como argumentos no regista_utilizador.sh
    if [[ "$input" == 1 ]]; then
        echo "Regista utilizador / Atualiza saldo utilizador:"
        read -p "Indique o nome do utilizador: " nome
        read -p "Indique a senha do utilizador: " pass
        read -p "Para registar o utilizador, insira o NIF do utilizador: " nif
        read -p "Indique o saldo a adicionar ao utilizador: " saldo
        ./regista_utilizador.sh "$nome" $pass $saldo $nif
        ./success 5.2.2.1
        echo ""
    fi

    ### 5.2.2.2 ### Evoca o compra.sh
    if [[ "$input" == 2 ]]; then
        ./compra.sh
        ./success 5.2.2.2
        echo ""
    fi

    ### 5.2.2.3 ### Evoca o refill.sh
    if [[ "$input" == 3 ]]; then
        ./refill.sh
        ./success 5.2.2.3
        echo ""
    fi

    ### 5.2.2.4 ### Mostras as sub-opcoes para evocar o stats.sh com os respetivos argumentos
    if [[ "$input" == 4 ]]; then
        echo "Estatísticas:"
        echo "1: Listar utilizadores que já fizeram compras"
        echo "2: Listar os produtos mais vendidos"
        echo "3: Histograma de vendas"
        echo "0: Voltar ao menu principal"
        echo ""
        read -p "Sub-Opção: " subInput
        if [[ $subInput =~ ^[0-3]$ ]]; then  #Verifica se a opcao é valida
            if [[ "$subInput" == 1 ]]; then  #Evoca o stats.sh com a opcao listar
                ./stats.sh listar
            fi
            if [[ "$subInput" == 2 ]]; then  #Pede ao utilizador o nº de produtos mais vendidos a apresentar
                echo ""
                echo "Listar os produtos mais vendidos:"
                read -p "Indique o número de produtos mais vendidos a listar: " subSubInput
                ./stats.sh popular $subSubInput    #Evoca o stats.sh com a opcao popular e o nº de produtos mais vendidos a apresentar
            fi
            if [[ "$subInput" == 3 ]]; then #Evoca o stats.sh com a opcao histograma
                ./stats.sh histograma
            fi
            ./success 5.2.2.4
        else
            echo ""
            ./error 5.2.2.4
        fi
        echo ""
    fi
done


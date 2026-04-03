#!/bin/bash
exec_list(){
    ps | zenity --list --title "Gerenciador de Processos" --text "Processos em Execução" --column "Processos em execução"
    cont_user
}
info_pid(){
    if [[ $proc != "Alterar prioridade" ]]
    then
        pid=$(zenity --entry --text 'Informe o PID do processo')
    else
        pid=$(zenity --entry --text 'Informe o PID do processo')
        prio_value=$(zenity --entry --text 'Informe a prioridade do processo [-20(maior) a 19(menor)]')
    fi
}
info_name(){
    if [[ $proc != "Iniciar com prioridade no segundo plano" ]]
    then
        process=$(zenity --entry --text 'Informe o nome/caminho do processo')
    else
        process=$(zenity --entry --text 'Informe o nome/caminho do processo')
        prio_value=$(zenity --entry --text 'Informe a prioridade do processo [-20(maior) a 19(menor)]')
    fi
}
info_proc(){
    if [[ $selec == "By-PID" ]]
    then
        proc=$(zenity --list --radiolist --title 'Gerenciador de Processos' --text 'Gerenciamento por PID' --column 'Item' --column 'Função' \
        1 "Mostrar processos em execução" 2 "Paralisar processo" 3 "Continuar execução de processo" 4 "Terminar execução de processo" \
        5 "Forçar encerramento do processo" 6 "Alterar prioridade de um processo" 7 "Mostrar árvore do processo")
    elif [[ $selec == "By-Name" ]]
    then
        proc=$(zenity --list --radiolist --title 'Gerenciador de Processos' --text 'Gerenciamento por Nome' --column 'Item' --column 'Função' \
        1 "Paralisar processo" 2 "Continuar execução de processo" 3 "Terminar execução de processo" 4 "Forçar encerramento do processo" \
        5 "Iniciar com prioridade no segundo plano")
    fi
}
cont_user(){
    sleep 1
    zenity --question --text="Deseja continuar?"
    cont=$?
}
bypid(){
    info_proc
    case $proc in
        "Mostrar processos em execução") info_name; (ps aux | grep $process) | zenity --list --title \
        "Gerenciador de Processos" --text "Processos Filtrados por Nome" --column \
        "Processos nomeados por $process"; cont_user;;

        "Paralisar processo") info_pid; kill -STOP $pid; cont_user;;

        "Continuar execução de processo") info_pid; kill -CONT $pid; cont_user;;

        "Terminar execução de processo") info_pid; kill -15 $pid; cont_user;;

        "Forçar encerramento do processo") info_pid; kill -9 $pid; cont_user;;

        "Alterar prioridade de um processo")info_pid
                                            renice -n "$prio_value" -p "$pid"
                                            cont_user;;

        "Mostrar árvore do processo") info_pid; pstree -p $pid | zenity --list --title \
        "Gerenciador de Processos" --text "Árvore do Processo PID: $pid" --column \
        "Árvore de processos"; cont_user;;
    esac
}
byname(){
    info_proc
    case $proc in
        "Paralisar processo") info_name; pkill -STOP $process; cont_user;;

        "Continuar execução de processo") info_name; pkill -CONT $process; cont_user;;

        "Terminar execução de processo") info_name; pkill -15 $process; cont_user;;

        "Forçar encerramento do processo") info_name; pkill -9 $process; cont_user;;
        
        "Iniciar com prioridade no segundo plano")  info_name
                                                    nice -n "$prio_value" "$process" &
                                                    cont_user;;
    esac
}
tree_user(){
    user=$(zenity --entry --text "Informe o usuário")
    pstree $user | zenity --list --title "Gerenciador de Processos" --text \
    "Árvore de Processos do Usuário: $user" --column "Árvore de processos"
    cont_user
}
sobre(){
    printf "%s\n" \
    "Criador 1|Maria Julia Soares Perim" \
    "Criador 2|Pablo Silva Torres" \
    "Criador 3|Rayssa Santhiago Sanches" \
    "Data de Criação|Novembro de 2025" | \
    zenity --list --title "Gerenciador de Processos" --text "Informações do Sistema (Sobre)" \
    --column "Detalhe" --column "Valor" --separator='|'
    cont_user
}

cont=0

while [ $cont != 1 ]
do
    selec=$(zenity --list --radiolist --title 'Gerenciador de Processos' --text 'Menu Principal' \
    --column 'Item' --column "Opções de Gerenciamento" 1 "Processos em execução" 2 'By-PID' \
    3 'By-Name' 4 "Árvore de processos do usuário" 5 "Sobre o sistema")
    case $selec in
        "Processos em execução") exec_list;;
        By-PID) bypid;;
        By-Name) byname;;
        "Árvore de processos do usuário") tree_user;;
        "Sobre o sistema") sobre;;
    esac
done
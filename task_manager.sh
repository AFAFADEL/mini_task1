#!/bin/bash

FILE="tasks.txt"
LOG="task_manager.log"

#=============================
# Colors
#=============================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

#=============================
# Initialize Files
#=============================
[ ! -f "$FILE" ] && touch "$FILE"
[ ! -f "$LOG" ] && touch "$LOG"

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG"
}

#=============================
# Spinner Animation
#=============================
spinner() {
    pid=$!
    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r${CYAN}Processing ${spin:$i:1}${NC}"
        sleep .1
    done
    printf "\r"
}

#=============================
# Generate ID
#=============================
generate_id() {
    if [ ! -s "$FILE" ]; then
        echo 1
    else
        awk -F"|" 'END{print $1+1}' "$FILE"
    fi
}

#=============================
# Add Task
#=============================
add_task() {
    read -p "Enter Title: " title

    if [ -z "$title" ]; then
        echo -e "${RED}Title cannot be empty!${NC}"
        return
    fi

    if ! [[ "$title" =~ [a-zA-Z] ]]; then
        echo -e "${RED}Title must contain letters!${NC}"
        return
    fi

    read -p "Enter Priority (high/medium/low): " priority
    if [[ "$priority" != "high" && "$priority" != "medium" && "$priority" != "low" ]]; then
        echo -e "${RED}Invalid priority!${NC}"
        return
    fi

    read -p "Enter Due Date (YYYY-MM-DD): " due
    if ! date -d "$due" +"%Y-%m-%d" >/dev/null 2>&1 || [[ ! "$due" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo -e "${RED}Invalid date format! Use YYYY-MM-DD${NC}"
        return
    fi

    id=$(generate_id)
    echo "$id|$title|$priority|$due|pending" >> "$FILE"

    log_action "Task Added: $title"
    echo -e "${GREEN}Task Added Successfully!${NC}"
}

#=============================
# List Tasks
#=============================
list_tasks() {
    if [ ! -s "$FILE" ]; then
        echo -e "${RED}No tasks found!${NC}"
        return
    fi

    echo -e "\n${BOLD}${CYAN}ID    Title                     Priority   Due Date     Status${NC}"
    echo "-----------------------------------------------------------------------"

    while IFS="|" read -r id title priority due status
    do
        case $status in
            pending) color=$YELLOW ;;
            in-progress) color=$BLUE ;;
            done) color=$GREEN ;;
            *) color=$NC ;;
        esac

        printf "%-5s %-25s %-10s %-12s ${color}%-15s${NC}\n" "$id" "$title" "$priority" "$due" "$status"
    done < "$FILE"
}

#=============================
# Update Task
#=============================
update_task() {
    read -p "Enter Task ID to update: " id

    if ! grep -q "^$id|" "$FILE"; then
        echo -e "${RED}Task ID not found!${NC}"
        return
    fi

    read -p "New Title: " title
    if ! [[ "$title" =~ [a-zA-Z] ]]; then
        echo -e "${RED}Title must contain letters!${NC}"
        return
    fi

    read -p "New Priority (high/medium/low): " priority
    read -p "New Due Date (YYYY-MM-DD): " due
    read -p "New Status (pending/in-progress/done): " status

    if [[ "$priority" != "high" && "$priority" != "medium" && "$priority" != "low" ]]; then
        echo -e "${RED}Invalid priority!${NC}"
        return
    fi

    if [[ "$status" != "pending" && "$status" != "in-progress" && "$status" != "done" ]]; then
        echo -e "${RED}Invalid status!${NC}"
        return
    fi

    if ! date -d "$due" +"%Y-%m-%d" >/dev/null 2>&1 || [[ ! "$due" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo -e "${RED}Invalid date format!${NC}"
        return
    fi

    (sleep 1) &
    spinner

    sed -i "/^$id|/c\\$id|$title|$priority|$due|$status" "$FILE"

    log_action "Task Updated: ID $id"
    echo -e "${GREEN}Task Updated Successfully!${NC}"
}

#=============================
# Delete Task
#=============================
delete_task() {
    read -p "Enter Task ID to delete: " id

    if ! grep -q "^$id|" "$FILE"; then
        echo -e "${RED}Task ID not found!${NC}"
        return
    fi

    read -p "Are you sure? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        sed -i "/^$id|/d" "$FILE"
        log_action "Task Deleted: ID $id"
        echo -e "${GREEN}Task Deleted Successfully!${NC}"
    else
        echo -e "${YELLOW}Deletion Cancelled.${NC}"
    fi
}

#=============================
# Search Task
#=============================
search_task() {
    read -p "Enter keyword: " keyword
    grep -i "$keyword" "$FILE"
}

#=============================
# Reports
#=============================
task_summary() {
    echo -e "${CYAN}Pending:${NC} $(grep -c "|pending$" "$FILE")"
    echo -e "${BLUE}In-Progress:${NC} $(grep -c "|in-progress$" "$FILE")"
    echo -e "${GREEN}Done:${NC} $(grep -c "|done$" "$FILE")"
}

overdue_tasks() {
    today=$(date +%Y-%m-%d)
    awk -F"|" -v today="$today" '$4 < today && $5 != "done"' "$FILE"
}

priority_report() {
    echo -e "${RED}High Priority:${NC}"
    grep "|high|" "$FILE"
    echo -e "\n${YELLOW}Medium Priority:${NC}"
    grep "|medium|" "$FILE"
    echo -e "\n${GREEN}Low Priority:${NC}"
    grep "|low|" "$FILE"
}

reports_menu() {
    echo -e "${CYAN}1. Task Summary${NC}"
    echo -e "${CYAN}2. Overdue Tasks${NC}"
    echo -e "${CYAN}3. Priority Report${NC}"
    read -p "Choose: " rep

    case $rep in
        1) task_summary ;;
        2) overdue_tasks ;;
        3) priority_report ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
}

#=============================
# Main Menu
#=============================
main_menu() {
    echo -e "\n${BOLD}${MAGENTA}====== Task Manager ======${NC}"
    echo -e "${GREEN}1. Add Task${NC}"
    echo -e "${BLUE}2. List Tasks${NC}"
    echo -e "${YELLOW}3. Update Task${NC}"
    echo -e "${MAGENTA}4. Delete Task${NC}"
    echo -e "${RED}5. Search${NC}"
    echo -e "${CYAN}6. Reports${NC}"
    echo -e "${GREEN}7. Exit${NC}"
    echo
    read -p "Choose option: " choice

    case $choice in
        1) add_task ;;
        2) list_tasks ;;
        3) update_task ;;
        4) delete_task ;;
        5) search_task ;;
        6) reports_menu ;;
        7) exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}" ;;
    esac
}

while true; do
    main_menu
done

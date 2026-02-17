#!/bin/bash

FILE="tasks.txt"

# إنشاء الملف لو مش موجود
[ ! -f "$FILE" ] && touch "$FILE"

########################################
# توليد ID جديد
########################################
generate_id() {
    if [ ! -s "$FILE" ]; then
        echo 1
    else
        awk -F"|" 'END{print $1+1}' "$FILE"
    fi
}

########################################
# إضافة مهمة
########################################
add_task() {
    read -p "Enter Title: " title
    if [ -z "$title" ]; then
        echo "Title cannot be empty!"
        return
    fi

    read -p "Enter Priority (high/medium/low): " priority
    if [[ "$priority" != "high" && "$priority" != "medium" && "$priority" != "low" ]]; then
        echo "Invalid priority!"
        return
    fi

    read -p "Enter Due Date (YYYY-MM-DD): " due
    if ! date -d "$due" >/dev/null 2>&1; then
        echo "Invalid date format!"
        return
    fi

    id=$(generate_id)
    echo "$id|$title|$priority|$due|pending" >> "$FILE"
    echo "Task Added Successfully!"
}

########################################
# عرض المهام
########################################
list_tasks() {
    if [ ! -s "$FILE" ]; then
        echo "No tasks found!"
        return
    fi

    printf "\n%-5s %-25s %-10s %-12s %-15s\n" "ID" "Title" "Priority" "Due Date" "Status"
    echo "-----------------------------------------------------------------------"
    awk -F"|" '{printf "%-5s %-25s %-10s %-12s %-15s\n",$1,$2,$3,$4,$5}' "$FILE"
}

########################################
# تحديث مهمة
########################################
update_task() {
    read -p "Enter Task ID to update: " id

    if ! grep -q "^$id|" "$FILE"; then
        echo "Task ID not found!"
        return
    fi

    read -p "New Title: " title
    read -p "New Priority (high/medium/low): " priority
    read -p "New Due Date (YYYY-MM-DD): " due
    read -p "New Status (pending/in-progress/done): " status

    if [[ "$priority" != "high" && "$priority" != "medium" && "$priority" != "low" ]]; then
        echo "Invalid priority!"
        return
    fi

    if [[ "$status" != "pending" && "$status" != "in-progress" && "$status" != "done" ]]; then
        echo "Invalid status!"
        return
    fi

    if ! date -d "$due" >/dev/null 2>&1; then
        echo "Invalid date!"
        return
    fi

    sed -i "/^$id|/c\$id|$title|$priority|$due|$status" "$FILE"
    echo "Task Updated!"
}

########################################
# حذف مهمة
########################################
delete_task() {
    read -p "Enter Task ID to delete: " id

    if ! grep -q "^$id|" "$FILE"; then
        echo "Task ID not found!"
        return
    fi

    read -p "Are you sure? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        sed -i "/^$id|/d" "$FILE"
        echo "Task Deleted!"
    fi
}

########################################
# البحث
########################################
search_task() {
    read -p "Enter keyword: " keyword
    grep -i "$keyword" "$FILE"
}

########################################
# تقرير ملخص الحالات
########################################
task_summary() {
    echo "Pending: $(grep -c "|pending$" "$FILE")"
    echo "In-Progress: $(grep -c "|in-progress$" "$FILE")"
    echo "Done: $(grep -c "|done$" "$FILE")"
}

########################################
# المهام المتأخرة
########################################
overdue_tasks() {
    today=$(date +%Y-%m-%d)
    echo "Overdue Tasks:"
    awk -F"|" -v today="$today" '$4 < today && $5 != "done"' "$FILE"
}

########################################
# تقرير حسب الأولوية
########################################
priority_report() {
    echo "High Priority:"
    grep "|high|" "$FILE"

    echo -e "\nMedium Priority:"
    grep "|medium|" "$FILE"

    echo -e "\nLow Priority:"
    grep "|low|" "$FILE"
}

########################################
# التقارير
########################################
reports_menu() {
    echo "1. Task Summary"
    echo "2. Overdue Tasks"
    echo "3. Priority Report"
    read -p "Choose: " rep

    case $rep in
        1) task_summary ;;
        2) overdue_tasks ;;
        3) priority_report ;;
        *) echo "Invalid choice" ;;
    esac
}

########################################
# القائمة الرئيسية
########################################
main_menu() {
    echo -e "\n====== Task Manager ======"
    echo "1. Add Task"
    echo "2. List Tasks"
    echo "3. Update Task"
    echo "4. Delete Task"
    echo "5. Search"
    echo "6. Reports"
    echo "7. Exit"
    read -p "Choose option: " choice

    case $choice in
        1) add_task ;;
        2) list_tasks ;;
        3) update_task ;;
        4) delete_task ;;
        5) search_task ;;
        6) reports_menu ;;
        7) exit 0 ;;
        *) echo "Invalid option!" ;;
    esac
}

while true; do
    main_menu
done

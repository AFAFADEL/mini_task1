# 🗂 Mini Task Manager - Bash Project

## 📌 Overview

Mini Task Manager is a Command Line Task Management System built using **Bash scripting**.

It allows users to:

- Add tasks
- List tasks
- Update tasks
- Delete tasks
- Search tasks
- Generate reports

All tasks are stored inside:

```
tasks.txt
```

Each task is saved in this format:

```
ID|Title|Priority|DueDate|Status
```

Example:

```
1|Study DevOps|high|2026-02-20|pending
```

---

# 🚀 How To Run

1. Make the script executable:

```bash
chmod +x task_manager.sh
```

2. Run the project:

```bash
./task_manager.sh
```

---

# 📂 Project Structure

```
Mini-Task-Manager/
│
├── task_manager.sh
├── tasks.txt
└── README.md
```

---

# 🧠 Features Explained

## 1️⃣ Add Task
- Validates title (cannot be empty)
- Validates priority (high/medium/low)
- Validates date format (YYYY-MM-DD)
- Automatically generates unique ID
- Default status = pending

---

## 2️⃣ List Tasks
Displays all tasks in table format using:

- `awk`
- formatted output (`printf`)

---

## 3️⃣ Update Task
- Searches by ID
- Validates new values
- Uses `sed` to update task

---

## 4️⃣ Delete Task
- Deletes by ID
- Confirmation before deletion
- Uses `sed` to remove line

---

## 5️⃣ Search
- Searches by keyword
- Case-insensitive search
- Uses `grep -i`

---

## 6️⃣ Reports

### 📊 Task Summary
Counts:
- Pending
- In-progress
- Done

### ⏰ Overdue Tasks
Shows tasks where:
- Due date < today
- Status != done

### 🎯 Priority Report
Groups tasks by:
- High
- Medium
- Low

---

# 🧾 Full Source Code

Below is the complete script:

```bash
#!/bin/bash

FILE="tasks.txt"
[ ! -f "$FILE" ] && touch "$FILE"

generate_id() {
    if [ ! -s "$FILE" ]; then
        echo 1
    else
        awk -F"|" 'END{print $1+1}' "$FILE"
    fi
}

add_task() {
    read -p "Enter Title: " title
    [ -z "$title" ] && echo "Title cannot be empty!" && return

    read -p "Enter Priority (high/medium/low): " priority
    [[ "$priority" != "high" && "$priority" != "medium" && "$priority" != "low" ]] && echo "Invalid priority!" && return

    read -p "Enter Due Date (YYYY-MM-DD): " due
    ! date -d "$due" >/dev/null 2>&1 && echo "Invalid date format!" && return

    id=$(generate_id)
    echo "$id|$title|$priority|$due|pending" >> "$FILE"
    echo "Task Added Successfully!"
}

list_tasks() {
    [ ! -s "$FILE" ] && echo "No tasks found!" && return

    printf "\n%-5s %-25s %-10s %-12s %-15s\n" "ID" "Title" "Priority" "Due Date" "Status"
    echo "-----------------------------------------------------------------------"
    awk -F"|" '{printf "%-5s %-25s %-10s %-12s %-15s\n",$1,$2,$3,$4,$5}' "$FILE"
}

update_task() {
    read -p "Enter Task ID to update: " id
    ! grep -q "^$id|" "$FILE" && echo "Task ID not found!" && return

    read -p "New Title: " title
    read -p "New Priority (high/medium/low): " priority
    read -p "New Due Date (YYYY-MM-DD): " due
    read -p "New Status (pending/in-progress/done): " status

    [[ "$priority" != "high" && "$priority" != "medium" && "$priority" != "low" ]] && echo "Invalid priority!" && return
    [[ "$status" != "pending" && "$status" != "in-progress" && "$status" != "done" ]] && echo "Invalid status!" && return
    ! date -d "$due" >/dev/null 2>&1 && echo "Invalid date!" && return

    sed -i "/^$id|/c\\$id|$title|$priority|$due|$status" "$FILE"
    echo "Task Updated!"
}

delete_task() {
    read -p "Enter Task ID to delete: " id
    ! grep -q "^$id|" "$FILE" && echo "Task ID not found!" && return

    read -p "Are you sure? (y/n): " confirm
    [ "$confirm" == "y" ] && sed -i "/^$id|/d" "$FILE" && echo "Task Deleted!"
}

search_task() {
    read -p "Enter keyword: " keyword
    grep -i "$keyword" "$FILE"
}

task_summary() {
    echo "Pending: $(grep -c "|pending$" "$FILE")"
    echo "In-Progress: $(grep -c "|in-progress$" "$FILE")"
    echo "Done: $(grep -c "|done$" "$FILE")"
}

overdue_tasks() {
    today=$(date +%Y-%m-%d)
    awk -F"|" -v today="$today" '$4 < today && $5 != "done"' "$FILE"
}

priority_report() {
    echo "High Priority:"
    grep "|high|" "$FILE"
    echo -e "\nMedium Priority:"
    grep "|medium|" "$FILE"
    echo -e "\nLow Priority:"
    grep "|low|" "$FILE"
}

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
```

---

# 🛠 Skills Used

- Bash Scripting
- File Handling
- awk
- sed
- grep
- Input Validation
- CLI Menu Design

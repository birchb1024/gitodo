#!/bin/bash
#
# Todo List in Git
function gitodo-init {
    #
    # Set TODO_DIR to the directory which you want to use for items
    #
    export TODO_DIR="$PWD"
    export TODO_GIT_DIR="$TODO_DIR"/.git
    echo "Using $TODO_DIR"
}

function list () (
    #
    # List all open items and display a summary of the history
    #
    cd "$TODO_DIR" &&
    local current_branch
    current_branch=$(git --git-dir="$TODO_GIT_DIR" symbolic-ref HEAD | cut -d/ -f3)
    #shellcheck disable=SC2016
    git --git-dir="$TODO_GIT_DIR" for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads | fzf --header="Doing: ${current_branch}" -1 -e --preview='git --git-dir="$TODO_GIT_DIR" log --abbrev-commit --decorate --format=format:"- %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)" {}' > /dev/null
)

function did () (
    #
    # Print history of the current item
    #
    cd "$TODO_DIR" &&
    git --git-dir="$TODO_GIT_DIR" log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'
)

function doing () (
    #
    # Choose a new active branch , provide a string to search for in the list of items
    #
    # Example:
    #
    #   $ doing world
    #
    local pattern="${1}"
    cd "$TODO_DIR"
    if [[ "$(git clean -xn | grep 'Would remove')" != "" ]]
    then
        echo "Workstation not clean - Files not checked in or ignored"
        git status --short --ignored --untracked-files
        return 1
    fi
    git --git-dir="$TODO_GIT_DIR" checkout "$(git --git-dir="$TODO_GIT_DIR" for-each-ref --sort=-committerdate --format='%(refname:lstrip=-1)' refs | sort -u | fzf -1 -e -q "${pattern}" | awk '{print $NF}' )"
)

function what () (
    #
    # Print the active item
    #
    cd "$TODO_DIR" &&
    local current_branch
    current_branch=$(git --git-dir="$TODO_GIT_DIR" symbolic-ref HEAD | cut -d/ -f3)
    echo "$current_branch"
)

function nb () (
    #
    # Add a one-line comment record to the current branch
    #
    # Example:
    #
    #   $ nb Linus says sorry
    #
    cd "$TODO_DIR" &&
    git --git-dir="$TODO_GIT_DIR" commit --allow-empty -m "$*"
)
function memo () (
    #
    # Add a multi-line commit to the current item
    #
    cd "$TODO_DIR" &&
    git --git-dir="$TODO_GIT_DIR" commit --allow-empty
)
function todo () (
    #
    # Create a new item todo
    #
    # Example:
    #
    #   $ todo Solve world hunger
    #
    if [[ "$#" == "0" ]]; then
        echo "Nothing added"
        return 0
    fi
    cd "$TODO_DIR" &&
    local current_branch
    current_branch="$(git --git-dir="$TODO_GIT_DIR" status | head -1 | sed 's;On branch ;;' )"
    local task_name
    task_name=$(echo "$*" | tr ' ' '_')
    git --git-dir="$TODO_GIT_DIR" checkout --orphan "$task_name" trunk &&
    git --git-dir="$TODO_GIT_DIR" commit --allow-empty -m "New task: $*"
    git --git-dir="$TODO_GIT_DIR" checkout "$current_branch"
)

function fin () (
    #
    # Finish an item, remove it from the list. Optionally provide an inital search string.
    #
    # Example:
    #
    #   $ fin hunger
    #
    local pattern="${1}"
    cd "$TODO_DIR" &&
    local current_branch
    current_branch=$(git --git-dir="$TODO_GIT_DIR" for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads | fzf -1 -e -q "${pattern}")
    if [[ "${current_branch}" == "" || "${current_branch}" == "trunk" ]] ; then
        echo "Nothing selected"
        return
    fi
    git --git-dir="$TODO_GIT_DIR" checkout "$current_branch"
    git --git-dir="$TODO_GIT_DIR" commit --allow-empty -m "Finished $(echo "$current_branch" | tr '_' ' ')"
    git --git-dir="$TODO_GIT_DIR" tag -f -m "DONE $current_branch" -a "$current_branch" &&
    git --git-dir="$TODO_GIT_DIR" checkout trunk &&
    git --git-dir="$TODO_GIT_DIR" branch -D "$current_branch"
)

function recent() {
    #
    # Report the history of recently used items - hint use | less -r
    #
    git --git-dir="$TODO_GIT_DIR" for-each-ref --sort=-committerdate refs/heads --format '%(color:yellow) %(committerdate:short) %(color:white) %(refname:short)' | tr '_' ' '
}

function gitodo {
    #
    # HELP - Report these commands and what they do
    #
    grep function -A 2 --no-group-separator "${TODO_SCRIPT}" | grep -v grep | sed 's;function ;;' | tr -d '#(){}' | sed '/^\s*$/d'
}

export TODO_SCRIPT="${BASH_SOURCE[0]}"

# Items (Do this when I get a Round Toit - a square one won't do ;-)
# TOIT - rewrite in Go
# TOIT - make the init function create a .git repo with empty trunk perhaps

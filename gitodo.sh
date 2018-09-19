#
# Todo List in Git
#
# Set TODO_DIR to the directory which you want to use for items
#
export TODO_DIR=${TODO_DIR:-"$PWD"}
export TODO_GIT_DIR="$TODO_DIR/.git"

function list () (
    #
    # List all open items
    #
    cd $TODO_DIR &&
    local current_branch=$(git --git-dir=$TODO_GIT_DIR symbolic-ref HEAD | cut -d/ -f3)
    git --git-dir=$TODO_GIT_DIR for-each-ref --format='%(refname:short)' refs/heads/* | fzf --header="Doing: ${current_branch}" -e --preview='git --git-dir=$TODO_GIT_DIR log --abbrev-commit --decorate --format=format:"- %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)" {}' >/dev/null
)
function did () (
    #
    # Print history of the current item
    #
    cd $TODO_DIR &&
    git --git-dir=$TODO_GIT_DIR log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'
)
function doing () (
    #
    # Choose a new active branch , provide a string to search for in the liost of items
    #
    # Example:
    #
    #   $ doing world
    #
    local pattern="${1}"
    cd $TODO_DIR &&
    git --git-dir=$TODO_GIT_DIR checkout $(git --git-dir=$TODO_GIT_DIR for-each-ref --format='%(refname:short)' refs/heads/* | fzf -1 -e -q "${pattern}" )
)
function what () (
    #
    # Print the active item
    #
    cd $TODO_DIR &&
    local current_branch=$(git --git-dir=$TODO_GIT_DIR symbolic-ref HEAD | cut -d/ -f3)
    echo $current_branch
)
function nb () (
    #
    # Add a one-line commit record to the current branch
    #
    # Example: 
    #
    #   $ nb Linus says sorry
    #
    cd $TODO_DIR &&
    git --git-dir=$TODO_GIT_DIR commit --allow-empty -m "$*"
)
function memo () (
    #
    # Add a multi-line commit record to the current branch
    #
    cd $TODO_DIR &&
    git --git-dir=$TODO_GIT_DIR commit --allow-empty
)
function todo () (
    #
    # Create a new item todo 
    #
    # Example: 
    #
    #   $ todo Solve world hunger
    #
    cd $TODO_DIR &&
    local current_branch=$(git --git-dir=$TODO_GIT_DIR status | head -1 | sed 's;On branch ;;' )
    local task_name=$(echo "$*" | tr ' ' '_')
    git --git-dir=$TODO_GIT_DIR checkout --orphan $task_name && 
    git --git-dir=$TODO_GIT_DIR commit --allow-empty -m "Added $task_name"
    git --git-dir=$TODO_GIT_DIR checkout $current_branch
)

function fin () (
    #
    # Finish an item, remove it from the list.
    #
    cd $TODO_DIR &&
    local current_branch=$(git --git-dir=$TODO_GIT_DIR for-each-ref --format='%(refname:short)' refs/heads/* | fzf -e)
    git --git-dir=$TODO_GIT_DIR checkout $current_branch
    git --git-dir=$TODO_GIT_DIR commit --allow-empty -m "Finished $current_branch"
    git --git-dir=$TODO_GIT_DIR tag -f -m 'DONE' -a $current_branch && 
    git --git-dir=$TODO_GIT_DIR checkout master &&
    git --git-dir=$TODO_GIT_DIR branch -D $current_branch
)

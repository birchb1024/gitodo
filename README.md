# gitodo
Use Git to store and update todo lists and issues.

## Installation

* Clone this repo
* Install fzf (https://github.com/junegunn/fzf)
* Set some environment variables

~~~
    export TODO_DIR=/some/directory
~~~

* Create the repo

~~~
    cd $TODO_DIR; git init
~~~

## Usage

~~~
list

     List all open items

did

     Print history of the current item

doing

     Choose a new active branch , provide a string to search for in the liost of items

     Example:

       $ doing world

what

     Print the active item

nb

     Add a one-line comment record to the current branch

     Example:

       $ nb Linus says sorry

memo

     Add a multi-line commit to the current item

todo

     Create a new item todo

     Example:

       $ todo Solve world hunger

fin

     Finish an item, remove it from the list. Optionally provide an inital search string.

     Example:

       $ fin hunger

~~~
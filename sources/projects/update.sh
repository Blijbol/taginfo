#!/usr/bin/env bash
#------------------------------------------------------------------------------
#
#  Taginfo source: Projects
#
#  update.sh DATADIR
#
#------------------------------------------------------------------------------

set -euo pipefail

readonly SRCDIR=$(dirname "$(readlink -f "$0")")
readonly DATADIR=$1

if [ -z "$DATADIR" ]; then
    echo "Usage: update.sh DATADIR"
    exit 1
fi

readonly PROJECT_LIST="$DATADIR/taginfo-projects/project_list.txt"
readonly DATABASE="$DATADIR/taginfo-projects.db"

# shellcheck source=/dev/null
source "$SRCDIR/../util.sh" projects

update_projects_list() {
    if [ -d "$DATADIR/taginfo-projects" ]; then
        run_exe git -C "$DATADIR/taginfo-projects" pull --quiet
    else
        run_exe git clone --quiet --depth=1 https://github.com/taginfo/taginfo-projects.git "$DATADIR/taginfo-projects"
    fi
}

import_projects_list() {
    run_ruby "-l$DATADIR/import.log" "$SRCDIR/import.rb" "$DATADIR" "$PROJECT_LIST"
    run_ruby "-l$DATADIR/parse.log" "$SRCDIR/parse.rb" "$DATADIR"
    run_ruby "-l$DATADIR/get_icons.log" "$SRCDIR/get_icons.rb" "$DATADIR"
}

main() {
    print_message "Start projects..."

    initialize_database "$DATABASE" "$SRCDIR"
    update_projects_list
    import_projects_list
    finalize_database "$DATABASE" "$SRCDIR"

    print_message "Done projects."
}

main


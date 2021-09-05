#!/bin/bash
# Improve bash history followed this blog
# https://www.thomaslaurenson.com/blog/2018-07-02/better-bash-history/

# Configure BASH to append (rather than overwrite the history):
shopt -s histappend

# Attempt to save all lines of a multiple-line command in the same entry
shopt -s cmdhist

# After each command, append to the history file and reread it
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$"\n"}history -a; history -c; history -r"

# Print the timestamp of each command
HISTTIMEFORMAT='%F_%H-%M-%S '

# Set high limit for history file size
HISTFILESIZE=500000
HISTSIZE=500000


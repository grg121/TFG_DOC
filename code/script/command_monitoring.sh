#!/bin/bash
# Add it to your .bashrc or similar configuration files
# Based on the code shared by VarunAgw at
# https://unix.stackexchange.com/a/250792/360599
########################################################

shopt -s extdebug

preexec_invoke_exec () {

    timestamp=$(date +%Y-%m-%d)
    session_log=/var/log/session/session.$USER.$$.$timestamp

    [ -n "$COMP_LINE" ] && return  # do nothing if completing
    [ "$BASH_COMMAND" = "$PROMPT_COMMAND" ] && return # don't cause a preexec for $PROMPT_COMMAND
    local this_command=`HISTTIMEFORMAT= history 1 | sed -e "s/^[ ]*[0-9]*[ ]*//"`;

    # So that you don't get locked accidentally
    if [ "shopt -u extdebug" == "$this_command" ]; then
        return 0
    fi

    if [ "clear" == "$this_command" ]; then
        return 0
    fi

    if [[ "${this_command}" =~ "cd ".* ]]; then
        return 0
    fi

    if [[ "${this_command}" =~ "cat /var/log/session/".* ]]; then
        return 0
    fi

    if [[ "${this_command}" =~ \S*=.* ]]; then
      this_command_output=""
      echo "$(date "+%b %d %H:%M:%S") $(whoami) shell_log: # ${this_command} -> $this_command_output" >> "${session_log}"
      return 0
    fi

    this_command_output=$(eval "${this_command}" | tee /dev/tty)
    this_command_output=$(echo "${this_command_output}" | tr '\n' ' ')

    echo "$(date "+%b %d %H:%M:%S") $(whoami) shell_log: # ${this_command} -> $this_command_output" >> "${session_log}"

    return 1 # This prevent executing of original command
}
trap 'preexec_invoke_exec' DEBUG


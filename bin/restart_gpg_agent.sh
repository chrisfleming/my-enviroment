
AGENT_SOCK=`gpgconf --list-dirs | grep agent-socket | cut -d : -f 2`

kill_wait() {
	PID=$(pgrep -U $USER gpg-agent)
	if [ ! -z "$PID" ]; then
		echo "gpg-agent is running $PID. Trying to close, (SIGNAL $1)"
		kill -s $1 "$PID"
		WAIT_LOOP=0
		while pgrep -U $USER gpg-agent > /dev/null  2>&1; do
			sleep 1
			WAIT_LOOP=$((WAIT_LOOP+1))
			if [ "$WAIT_LOOP" = 30 ]; then
				break
			fi
		done
	else
		return 0
	fi
	PID=$(pgrep -U $USER gpg-agent)
	if [ -z "$PID" ]; then
		rm $AGENT_SOCK > /dev/null 2>&1
		return 0
	else
		return "$PID"
	fi
}

start_agent() {

if [ ! -S ${AGENT_SOCK} ]; then
	echo "No $AGENT_SOCK - starting gpg agent"
  gpg-agent --daemon --use-standard-socket >/dev/null 2>&1
  else
  	  echo "$AGENT_SOCK is a socket - no action"
fi
export GPG_TTY=$(tty)

# Set SSH to use gpg-agent if it's enabled
GPG_SSH_AUTH_SOCK="${AGENT_SOCK}.ssh"
if [ -S ${GPG_SSH_AUTH_SOCK} ]; then
  export SSH_AUTH_SOCK=$GPG_SSH_AUTH_SOCK
  unset SSH_AGENT_PID
fi
}

echo KILLAGENT | gpg-connect-agent
kill_wait "HUP"
kill_wait "TERM"
kill_wait "SIGINT"
kill_wait "KILL"

start_agent


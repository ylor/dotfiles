# keep a forwarded agent when we're inside an ssh session
if not set -q SSH_CONNECTION
    for sock in "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" $HOME/.1password/agent.sock
        test -S $sock; and set -gx SSH_AUTH_SOCK $sock; and break
    end
end

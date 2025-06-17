function tn --wraps='tmux new-session -s' --description 'alias tn=tmux new-session -s'
  tmux new-session -s $argv
        
end

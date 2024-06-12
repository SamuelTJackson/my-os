#!/bin/bash

original_color=$(tmux show -gqv 'pane-active-border-style')

tmux set -g pane-active-border-style 'bg=green'
tmux select-pane -P 'bg=green,fg=default'

sleep 0.05

tmux select-pane -P 'bg=default,fg=default'
tmux set -g pane-active-border-style "$original_color"

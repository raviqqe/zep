zstyle :vcs_info:git:* formats '%F{248}%b%f %F{cyan}%m%f'
zstyle :vcs_info:git*+set-message:* hooks git-remote

+vi-git-remote() {
  local behind ahead

  git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null |
    read behind ahead ||
    return

  git fetch --no-write-fetch-head >/dev/null 2>&1 &|

  if [ -n "$hook_com[staged]" -o -n "$hook_com[unstaged]" ]; then
    hook_com[misc]+=*
  fi

  if [ $ahead -gt 0 ]; then
    hook_com[misc]+=^
  fi

  if [ $behind -gt 0 ]; then
    hook_com[misc]+=v
  fi

  if [ -n "$hook_com[misc]" ]; then
    hook_com[misc]+=' '
  fi
}

function zle-keymap-select zle-line-init {
  if [ $KEYMAP = vicmd ]; then
    vi_mode='<'
  else
    vi_mode='>'
  fi

  zle reset-prompt
}

zle -N zle-keymap-select
zle -N zle-line-init

PROMPT='%F{blue}%~%f ${vcs_info_msg_0_}%(?..%F{red}[%?]%f )
%F{magenta}$vi_mode%f '

autoload -Uz add-zsh-hook

zstyle :vcs_info:git:* formats '%F{248}%b%f '
zstyle :vcs_info:git*+post-backend:* hooks git-status

zep-git-status() {
  local behind ahead markers

  if ! git diff --quiet || ! git diff --quiet --staged; then
    markers+=*
  fi

  if git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null |
    read behind ahead; then
    git fetch --no-write-fetch-head >/dev/null 2>&1 &|

    if [ $ahead -gt 0 ]; then
      markers+=^
    fi

    if [ $behind -gt 0 ]; then
      markers+=v
    fi
  fi

  echo "$markers"
}

zep-git-status-cancel() {
  if [ -n "$zep_git_status_fd" ]; then
    zle -F $zep_git_status_fd
    exec {zep_git_status_fd}<&-
    unset zep_git_status_fd
  fi
}

zep-git-status-callback() {
  local markers

  read -r -u $1 markers
  zep-git-status-cancel

  if [ "$markers" != "$zep_git_status" ]; then
    zep_git_status=$markers
    zle reset-prompt
  fi
}

zep-git-status-reset() {
  zep-git-status-cancel
  zep_git_status=
}

+vi-git-status() {
  zep-git-status-cancel
  exec {zep_git_status_fd}< <(zep-git-status)
  zle -F $zep_git_status_fd zep-git-status-callback
}

add-zsh-hook chpwd zep-git-status-reset

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

PROMPT='%F{blue}%~%f ${vcs_info_msg_0_}%F{cyan}${zep_git_status:+$zep_git_status }%f%(?..%F{red}[%?]%f )
%F{magenta}$vi_mode%f '

() {
  emulate -L zsh -o no_hist_expand -o extended_glob -o no_prompt_bang -o prompt_percent -o no_prompt_subst -o no_aliases -o no_bg_nice -o typeset_silent
  trap ":" INT
  trap "trap ${(q)__p9k_trapint:--} INT" EXIT
  local -a match reply mbegin mend
  local -i MBEGIN MEND OPTIND
  local MATCH REPLY OPTARG IFS=$' \t\n\0'
  (( ! $+__p9k_instant_prompt_disabled )) || return
  typeset -gi __p9k_instant_prompt_disabled=1 __p9k_instant_prompt_sourced=21
  [[ -t 0 && -t 1 && -t 2 && $ZSH_VERSION == 5.8 && $ZSH_PATCHLEVEL == zsh-5.8-0-g77d203f &&
     $TERM_PROGRAM != 'Hyper' && $+VTE_VERSION == 0 &&
     $POWERLEVEL9K_DISABLE_INSTANT_PROMPT != 'true' &&
     $POWERLEVEL9K_INSTANT_PROMPT != 'off' ]] || { __p9k_instant_prompt_sourced=0; return 1; }
  local -i ZLE_RPROMPT_INDENT=1
  local PROMPT_EOL_MARK=%B%S%\#%s%b
  [[ -n $SSH_CLIENT || -n $SSH_TTY || -n $SSH_CONNECTION ]] && local ssh=1 || local ssh=0
  local cr=$'\r' lf=$'\n' esc=$'\e[' rs=$'\x1e' us=$'\x1f'
  local -i height=1
  local prompt_dir=/Users/pwamsley/.cache/p10k-pwamsley

  zmodload zsh/langinfo
  if [[ $langinfo[CODESET] != (utf|UTF)(-|)8 ]]; then
    local loc_cmd=$commands[locale]
    [[ -z $loc_cmd ]] && loc_cmd=/usr/bin/locale
    if [[ -x $loc_cmd ]]; then
      local -a locs
      if locs=(${(@M)$(locale -a 2>/dev/null):#*.(utf|UTF)(-|)8}) && (( $#locs )); then
        local loc=${locs[(r)(#i)C.UTF(-|)8]:-${locs[(r)(#i)en_US.UTF(-|)8]:-$locs[1]}}
        [[ -n $LC_ALL ]] && local LC_ALL=$loc || local LC_CTYPE=$loc
      fi
    fi
  fi
  zmodload zsh/terminfo
  (( $+terminfo[cuu] && $+terminfo[cuf] && $+terminfo[ed] && $+terminfo[sc] && $+terminfo[rc] )) || return
  local pwd=${(%):-%/}
  local prompt_file=$prompt_dir/prompt-${#pwd}
  local key=$pwd:$ssh:${(%):-%#}
  local content
  { content="$(<$prompt_file)" } 2>/dev/null || return
  local tail=${content##*$rs$key$us}
  [[ ${#tail} != ${#content} ]] || return
  local P9K_PROMPT=instant
  if (( ! $+P9K_TTY )); then

    typeset -gx P9K_TTY=old
    zmodload -F zsh/stat b:zstat
    zmodload zsh/datetime
    local -a stat
    if zstat -A stat +ctime -- $TTY 2>/dev/null &&
      (( EPOCHREALTIME - stat[1] < 5.0000000000 )); then
      P9K_TTY=new
    fi
  fi
  local -i _p9k__empty_line_i=3 _p9k__ruler_i=3
  local -A _p9k_display_k=(-1/right/background_jobs 25 -1/right/terraform 63 -1/right/nodenv 39 1/right/plenv 55 1/right/nvm 41 1/right/background_jobs 25 -1/right/plenv 55 1/right/direnv 27 1/right/timewarrior 93 1/right/rvm 47 1/right/midnight_commander 85 -1/right 13 -1/right/aws_eb_env 67 1/right/vim_shell 83 -1/right/google_app_cred 73 1/right/nnn 81 1/right/google_app_cred 73 1/right/asdf 29 -1/left/vcs 19 -1/right/midnight_commander 85 1/right/nordvpn 77 -1/right/asdf 29 1/left/dir 17 -1/right/ranger 79 1/right/rbenv 45 1/right/terraform 63 1/right/nodenv 39 -1/right/rbenv 45 -1/left 11 1/right/virtualenv 31 -1/right/vi_mode 89 -1/right/kubecontext 61 1/right_frame 9 1/right 13 1/right/pyenv 35 -1/right/fvm 49 1/right/nodeenv 43 1/right/goenv 37 -1/right/pyenv 35 -1/right/goenv 37 1/right/haskell_stack 59 -1/right/taskwarrior 95 1/right/ranger 79 1/right/jenv 53 1/right/aws 65 -1/right/nix_shell 87 -1/right/jenv 53 empty_line 1 1/right/todo 91 -1/right/nvm 41 -1/right/todo 91 1/right/context 75 -1 5 1/left 11 -1/right/rvm 47 1/right/azure 69 -1/right_frame 9 -1/gap 15 -1/right/azure 69 -1/right/nordvpn 77 1/right/aws_eb_env 67 1/left/vcs 19 1/right/time 97 -1/right/gcloud 71 -1/right/nnn 81 1/right/kubecontext 61 -1/right/time 97 1/right/anaconda 33 -1/right/status 21 1/right/nix_shell 87 1/left_frame 7 1 5 -1/right/luaenv 51 ruler 3 -1/left_frame 7 -1/right/phpenv 57 1/gap 15 1/right/command_execution_time 23 -1/right/nodeenv 43 1/right/taskwarrior 95 -1/right/timewarrior 93 -1/right/virtualenv 31 -1/left/dir 17 1/right/gcloud 71 1/right/status 21 -1/right/aws 65 -1/right/command_execution_time 23 -1/right/direnv 27 -1/right/context 75 -1/right/haskell_stack 59 1/right/vi_mode 89 1/right/luaenv 51 -1/right/vim_shell 83 1/right/phpenv 57 1/right/fvm 49 -1/right/anaconda 33)
  local -a _p9k__display_v=(empty_line hide ruler hide 1 show 1/left_frame show 1/right_frame show 1/left show 1/right show 1/gap show 1/left/dir show 1/left/vcs show 1/right/status show 1/right/command_execution_time show 1/right/background_jobs show 1/right/direnv show 1/right/asdf show 1/right/virtualenv show 1/right/anaconda show 1/right/pyenv show 1/right/goenv show 1/right/nodenv show 1/right/nvm show 1/right/nodeenv show 1/right/rbenv show 1/right/rvm show 1/right/fvm show 1/right/luaenv show 1/right/jenv show 1/right/plenv show 1/right/phpenv show 1/right/haskell_stack show 1/right/kubecontext show 1/right/terraform show 1/right/aws show 1/right/aws_eb_env show 1/right/azure show 1/right/gcloud show 1/right/google_app_cred show 1/right/context show 1/right/nordvpn show 1/right/ranger show 1/right/nnn show 1/right/vim_shell show 1/right/midnight_commander show 1/right/nix_shell show 1/right/vi_mode show 1/right/todo show 1/right/timewarrior show 1/right/taskwarrior show 1/right/time show)
  function p10k() {
    emulate -L zsh -o no_hist_expand -o extended_glob -o no_prompt_bang -o prompt_percent -o no_prompt_subst -o no_aliases -o no_bg_nice -o typeset_silent
  trap ":" INT
  trap "trap ${(q)__p9k_trapint:--} INT" EXIT
  local -a match reply mbegin mend
  local -i MBEGIN MEND OPTIND
  local MATCH REPLY OPTARG IFS=$' \t\n\0'; [[ $langinfo[CODESET] != (utf|UTF)(-|)8 ]] && _p9k_init_locale && { [[ -n $LC_ALL ]] && local LC_ALL=$__p9k_locale || local LC_CTYPE=$__p9k_locale }
    [[ $1 == display ]] || return
    shift
    local -i k dump
    local opt prev new pair list name var
    while getopts ":ha" opt; do
      case $opt in
        a) dump=1;;
        h) return 0;;
        ?) return 1;;
      esac
    done
    if (( dump )); then
      reply=()
      shift $((OPTIND-1))
      (( ARGC )) || set -- "*"
      for opt; do
        for k in ${(u@)_p9k_display_k[(I)$opt]:/(#m)*/$_p9k_display_k[$MATCH]}; do
          reply+=($_p9k__display_v[k,k+1])
        done
      done
      return 0
    fi
    for opt in "${@:$OPTIND}"; do
      pair=(${(s:=:)opt})
      list=(${(s:,:)${pair[2]}})
      if [[ ${(b)pair[1]} == $pair[1] ]]; then
        local ks=($_p9k_display_k[$pair[1]])
      else
        local ks=(${(u@)_p9k_display_k[(I)$pair[1]]:/(#m)*/$_p9k_display_k[$MATCH]})
      fi
      for k in $ks; do
        if (( $#list == 1 )); then
          [[ $_p9k__display_v[k+1] == $list[1] ]] && continue
          new=$list[1]
        else
          new=${list[list[(I)$_p9k__display_v[k+1]]+1]:-$list[1]}
          [[ $_p9k__display_v[k+1] == $new ]] && continue
        fi
        _p9k__display_v[k+1]=$new
        name=$_p9k__display_v[k]
        if [[ $name == (empty_line|ruler) ]]; then
          var=_p9k__${name}_i
          [[ $new == hide ]] && typeset -gi $var=3 || unset $var
        elif [[ $name == (#b)(<->)(*) ]]; then
          var=_p9k__${match[1]}${${${${match[2]//\/}/#left/l}/#right/r}/#gap/g}
          [[ $new == hide ]] && typeset -g $var= || unset $var
        fi
      done
    done
  }

  local _p9k__1rkubecontext=
  _p9k__display_v[62]=hide

  local _p9k__1raws=
  _p9k__display_v[66]=hide

  local _p9k__1razure=
  _p9k__display_v[70]=hide

  local _p9k__1rgcloud=
  _p9k__display_v[72]=hide

  local _p9k__1rgoogle_app_cred=
  _p9k__display_v[74]=hide

  trap "unset -m _p9k__\*; unfunction p10k" EXIT
  local -a _p9k_t=("${(@ps:$us:)${tail%%$rs*}}")
  typeset -ga __p9k_used_instant_prompt=("${(@e)_p9k_t[-3,-1]}")

  (( height += ${#${__p9k_used_instant_prompt[1]//[^$lf]}} ))
  local _p9k__ret
  function _p9k_prompt_length() {
    local COLUMNS=1024
    local -i x y=$#1 m
    if (( y )); then
      while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
        x=y
        (( y *= 2 ));
      done
      local xy
      while (( y > x + 1 )); do
        m=$(( x + (y - x) / 2 ))
        typeset ${${(%):-$1%$m(l.x.y)}[-1]}=$m
      done
    fi
    _p9k__ret=$x
  }
  local out

  local mark=${(e)PROMPT_EOL_MARK}
  [[ $mark == "%B%S%#%s%b" ]] && _p9k__ret=1 || _p9k_prompt_length $mark
  local -i fill=$((COLUMNS > _p9k__ret ? COLUMNS - _p9k__ret : 0))
  out+="${(%):-%b%k%f%s%u$mark${(pl.$fill.. .)}$cr%b%k%f%s%u%E}"

  out+="${(pl.$height..$lf.)}$esc${height}A$terminfo[sc]"
  out+=${(%):-"$__p9k_used_instant_prompt[1]$__p9k_used_instant_prompt[2]"}
  if [[ -n $__p9k_used_instant_prompt[3] ]]; then
    _p9k_prompt_length "$__p9k_used_instant_prompt[2]"
    local -i left_len=_p9k__ret
    _p9k_prompt_length "$__p9k_used_instant_prompt[3]"
    local -i gap=$((COLUMNS - left_len - _p9k__ret - ZLE_RPROMPT_INDENT))
    if (( gap >= 40 )); then
      out+="${(pl.$gap.. .)}${(%):-${__p9k_used_instant_prompt[3]}%b%k%f%s%u}$cr$esc${left_len}C"
    fi
  fi
  typeset -g __p9k_instant_prompt_output=${TMPDIR:-/tmp}/p10k-instant-prompt-output-${(%):-%n}-$$
  { echo -n > $__p9k_instant_prompt_output } || return
  print -rn -- "$out" || return
  exec {__p9k_fd_0}<&0 {__p9k_fd_1}>&1 {__p9k_fd_2}>&2 0</dev/null 1>$__p9k_instant_prompt_output
  exec 2>&1
  typeset -gi __p9k_instant_prompt_active=1
  typeset -g __p9k_instant_prompt_dump_file=${XDG_CACHE_HOME:-~/.cache}/p10k-dump-${(%):-%n}.zsh
  if source $__p9k_instant_prompt_dump_file 2>/dev/null && (( $+functions[_p9k_preinit] )); then
    _p9k_preinit
  fi
  function _p9k_instant_prompt_precmd_first() {
    emulate -L zsh -o no_hist_expand -o extended_glob -o no_prompt_bang -o prompt_percent -o no_prompt_subst -o no_aliases -o no_bg_nice -o typeset_silent
  trap ":" INT
  trap "trap ${(q)__p9k_trapint:--} INT" EXIT
  local -a match reply mbegin mend
  local -i MBEGIN MEND OPTIND
  local MATCH REPLY OPTARG IFS=$' \t\n\0'; [[ $langinfo[CODESET] != (utf|UTF)(-|)8 ]] && _p9k_init_locale && { [[ -n $LC_ALL ]] && local LC_ALL=$__p9k_locale || local LC_CTYPE=$__p9k_locale }
    function _p9k_instant_prompt_sched_last() {
      (( $+__p9k_instant_prompt_active )) || return 0
      () {
        emulate -L zsh -o no_hist_expand -o extended_glob -o no_prompt_bang -o prompt_percent -o no_prompt_subst -o no_aliases -o no_bg_nice -o typeset_silent
  trap ":" INT
  trap "trap ${(q)__p9k_trapint:--} INT" EXIT
  local -a match reply mbegin mend
  local -i MBEGIN MEND OPTIND
  local MATCH REPLY OPTARG IFS=$' \t\n\0'; [[ $langinfo[CODESET] != (utf|UTF)(-|)8 ]] && _p9k_init_locale && { [[ -n $LC_ALL ]] && local LC_ALL=$__p9k_locale || local LC_CTYPE=$__p9k_locale }
        exec 0<&$__p9k_fd_0 1>&$__p9k_fd_1 2>&$__p9k_fd_2 {__p9k_fd_0}>&- {__p9k_fd_1}>&- {__p9k_fd_2}>&-
        unset __p9k_fd_0 __p9k_fd_1 __p9k_fd_2 __p9k_instant_prompt_active
        typeset -gi __p9k_instant_prompt_erased=1
        print -rn -- $terminfo[rc]${(%):-%b%k%f%s%u}$terminfo[ed]
        if [[ -s $__p9k_instant_prompt_output ]]; then
          cat $__p9k_instant_prompt_output 2>/dev/null
          local _p9k__ret mark="${(e)${PROMPT_EOL_MARK-%B%S%#%s%b}}"
          _p9k_prompt_length $mark
          local -i fill=$((COLUMNS > _p9k__ret ? COLUMNS - _p9k__ret : 0))
          echo -nE - "${(%):-%b%k%f%s%u$mark${(pl.$fill.. .)}$cr%b%k%f%s%u%E}"
        fi
        zmodload -F zsh/files b:zf_rm
        zf_rm -f -- $__p9k_instant_prompt_output ${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh{,.zwc} 2>/dev/null
      }
      setopt no_local_options prompt_cr prompt_sp
    }
    zmodload zsh/sched
    sched +0 _p9k_instant_prompt_sched_last
    precmd_functions=(${(@)precmd_functions:#_p9k_instant_prompt_precmd_first})
  }
  precmd_functions=(_p9k_instant_prompt_precmd_first $precmd_functions)
  DISABLE_UPDATE_PROMPT=true
} && unsetopt prompt_cr prompt_sp || true

# custom prompt

RED="\033[0;31m"
PINK="\033[1;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
LT_GREEN="\033[1;32m"
BLUE="\033[0;34m"
WHITE="\033[1;37m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
BROWN="\033[0;33m"
COLOR_NONE="\033[0m"

LIGHTNING_BOLT="⚡"
UP_ARROW="↑"
DOWN_ARROW="↓"
UD_ARROW="↕"
FF_ARROW="→"
RECYCLE="♺"
MIDDOT="•"
PLUSMINUS="±"
CURRENCY_GENERIC="¤"


function parse_git_branch {
    branch_pattern="^# On branch ([^${IFS}]*)"
    remote_pattern_ahead="# Your branch is ahead of"
    remote_pattern_behind="# Your branch is behind"
    remote_pattern_ff="# Your branch (.*) can be fast-forwarded."
    diverge_pattern="# Your branch and (.*) have diverged"

    git_status="$(git status 2> /dev/null)"
    if [[ ! ${git_status} =~ ${branch_pattern} ]]; then
        # Rebasing?
        toplevel=$(git rev-parse --show-toplevel 2> /dev/null)
        [[ -z "$toplevel" ]] && return

        [[ -d "$toplevel/.git/rebase-merge" || -d "$toplevel/.git/rebase-apply" ]] && {
            sha_file="$toplevel/.git/rebase-merge/stopped-sha"
            [[ -e "$sha_file" ]] && {
                sha=`cat "${sha_file}"`
            }
            echo -e "${PINK}(rebase in progress)${COLOR_NONE} ${sha}"
        }
        return
  fi

  branch=${BASH_REMATCH[1]}

  # Dirty?
  if [[ ! ${git_status} =~ "working directory clean" ]]; then
      [[ ${git_status} =~ "modified:" ]] && {
          git_is_dirty="${RED}${LIGHTNING_BOLT}"
      }

      # [[ ${git_status} =~ "Untracked files" ]] && {
      #     git_is_dirty="${git_is_dirty}${WHITE}${MIDDOT}"
      # }

      [[ ${git_status} =~ "new file:" ]] && {
          git_is_dirty="${git_is_dirty}${LT_GREEN}+"
      }

      [[ ${git_status} =~ "deleted:" ]] && {
          git_is_dirty="${git_is_dirty}${RED}-"
      }

      [[ ${git_status} =~ "renamed:" ]] && {
          git_is_dirty="${git_is_dirty}${YELLOW}→"
      }
  fi

  # Are we ahead of, beind, or diverged from the remote?
  if [[ ${git_status} =~ ${remote_pattern_ahead} ]]; then
      remote="${YELLOW}${UP_ARROW}"
  elif [[ ${git_status} =~ ${remote_pattern_ff} ]]; then
      remote_ff="${WHITE}${FF_ARROW}"
  elif [[ ${git_status} =~ ${remote_pattern_behind} ]]; then
      remote="${YELLOW}${DOWN_ARROW}"
  elif [[ ${git_status} =~ ${diverge_pattern} ]]; then
      remote="${YELLOW}${UD_ARROW}"
  fi

  echo -e "(${GREEN}${branch}${remote}${remote_ff}${COLOR_NONE}${git_is_dirty}${COLOR_NONE})"
}

git_current_info=""
function set_prompt() {
    git_current_info=$(parse_git_branch)
    [ -n "$git_current_info" ] && git_current_info="$git_current_info "
}
PROMPT_COMMAND=set_prompt

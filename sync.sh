#!/usr/bin/env bash
# sync.sh — bring this machine in line with the dotfiles repo without
# clobbering local edits. Safe to run any time; install.sh is for fresh machines.
#
#   ./sync.sh                 report only, changes nothing
#   ./sync.sh --apply         decide, review, then apply everything at once
#   ./sync.sh --apply --no-packages
#   ./sync.sh --show-extras   also list explicitly installed packages not in packages.csv
#
# Configs (config/ -> ~/.config) and scripts (bin/ -> ~/.local/bin) are compared
# three ways using a manifest of what was last synced, so it can tell apart:
#   repo changed      -> machine is updated (old file backed up)
#   machine changed   -> you choose: adopt into repo, or revert to repo
#   both / unknown    -> conflict: you pick the new baseline after seeing the diff
#
# --apply works in two phases:
#   1. decide   all questions are asked first; nothing is written. Ctrl+C here
#               leaves the machine and the repo untouched.
#   2. apply    after you confirm the plan, every change is applied in one go.
#               Ctrl+C is held until it finishes; if any step fails, everything
#               already applied is rolled back and the manifest is not updated.
# Missing packages from data/packages.csv are offered afterwards, separately.
# Nothing is ever uninstalled, and files that exist only on the machine are left alone.
#
# Backups:  $XDG_STATE_HOME/dotfiles-sync/backups/<timestamp>/
# Manifest: $XDG_STATE_HOME/dotfiles-sync/manifest

set -euo pipefail

DOTFILES=${DOTFILES_DIR:-$HOME/.dotfiles}
CONFIG_DEST=${XDG_CONFIG_HOME:-$HOME/.config}
BIN_DEST=$HOME/.local/bin
STATE=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-sync
MANIFEST=$STATE/manifest
BACKUPS=$STATE/backups/$(date +%Y%m%d-%H%M%S)

APPLY=0 DO_PKGS=1 SHOW_EXTRAS=0
for arg in "$@"; do
  case $arg in
    --apply) APPLY=1 ;;
    --no-packages) DO_PKGS=0 ;;
    --show-extras) SHOW_EXTRAS=1 ;;
    -h | --help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg (see --help)" >&2; exit 1 ;;
  esac
done

[[ -d $DOTFILES/config ]] || { echo "no dotfiles repo at $DOTFILES" >&2; exit 1; }

# --- output helpers ---------------------------------------------------------
if [[ -t 1 ]]; then
  c_ok=$'\e[32m' c_upd=$'\e[36m' c_warn=$'\e[33m' c_bad=$'\e[31m' c_dim=$'\e[2m' c_off=$'\e[0m'
else
  c_ok='' c_upd='' c_warn='' c_bad='' c_dim='' c_off=''
fi
section() { printf '\n==> %s\n' "$1"; }
line() { printf '  %s%-9s%s %s\n' "$1" "$2" "$c_off" "$3"; }
tilde() { printf '%s' "${1/#$HOME/\~}"; }

interactive() { [[ -t 0 && -t 1 ]]; }
use_gum() { command -v gum >/dev/null && [[ -z ${NO_GUM:-} ]]; }

abort() { printf '\n%s\n' "Aborted. Nothing was changed." >&2; exit 130; }
# Phase 1: an interrupt just stops; nothing has been written yet.
trap abort INT TERM

# choose "question" option...  -> prints the chosen option; non-zero on Ctrl+C / EOF
choose() {
  local q=$1; shift
  if use_gum; then
    gum choose --header "$q" "$@"
  else
    local PS3="$q "
    select opt in "$@"; do [[ -n ${opt:-} ]] && { printf '%s\n' "$opt"; return 0; }; done
    return 1 # EOF
  fi
}

confirm() {
  if use_gum; then
    gum confirm "$1"
  else
    local r; read -rp "$1 [y/N] " r || return 1; [[ $r == [yY]* ]]
  fi
}

# Show a diff between two files. Uses delta (side by side when the terminal is
# wide enough, scrollable in a pager) if installed, plain git diff otherwise.
show_diff() {
  if command -v delta >/dev/null; then
    local sbs=()
    (( $(tput cols 2>/dev/null || echo 80) >= 140 )) && sbs=(--side-by-side)
    delta "${sbs[@]}" --line-numbers --paging=always -- "$1" "$2" || true
  else
    git --no-pager diff --no-index --color=auto -- "$1" "$2" || true
  fi
}
filehash() { sha256sum "$1" | cut -d' ' -f1; }

# --- manifest ---------------------------------------------------------------
declare -A base=() newbase=()
if [[ -f $MANIFEST ]]; then
  while read -r h p; do [[ -n $p ]] && base[$p]=$h; done <"$MANIFEST"
fi

# --- the plan ---------------------------------------------------------------
# Each planned action: op | rel | src | dst | exec | description
#   copy   src -> dst      (repo -> machine; dst backed up if it exists)
#   adopt  dst -> src      (machine -> repo; repo file backed up)
#   link   ln -s src dst   (dst backed up if it exists)
p_op=() p_rel=() p_src=() p_dst=() p_exec=() p_desc=()
plan() {
  p_op+=("$1") p_rel+=("$2") p_src+=("$3") p_dst+=("$4") p_exec+=("$5") p_desc+=("$6")
}

declare -i n_ok=0 n_conf=0 n_skip=0

# decide rel src dst is_exec kind   (kind: local | conflict)
decide() {
  local rel=$1 src=$2 dst=$3 is_exec=$4 kind=$5
  local keep_base=${base[$rel]:-}
  [[ -n $keep_base ]] && newbase[$rel]=$keep_base

  if (( ! APPLY )); then n_skip+=1; return 0; fi
  if ! interactive; then
    echo "     not a terminal, skipping (run --apply in a terminal to decide)"
    n_skip+=1; return 0
  fi

  local to_machine="Use repo version (overwrite machine, backup kept)"
  local to_repo="Keep machine version (copy into repo as new baseline)"
  local view="Show diff (repo -> machine)" skip="Skip for now"
  local opts=("$to_machine" "$to_repo" "$view" "$skip") ans
  [[ $kind == local ]] && opts=("$to_repo" "$to_machine" "$view" "$skip")

  while :; do
    ans=$(choose "$rel:" "${opts[@]}") || abort
    case $ans in
      "$to_machine")
        plan copy "$rel" "$src" "$dst" "$is_exec" "repo -> machine   $rel"
        newbase[$rel]=$(filehash "$src"); return 0 ;;
      "$to_repo")
        plan adopt "$rel" "$src" "$dst" 0 "machine -> repo   $rel"
        newbase[$rel]=$(filehash "$dst"); return 0 ;;
      "$view") show_diff "$src" "$dst" ;;
      *) n_skip+=1; return 0 ;;
    esac
  done
}

# scan_file rel src dst is_exec
scan_file() {
  local rel=$1 src=$2 dst=$3 is_exec=$4 hs hd b

  # Already a symlink to the repo file: nothing to sync.
  if [[ -L $dst && $(readlink -f "$dst") == "$(readlink -f "$src")" ]]; then
    newbase[$rel]=$(filehash "$src"); n_ok+=1; return 0
  fi

  hs=$(filehash "$src")
  if [[ ! -e $dst ]]; then
    line "$c_upd" new "$rel"
    plan copy "$rel" "$src" "$dst" "$is_exec" "new               $rel"
    newbase[$rel]=$hs; return 0
  fi

  hd=$(filehash "$dst")
  if [[ $hs == "$hd" ]]; then newbase[$rel]=$hs; n_ok+=1; return 0; fi

  b=${base[$rel]:-}
  if [[ -n $b && $b == "$hd" ]]; then
    line "$c_upd" update "$rel  ${c_dim}(changed in repo)${c_off}"
    plan copy "$rel" "$src" "$dst" "$is_exec" "repo -> machine   $rel"
    newbase[$rel]=$hs
  elif [[ -n $b && $b == "$hs" ]]; then
    line "$c_warn" local "$rel  ${c_dim}(edited on this machine)${c_off}"
    decide "$rel" "$src" "$dst" "$is_exec" local
  else
    local why="no sync record yet"; [[ -n $b ]] && why="changed on both sides"
    line "$c_bad" conflict "$rel  ${c_dim}($why)${c_off}"
    n_conf+=1
    decide "$rel" "$src" "$dst" "$is_exec" conflict
  fi
}

# ===========================================================================
# Phase 1: scan and decide (nothing is written)
# ===========================================================================
section "Configs ($(tilde "$DOTFILES")/config -> $(tilde "$CONFIG_DEST"))"
# Read the file list on fd 3 so prompts inside the loop still get the terminal on stdin.
while IFS= read -r -d '' f <&3; do
  rel=${f#"$DOTFILES/"}
  # zsh/.zshrc is a symlink into the repo, handled under Links.
  [[ $rel == config/zsh/.zshrc ]] && continue
  scan_file "$rel" "$f" "$CONFIG_DEST/${rel#config/}" 0
done 3< <(find "$DOTFILES/config" -type f -print0 | sort -z)

section "Scripts ($(tilde "$DOTFILES")/bin -> $(tilde "$BIN_DEST"))"
while IFS= read -r -d '' f <&3; do
  rel=${f#"$DOTFILES/"}
  scan_file "$rel" "$f" "$BIN_DEST/${rel#bin/}" 1
done 3< <(find "$DOTFILES/bin" -type f -print0 | sort -z)

if [[ -d $BIN_DEST ]]; then
  extra=()
  for f in "$BIN_DEST"/*; do
    [[ -f $f && ! -L $f && ! -e $DOTFILES/bin/${f##*/} ]] && extra+=("${f##*/}")
  done
  (( ${#extra[@]} )) && line "$c_dim" info "only on this machine, not in repo: ${extra[*]}"
fi
(( n_ok )) && line "$c_ok" ok "$n_ok files already in sync"

# --- links (keep in step with scripts/config.sh) ----------------------------
section "Links"
check_link() { # link target
  local link=$1 target=$2 name ans
  name=$(tilde "$link")
  if [[ -L $link && $(readlink -f "$link") == "$(readlink -f "$target")" ]]; then
    return 0
  elif [[ ! -e $target ]]; then
    line "$c_warn" skip "$name: link target $(tilde "$target") does not exist"
  elif [[ ! -e $link && ! -L $link ]]; then
    line "$c_upd" missing "$name -> $(tilde "$target")"
    plan link "" "$target" "$link" 0 "link              $name -> $(tilde "$target")"
  elif [[ -L $link ]]; then
    line "$c_warn" relink "$name points to $(readlink "$link"), should be $(tilde "$target")"
    plan link "" "$target" "$link" 0 "relink            $name -> $(tilde "$target")"
  elif cmp -s "$link" "$target"; then
    line "$c_upd" link "$name is a plain copy, identical; will be replaced with a link"
    plan link "" "$target" "$link" 0 "copy -> link      $name -> $(tilde "$target")"
  else
    line "$c_bad" conflict "$name is a regular file that differs from $(tilde "$target")"
    n_conf+=1
    if (( APPLY )) && interactive; then
      while :; do
        ans=$(choose "$name:" "Replace with link (backup kept)" "Show diff (link target -> file)" "Skip for now") || abort
        case $ans in
          "Replace with link"*)
            plan link "" "$target" "$link" 0 "file -> link      $name -> $(tilde "$target")"; break ;;
          "Show diff"*) show_diff "$target" "$link" ;;
          *) n_skip+=1; break ;;
        esac
      done
    else
      n_skip+=1
    fi
  fi
}
check_link "$HOME/.xprofile" "$CONFIG_DEST/x11/xprofile"
check_link "$HOME/.zprofile" "$CONFIG_DEST/shell/profile"
check_link "$CONFIG_DEST/zsh/.zshrc" "$DOTFILES/config/zsh/.zshrc"
check_link "$HOME/.zshrc" "$DOTFILES/config/zsh/.zshrc"
check_link "$HOME/.ssh/config" "$CONFIG_DEST/ssh/config"

# --- system files (report only) ---------------------------------------------
section "System files (report only)"
if [[ -f $DOTFILES/data/pacman.conf ]] && ! cmp -s "$DOTFILES/data/pacman.conf" /etc/pacman.conf; then
  line "$c_warn" differs "/etc/pacman.conf vs data/pacman.conf  ${c_dim}(git diff --no-index /etc/pacman.conf $(tilde "$DOTFILES")/data/pacman.conf)${c_off}"
else
  line "$c_ok" ok "/etc/pacman.conf"
fi

# --- packages: work out what is missing (installed after the files) ---------
missing=()
if (( DO_PKGS )); then
  section "Packages ($(tilde "$DOTFILES")/data/packages.csv)"
  mapfile -t want < <(awk -F, 'NR > 1 && $1 != "" { print $1 }' "$DOTFILES/data/packages.csv")
  # pacman -T prints the ones not satisfied (understands provides, e.g. AUR -bin packages)
  mapfile -t missing < <(pacman -T "${want[@]}" 2>/dev/null || true)
  if (( ${#missing[@]} == 0 )); then
    line "$c_ok" ok "all ${#want[@]} packages installed"
  else
    line "$c_upd" missing "${missing[*]}"
  fi
  if (( SHOW_EXTRAS )); then
    mapfile -t extras < <(comm -23 <(pacman -Qqe | sort) <(printf '%s\n' "${want[@]}" | sort))
    line "$c_dim" info "explicitly installed but not in packages.csv (${#extras[@]}):"
    printf '    %s\n' "${extras[@]}" | column -c "${COLUMNS:-100}"
  fi
fi

# ===========================================================================
# The plan
# ===========================================================================
n_plan=${#p_op[@]}
section "Plan"
if (( n_plan == 0 )); then
  line "$c_ok" none "no file or link changes"
else
  for ((i = 0; i < n_plan; i++)); do printf '  %s\n' "${p_desc[i]}"; done
fi
printf '\n  in sync %d · planned changes %d · conflicts %d · skipped %d\n' "$n_ok" "$n_plan" "$n_conf" "$n_skip"

if (( ! APPLY )); then
  echo "  Report only. Run with --apply to decide and apply."
  exit 0
fi

# ===========================================================================
# Phase 2: apply all-or-nothing
# ===========================================================================
if (( n_plan > 0 )) && interactive; then
  confirm "Apply these $n_plan change(s)?" || abort
fi

# Each applied step is recorded so it can be undone if a later step fails.
# cur_existed / cur_backed describe the step in progress, so a step that fails
# half-way can be undone too.
done_steps=()
cur_existed=0 cur_backed=0

backup_to() { # file backup-relative-path
  mkdir -p "$BACKUPS/$(dirname "$2")" && cp -P -p "$1" "$BACKUPS/$2"
}

apply_one() { # index
  local i=$1
  local op=${p_op[i]} src=${p_src[i]} dst=${p_dst[i]}
  local mb="machine/${dst#"$HOME"/}" rb="repo/${p_rel[i]}"
  cur_existed=0 cur_backed=0
  case $op in
    copy | link)
      if [[ -e $dst || -L $dst ]]; then
        cur_existed=1; backup_to "$dst" "$mb" || return 1; cur_backed=1
      fi
      mkdir -p "$(dirname "$dst")" || return 1
      if [[ $op == copy ]]; then
        cp "$src" "$dst" || return 1
        if (( p_exec[i] )); then chmod +x "$dst" || return 1; fi
      else
        ln -sfn "$src" "$dst" || return 1
      fi ;;
    adopt)
      cur_existed=1; backup_to "$src" "$rb" || return 1; cur_backed=1
      cp "$dst" "$src" || return 1 ;;
  esac
  done_steps+=("$i")
}

undo_one() { # index existed backed
  local i=$1 existed=$2 backed=$3
  local op=${p_op[i]} src=${p_src[i]} dst=${p_dst[i]}
  local mb="machine/${dst#"$HOME"/}" rb="repo/${p_rel[i]}"
  case $op in
    copy | link)
      if (( existed && backed )); then rm -f "$dst" && cp -P -p "$BACKUPS/$mb" "$dst"
      elif (( ! existed )); then rm -f "$dst"
      fi ;; # existed but backup failed: dst was never touched
    adopt)
      if (( backed )); then cp -p "$BACKUPS/$rb" "$src"; fi ;;
  esac
}

rollback() { # failed-index
  local j k
  echo "  ${c_bad}A step failed, rolling back...${c_off}" >&2
  undo_one "$1" "$cur_existed" "$cur_backed" || echo "  could not undo: ${p_desc[$1]}" >&2
  for ((j = ${#done_steps[@]} - 1; j >= 0; j--)); do
    k=${done_steps[j]}
    if [[ ${p_op[k]} == adopt ]]; then
      undo_one "$k" 1 1
    elif [[ -e $BACKUPS/machine/${p_dst[k]#"$HOME"/} || -L $BACKUPS/machine/${p_dst[k]#"$HOME"/} ]]; then
      undo_one "$k" 1 1
    else
      undo_one "$k" 0 0
    fi || echo "  could not undo: ${p_desc[k]}" >&2
  done
  echo "  Rolled back. Manifest not updated. Backups kept in $(tilde "$BACKUPS")" >&2
  exit 1
}

if (( n_plan > 0 )); then
  section "Applying"
  # Ignore Ctrl+C until the whole plan is applied, so it can't stop half-way.
  # (Ignored, not caught: the ignore is inherited by cp/ln, so they can't be
  # killed mid-copy either.)
  echo "  ${c_dim}(Ctrl+C is ignored until this finishes)${c_off}"
  trap '' INT TERM
  set +e
  for ((i = 0; i < n_plan; i++)); do
    if apply_one "$i"; then
      printf '  %sdone%s     %s\n' "$c_ok" "$c_off" "${p_desc[i]}"
    else
      printf '  %sfailed%s   %s\n' "$c_bad" "$c_off" "${p_desc[i]}" >&2
      rollback "$i"
    fi
  done
  set -e
fi

# Save the manifest atomically, only after every change succeeded.
mkdir -p "$STATE"
for p in "${!newbase[@]}"; do printf '%s %s\n' "${newbase[$p]}" "$p"; done | sort -k2 >"$MANIFEST.tmp"
mv "$MANIFEST.tmp" "$MANIFEST"
trap abort INT TERM

if [[ -d $BACKUPS ]]; then echo "  Backups: $(tilde "$BACKUPS")"; fi
for ((i = 0; i < n_plan; i++)); do
  if [[ ${p_op[i]} == adopt ]]; then
    echo "  Machine versions were copied into the repo: review with 'git -C $(tilde "$DOTFILES") diff' and commit."
    break
  fi
done

# --- packages: separate step, after the files are done ----------------------
if (( DO_PKGS && ${#missing[@]} )); then
  section "Packages"
  if ! interactive; then
    echo "  not a terminal, skipping package install"
  elif ! command -v yay >/dev/null; then
    echo "  yay not found, install with: sudo pacman -Syu --needed ${missing[*]}"
  elif confirm "Install ${#missing[@]} package(s): ${missing[*]}? This also upgrades the system (-Syu)."; then
    yay -Syu --needed "${missing[@]}"
  else
    echo "  skipped"
  fi
fi

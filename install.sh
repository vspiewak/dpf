#!/usr/bin/env bash

{ # this ensures the entire script is downloaded #

dpf_has() {
  type "$1" > /dev/null 2>&1
}

dpf_install_dir() {
  echo "${HOME}/.dpf"
}

dpf_source() {
  echo "https://raw.githubusercontent.com/vspiewak/dpf/master/dpf.sh"
}

dpf_download() {
  if dpf_has "curl"; then
    curl --compressed -q "$@"
  elif dpf_has "wget"; then
    # Emulate curl with wget
    ARGS=$(echo "$*" | command sed -e 's/--progress-bar /--progress=bar /' \
                            -e 's/-L //' \
                            -e 's/--compressed //' \
                            -e 's/-I /--server-response /' \
                            -e 's/-s /-q /' \
                            -e 's/-o /-O /' \
                            -e 's/-C - /-c /')
    # shellcheck disable=SC2086
    eval wget ${ARGS}
  fi
}

dpf_try_profile() {
  if [ -z "${1-}" ] || [ ! -f "${1}" ]; then
    return 1
  fi
  echo "${1}"
}

#
# Detect profile file if not specified as environment variable
# (eg: PROFILE=~/.myprofile)
# The echo'ed path is guaranteed to be an existing file
# Otherwise, an empty string is returned
#
dpf_detect_profile() {
  if [ "${PROFILE-}" = '/dev/null' ]; then
    # the user has specifically requested NOT to have nvm touch their profile
    return
  fi

  if [ -n "${PROFILE}" ] && [ -f "${PROFILE}" ]; then
    echo "${PROFILE}"
    return
  fi

  local DETECTED_PROFILE
  DETECTED_PROFILE=''

  if [ -n "${BASH_VERSION-}" ]; then
    if [ -f "${HOME}/.bashrc" ]; then
      DETECTED_PROFILE="${HOME}/.bashrc"
    elif [ -f "${HOME}/.bash_profile" ]; then
      DETECTED_PROFILE="${HOME}/.bash_profile"
    fi
  elif [ -n "${ZSH_VERSION-}" ]; then
    DETECTED_PROFILE="${HOME}/.zshrc"
  fi

  if [ -z "${DETECTED_PROFILE}" ]; then
    for EACH_PROFILE in ".profile" ".bashrc" ".bash_profile" ".zshrc"
    do
      if DETECTED_PROFILE="$(dpf_try_profile "${HOME}/${EACH_PROFILE}")"; then
        break
      fi
    done
  fi

  if [ -n "${DETECTED_PROFILE}" ]; then
    echo "${DETECTED_PROFILE}"
  fi
}

dpf_do_install() {

  local YELLOW
  YELLOW='\033[0;33m'
  local BLUE
  BLUE='\033[0;34m'
  local GREY
  GREY='\033[0;90m'
  local NC
  NC='\033[0m'

  local INSTALL_DIR
  INSTALL_DIR="$(dpf_install_dir)"

  local SOURCE_URL
  SOURCE_URL="$(dpf_source)"

  echo -e "${GREY}[1/6]${NC} 🚧 Creating directory"
  mkdir -p "${INSTALL_DIR}"

  echo -e "${GREY}[2/6]${NC} 🚚 Downloading script"
  dpf_download -s "${SOURCE_URL}" -o "${INSTALL_DIR}/dpf.sh"
  chmod a+x "${INSTALL_DIR}/dpf.sh"

  echo -e "${GREY}[3/6]${NC} 🔎 Detecting profile"
  local DPF_PROFILE
  DPF_PROFILE="$(dpf_detect_profile)"

  echo -e "${GREY}[4/6]${NC} 📌 Making alias"
  local ALIAS_STR
  ALIAS_STR="alias dpf='~/.dpf/dpf.sh'"

  if [ -z "${DPF_PROFILE-}" ] ; then
    command printf "${YELLOW}warn${NC}  🚨 Profile not found\n"
    command printf "${YELLOW}warn${NC}  💡 Append the following line to the correct file:\n"
    command printf "${YELLOW}warn${NC}\n"
    command printf "${YELLOW}warn${NC}  👉 ${ALIAS_STR}\n"
    command printf "${YELLOW}warn${NC}\n"
  else
    if ! command grep -qc '/dpf.sh' "${DPF_PROFILE}"; then
      command printf "${BLUE}info${NC}  ✏️  Appending alias to ${DPF_PROFILE}\n"
      command printf "\n${ALIAS_STR}\n" >> "${DPF_PROFILE}"
    else
      command printf "${BLUE}info${NC}  ✔️  Alias already in ${DPF_PROFILE}\n"
    fi
  fi

  echo -e "${GREY}[5/6]${NC} 🚿 Cleaning env"
  dpf_reset

  echo -e "${GREY}[6/6]${NC} 🎉 Done"
}

#
# Unsets the various functions defined
# during the execution of the install script
#
dpf_reset() {
  unset -f dpf_has dpf_install_dir dpf_source dpf_download dpf_try_profile dpf_detect_profile dpf_do_install dpf_reset
}

# launch install
dpf_do_install


} # this ensures the entire script is downloaded #

#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`delete\` with no argument exits with 1, prints help, and does not delete." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" delete --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 1
  [[ ${status} -eq 1 ]]

  # Does not delete note file
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  # Does not create git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Delete') ]]

  # Prints help information
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes delete (<id> | <filename> | <path> | <title>) [--force]" ]]
}

# <selector> ##################################################################

@test "\`delete <selector>\` with empty repo exits with 1 and prints message." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" delete 1 --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Note not found." ]]
}

@test "\`delete <selector> (no force)\` returns 0 and deletes note." {
  skip "Determine how to test interactive prompt."
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" delete "${_filename}" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

# <scope>:<selector> ##########################################################

@test "\`delete <scope>:<selector>\` with <filename> argument prints scoped output." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" notebooks add "one"
    run "${_NOTES}" use "one"
    run "${_NOTES}" add
    _filename=$("${_NOTES}" list -n 1 --no-id | head -1)
    echo "\${_filename:-}: ${_filename:-}"
    run "${_NOTES}" use "home"
  }
  [[ -n "${_filename}" ]]
  [[ -e "${NOTES_DIR}/one/${_filename}" ]]

  run "${_NOTES}" delete one:"${_filename}" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${output}" =~ Deleted\ \[one:[A-Za-z0-9]+\]\ one:[A-Za-z0-9]+.md ]]
}

# <filename> ##################################################################

@test "\`delete\` with <filename> argument deletes properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]
  _original_index="$(cat "${NOTES_DATA_DIR}/.index")"

  run "${_NOTES}" delete "${_filename}" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Deletes note file
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]

  # Deletes entry from index
  [[ -e "${NOTES_DATA_DIR}/.index" ]]
  [[ "$(ls "${NOTES_DATA_DIR}")" == "$(cat "${NOTES_DATA_DIR}/.index")" ]]
  [[ "${_original_index}" != "$(cat "${NOTES_DATA_DIR}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Deleted\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

# <id> ########################################################################

@test "\`delete\` with <id> argument deletes properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]
  _original_index="$(cat "${NOTES_DATA_DIR}/.index")"

  run "${_NOTES}" delete 1 --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Deletes note file
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]

  # Deletes entry from index
  [[ -e "${NOTES_DATA_DIR}/.index" ]]
  [[ "$(ls "${NOTES_DATA_DIR}")" == "$(cat "${NOTES_DATA_DIR}/.index")" ]]
  [[ "${_original_index}" != "$(cat "${NOTES_DATA_DIR}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Deleted\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

# <path> ######################################################################

@test "\`delete\` with <path> argument deletes properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]
  _original_index="$(cat "${NOTES_DATA_DIR}/.index")"

  run "${_NOTES}" delete "${NOTES_DATA_DIR}/${_filename}" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Deletes note file
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]

  # Deletes entry from index
  [[ -e "${NOTES_DATA_DIR}/.index" ]]
  [[ "$(ls "${NOTES_DATA_DIR}")" == "$(cat "${NOTES_DATA_DIR}/.index")" ]]
  [[ "${_original_index}" != "$(cat "${NOTES_DATA_DIR}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Deleted\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

# <title> #####################################################################

@test "\`delete\` with <title> argument deletes properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${NOTES_DATA_DIR}/${_filename}" | sed 's/^\# //')"
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]
  _original_index="$(cat "${NOTES_DATA_DIR}/.index")"

  run "${_NOTES}" delete "${_title}" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Deletes note file
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]

  # Deletes entry from index
  [[ -e "${NOTES_DATA_DIR}/.index" ]]
  [[ "$(ls "${NOTES_DATA_DIR}")" == "$(cat "${NOTES_DATA_DIR}/.index")" ]]
  [[ "${_original_index}" != "$(cat "${NOTES_DATA_DIR}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Deleted\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

# help ########################################################################

@test "\`help delete\` exits with status 0." {
  run "${_NOTES}" help delete
  [[ ${status} -eq 0 ]]
}

@test "\`help delete\` prints help information." {
  run "${_NOTES}" help delete
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes delete (<id> | <filename> | <path> | <title>) [--force]" ]]
}

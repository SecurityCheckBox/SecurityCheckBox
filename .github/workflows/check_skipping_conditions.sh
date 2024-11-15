#!/bin/bash

event_name="${1}"
shift
event_input_github_repo="${1}"
shift
matrix_config_enabled="${1}"
shift
matrix_config_github_repo="${1}"
shift

function Do_Analysis() {
  local bool_value="${1}"
  echo "do_analysis=${bool_value}" >>"${GITHUB_ENV}"
  exit 0
}

case "${event_name}" in 
'schedule')
  if [[ "${matrix_config_enabled}" != true ]]; then
    echo "Scheduled analysis disabled for this repo."
    Do_Analysis false
  fi
  last_commit_date="$(
    curl -s "https://api.github.com/repos/${matrix_config_github_repo}/commits?per_page=1" |
      jq -r '.[0].commit.committer.date'
  )"
  # Convert to Unix timestamp for comparison
  last_commit_timestamp=$(date -d "${last_commit_date}" +%s)
  current_timestamp=$(date +%s)
  # Calculate age in days
  age_in_days="$(( (current_timestamp - last_commit_timestamp) / 86400 ))"
  echo "Last commit age: ${age_in_days} days"
  (( age_in_days > 8 )) && Do_Analysis false || Do_Analysis true
;;
'workflow_dispatch')
  case "${event_input_github_repo}" in
  '(all)' | "${matrix_config_github_repo}")
    echo "Manual run for this repo '${event_input_github_repo}'."
    Do_Analysis true
  ;;
  *)
    echo "Manual run for another repo '${event_input_github_repo}'."
    Do_Analysis false
  ;;
  esac
;;
*)
  echo "ERROR: Unexpected GitHub event name '${event_name}'."
  exit 1
;;
esac

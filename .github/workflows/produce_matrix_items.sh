#!/bin/bash

event_name="${1}"
shift
event_input_github_repo="${1}"
shift

function List_Items() {
  cat <<EOF | grep -v '^#'
#                    #                             schedule  requires  JDK      analysis  #
#_GitHub_owner_name  GitHub_repo_name              enabled   Node.js   version  method    [comment]
#------------------  ----------------------------  --------  --------  -------  --------  ---------
Applifting           Humansis                      true      false     0        default   TODO: gradle (kotlin)
cortezaproject       corteza                       true      true      0        default
cortezaproject       corteza-server-corredor       true      true      0        default
getgrav              grav                          true      false     0        default
getgrav              grav-plugin-admin             true      false     0        default
getgrav              grav-plugin-editor-buttons    true      false     0        default
getgrav              grav-plugin-email             true      false     0        default
getgrav              grav-plugin-error             true      false     0        default
getgrav              grav-plugin-featherlight      true      false     0        default
getgrav              grav-plugin-form              true      false     0        default
getgrav              grav-plugin-langswitcher      true      false     0        default
getgrav              grav-plugin-login             true      false     0        default
getgrav              grav-plugin-markdown-notices  true      false     0        default
getgrav              grav-plugin-problems          true      false     0        default
getgrav              grav-plugin-youtube           true      false     0        default
Gnucash              gnucash                       true      false     0        default   TODO: C/C++
hibbitts-design      grav-plugin-external-links    true      false     0        default
kalkulacka-one       kalkulacka                    true      true      0        default
KohoVolit            Mandaty.cz                    true      true      0        default
KohoVolit            NapisteJim                    true      true      0        default
KohoVolit            partmonitor.hu                true      true      0        default
LibreHealthIO        lh-ehr                        true      false     0        default
LibreHealthIO        lh-ehr-laravel                true      true      0        default
openstreetmap        iD                            true      true      0        default
openstreetmap        openstreetmap-website         true      false     0        default
rolling-cz           cistky-minihra                true      true      0        default
rolling-cz           cistky-obvineni               true      true      0        default
rolling-cz           cistky-politiky               true      true      0        default
rolling-cz           konec-dejin                   true      false     0        default
rolling-cz           moirai                        true      false     11       maven
rolling-cz           orloj-2.0                     true      false     0        default
SeanFranklin         hemaScorecard                 true      false     0        default
trilbymedia          grav-plugin-flex-objects      true      false     0        default
zegkljan             scorer                        true      true      0        default
zegkljan             videoreferee                  true      false     0        default   TODO: gradle (kotlin)
EOF
}

function Log_Info() {
  local info="${*}"
  echo "${info}" >&2
}

function Print_JSON_Item() {
  local repo_owner="${1}"
  shift
  local repo_name="${1}"
  shift
  local node_js="${1}"
  shift
  local jdk_version="${1}"
  shift
  local analysis_method="${1}"
  shift

  cat <<EOF
  {
    "githubRepo": "${repo_owner}/${repo_name}",
    "sonarProjectKey": "security-check-box_${repo_owner}_${repo_name}",
    "requiresNodeJs": ${node_js},
    "jdkVersion": ${jdk_version},
    "analysisMethod": "${analysis_method}"
  }
EOF
}

echo "["
separator=""
List_Items | while read repo_owner repo_name schedule_enabled node_js jdk_version analysis_method comment; do
  repo_full="${repo_owner}/${repo_name}"
  fields=("${repo_owner}" "${repo_name}" "${node_js}" "${jdk_version}" "${analysis_method}")

  case "${event_name}" in 

  'schedule')
    if [[ "${schedule_enabled}" != true ]]; then
      Log_Info "Repo ${repo_full}: Scheduled analysis disabled."
      continue
    fi
    last_commit_date="$(
      curl -s "https://api.github.com/repos/${repo_full}/commits?per_page=1" |
        jq -r '.[0].commit.committer.date'
    )"
    # Convert to Unix timestamp for comparison
    last_commit_timestamp=$(date -d "${last_commit_date}" +%s)
    current_timestamp=$(date +%s)
    # Calculate age in days
    age_in_days="$(( (current_timestamp - last_commit_timestamp) / 60 / 60 / 24 ))"
    Log_Info "Repo ${repo_full}: Last commit age: ${age_in_days} days"
    (( age_in_days > 8 )) && continue

    echo "${separator}"
    Print_JSON_Item "${fields[@]}"
    separator=","
  ;;

  'workflow_dispatch')
    case "${event_input_github_repo}" in
    '(all)' | "${repo_full}")
      Log_Info "Repo ${repo_full}: Manual run for repo '${event_input_github_repo}'."

      echo "${separator}"
      Print_JSON_Item "${fields[@]}"
      separator=","
    ;;
    *)
      Log_Info "Repo ${repo_full}: Manual run for another repo: '${event_input_github_repo}'."
      continue
    ;;
    esac
  ;;

  *)
    Log_Info "ERROR: Unexpected GitHub event name '${event_name}'."
    exit 1
  ;;

  esac
done
echo "]"

exit 0

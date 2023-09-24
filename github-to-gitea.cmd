@echo off
setlocal enabledelayedexpansion
@REM install jq from https://github.com/jqlang/jq/releases and place jq.exe in the same folder of this script


set GITHUB_USERNAME=yourusername
@REM get it from https://github.com/settings/tokens?type=beta
set GITHUB_TOKEN=github_pat_xxx
@REM set it to user or org
set GITHUB_TYPE=org
set GITHUB_USER_OR_ORGANISATION=yourorg

set GITEA_USERNAME=
set GITEA_TOKEN=
set GITEA_DOMAIN=192.168.0.XX
set GITEA_REPO_OWNER=


set GITHUB_API_URL=https://api.github.com/user/repos?per_page=200&type=all
if "%GITHUB_TYPE%"=="org" (
    set GITHUB_API_URL=https://api.github.com/orgs/%GITHUB_USER_OR_ORGANISATION%/repos?per_page=200&type=all
)


for /f %%i in ('curl -H "Accept: application/vnd.github.v3+json" -u %GITHUB_USERNAME%:%GITHUB_TOKEN% -s "%GITHUB_API_URL%" ^| jq -r ".[].html_url"') do (
    set URL=%%i
    set REPO_NAME=!URL:https://github.com/%GITHUB_USER_OR_ORGANISATION%/=!

    echo URL is: !URL!
    echo REPO_NAME is: !REPO_NAME!

	@REM Decomment this line to remove all repo added to gitea
	@REM curl -X DELETE "http://%GITEA_DOMAIN%/api/v1/repos/%GITEA_REPO_OWNER%/!REPO_NAME!" -u %GITEA_USERNAME%:%GITEA_TOKEN% -H  "accept: application/json"

    curl -X POST "http://%GITEA_DOMAIN%/api/v1/repos/migrate" -u %GITEA_USERNAME%:%GITEA_TOKEN% -H "accept: application/json" ^
	-H "Content-Type: application/json" -d "{  \"auth_username\": \"%GITHUB_USERNAME%\", \"auth_token\": \"%GITHUB_TOKEN%\", \"clone_addr\": \"!URL!\", \"issues\": true, \"labels\": true, \"private\": true, \"repo_name\": \"!REPO_NAME!\", \"repo_owner\": \"%GITEA_REPO_OWNER%\", \"service\": \"git\", \"uid\": 0, \"wiki\": true, \"mirror\": true, \"mirror_interval\": \"8h0m0s\"}"


)
endlocal

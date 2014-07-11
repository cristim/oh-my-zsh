export AWS_HOME=~/.aws

function _homebrew-installed () {
  type brew &> /dev/null
}

function _awscli-homebrew-installed () {
  brew --prefix awscli &> /dev/null
}

function agp () {
  echo $AWS_DEFAULT_PROFILE
}

function asp () {
  export AWS_DEFAULT_PROFILE=$1
  export AWS_PROFILE=$1
  export RPROMPT="<aws:$AWS_DEFAULT_PROFILE>$RPROMPT"
}

function aws_profiles () {
  reply=($(grep '^\[' $AWS_HOME/credentials|sed -e 's/\[\(.*\)\]/\1/'))
}

if _homebrew-installed && _awscli-homebrew-installed ; then
  _aws_zsh_completer_path=$(brew --prefix awscli)/libexec/bin/aws_zsh_completer.sh
else
  _aws_zsh_completer_path=$(which aws_zsh_completer.sh)
fi

[ -x $_aws_zsh_completer_path ] && source $_aws_zsh_completer_path
unset _aws_zsh_completer_path

function chpwd () {
  emulate -L zsh
  test -f .aws_profile && asp $(cat .aws_profile)
}


function aws_change_access_key () {
  if [[ "x$1" == "x" ]] then
    echo "usage: $0 <profile.name>"
    return 1
  else
    echo "Insert the credentials when asked."
    asp $1
    aws iam create-access-key
    aws configure --profile $1
    echo "You can now safely delete the old access key running 'aws iam delete-access-key --access-key-id ID'"
    echo "Your current keys are:"
    aws iam list-access-keys
  fi
}

compctl -K aws_profiles asp aws_change_access_key

if _homebrew-installed && _awscli-homebrew-installed; then
  source $(brew --prefix)/opt/awscli/libexec/bin/aws_zsh_completer.sh
else
  source `which aws_zsh_completer.sh`
fi

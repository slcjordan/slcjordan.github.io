#!/bin/bash

dependencies=(git curl)
source_code=/home/$USER/Developer/src
progress_file=/home/$USER/.setup_progress/bootstrap

install_dependencies() {
  for i in  "${dependencies[@]}"
  do
    sudo apt install $i
  done
}

setup_rsa_key() {
  email=$1

  ssh-keygen -t rsa -b 4096 -C $email
}

upload_rsa_key_to_github() {
  user=$1
  pass=$2
  desc=$3

  data='{"title":"'"$desc"'","key":"'"$(cat ~/.ssh/id_rsa.pub)"'"}'
  eval "curl -u \"$user:$pass\" -H \"Content-Type: application/json\" -X POST -d '$data' https://api.github.com/user/keys"
}

setup_git() {
  echo "setting up git"
  read -p "Enter Your Email: " email
  read -p "Enter Your github username: " user
  read -p "Enter Your github password: " pass
  read -p "Enter a description of this device: " desc

  setup_rsa_key $email
  upload_rsa_key_to_github $user $pass $desc
}

git_clone() {
  git_host=$1
  repo=$2

  dest=$source_code/$git_host/$repo
  mkdir -p $dest
  git clone git@$git_host:$repo.git $dest
}

setup() {
  if [[ -f $progress_file ]]; then
    echo "This has already been done"
    exit
  fi

  install_dependencies
  setup_git
  git_clone github.com slcjordan/config
  sudo chmod +x $source_code/github.com/slcjordan/config/setup.sh
  $source_code/github.com/slcjordan/config/setup.sh

  mkdir -p $(dirname $progress_file)
  touch $progress_file
}

setup

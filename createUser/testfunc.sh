#!/bin/#!/usr/bin/env bash

function echoBreak() {
  #statements
  echo "echo this function"
}

function echoLog() {
  #statements
  echo $1
}

function read_plus_cmd(parameter) {
  read -p "Please select from `groups $NEW_U | cut -d' ' -f3-`"
}

#export -f echoBreak
echoLog "Hello"

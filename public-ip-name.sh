#!/usr/bin/env bash

set -e

az network public-ip list -g $1 --query '[].{name:name}'[0]
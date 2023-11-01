#!/bin/bash

yabai --stop-service
brew upgrade yabai
yabai --start-service

brew update

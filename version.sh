#!/usr/bin/env bash

echo {\"sha\": \"$(git log --format="%h" -n 1 | cat)\"}
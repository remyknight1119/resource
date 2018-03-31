#!/bin/bash

git pull origin $(git symbolic-ref --short HEAD)

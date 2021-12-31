#!/usr/bin/env bash

set -e

service udev reload
sleep 2
service udev restart

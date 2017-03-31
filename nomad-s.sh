#!/bin/sh

nomad agent -client -server -bootstrap-expect=1 -data-dir=/etc/nomad.d/data

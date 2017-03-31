#!/bin/sh

nomad agent -server -bootstrap-expect=1 -data-dir=/etc/nomad.d/data

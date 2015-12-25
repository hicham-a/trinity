#!/bin/bash
omd start monitoring
echo I am started "$@"
exec "$@"

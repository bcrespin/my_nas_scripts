#!/bin/sh

echo -n "ada0 : "
sh -c 'camcontrol identify ada0 2>/null' | grep serial
echo
echo -n "ada1 : "
sh -c 'camcontrol identify ada1 2>/null' | grep serial
echo
echo -n "ada2 : "
sh -c 'camcontrol identify ada2 2>/null' | grep serial
echo 
echo -n "ada3 : "
sh -c 'camcontrol identify ada3 2>/null' | grep serial
echo 
echo -n "ada4 : "
sh -c 'camcontrol identify ada4 2>/null'  | grep serial
echo 
echo -n "ada5 : "
sh -c 'camcontrol identify ada5 2>/null' | grep serial
echo

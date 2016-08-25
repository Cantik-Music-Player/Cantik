#!/bin/bash

for i in plugins/*; do
    cd $i && npm run clean
    cd ../..
done

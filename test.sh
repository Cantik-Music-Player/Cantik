#!/bin/bash

for i in plugins/*; do
    cd $i && npm test || exit 1
    cd ../..
done

cd src && mocha --timeout 200000 --compilers coffee:coffee-script/register test && cd ..

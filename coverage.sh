#!/bin/bash

for i in plugins/*; do
    cd $i && npm run coverage
    cd ../..
done

cd src && istanbul cover _mocha -- --timeout 200000 --recursive --compilers coffee:coffee-script/register --require coffee-coverage/register-istanbul test && cd ..

istanbul-combine -d coverage -p summary -r lcov -r html coverage/coverage-a.json coverage/coverage-b.json ./plugins/*/coverage/*.json ./src/coverage/*.json

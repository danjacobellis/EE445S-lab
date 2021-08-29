#!/bin/bash

# Build html and organize files into two folders:
# /docs (with absolute links to use on github pages)
# /stm32h735gdk (with relative links to files on courses/realtime)

mkdir -p docs
mkdir -p stm32h735gdk
cd lab_manual

#docs
make clean
make html
cp -r _build/html/* ../docs/

#stm32h735gdk
for f in $(find _build -name '*.html')
do
    sed -i 's#http://users.ece.utexas.edu/~bevans/courses/realtime/#../../../../#g' $f
done
cp -r _build/html/* ../stm32h735gdk/

cd ..
zip -r stm32h735gdk.zip stm32h735gdk
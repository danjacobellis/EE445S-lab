# Building HTML

1. Set the current directoy to 'lab_manual'

    ```cd lab_manual```
    
2. Build the files

    ```make clean; make html```

3. To make the changes visible on github pages, copy them to the docs folder

    ```cp -r _build/html/* ../docs/```
    
Once changes are pushed, they will be visible on 

https://danjacobellis.github.io/EE445S-lab/
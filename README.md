# Building HTML

The build.sh script will create two versions of the HTML files

The first version is placed in the /docs folder where github pages automatically hosts from. For links to other course materials in this version, the full ece.utexas.edu URL is used. This version will be automatically published https://danjacobellis.github.io/EE445S-lab/ whenever changes are made.

The build.sh script creates a second version of the HTML files in stm32h735gdk.zip This version uses relative links to reference any files in the hierarchy higher than 'courses/realtime/lectures/laboratory/stm32h735gdk' (such as lecture slides, matlab info, etc).
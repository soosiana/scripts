export VOLUME="33"
cd $VOLUME
git init
git symbolic-ref HEAD refs/heads/main
git add .
git commit -s -m "First commit"
git remote add origin https://github.com/soosiana/volume-$VOLUME.git
git remote -v
git push -u origin main

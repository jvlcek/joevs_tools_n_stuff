#!/usr/bin/env bash

function ask {
  read -p "$@: " choice;
  echo "${choice}";
}

FILES="vmdb/Gemfile* lib/Gemfile host/Gemfile build/kickstarts/base.ks.erb"
BUILD_DIR_BASE="/home/jvlcek"
BUILD_DIR="CFME_IMAGE_BUILDING_2"

cd ${BUILD_DIR_BASE}
if ! [[ -d ./${BUILD_DIR} ]]; then
  mkdir ${BUILD_DIR}
fi
cd ${BUILD_DIR}

if ! [[ -d ./cfme ]]; then
  git clone -o production git+ssh://code.engineering.redhat.com/cfme.git # gerrit
  cd cfme
  git remote add upstream git@github.com:ManageIQ/manageiq.git
fi

cd cfme

# git remote -v
# Should look like this:
# production   git+ssh://code.engineering.redhat.com/cfme.git (fetch)
# production   git+ssh://code.engineering.redhat.com/cfme.git (push)
# upstream     git@github.com:ManageIQ/manageiq.git (fetch)
# upstream     git@github.com:ManageIQ/manageiq.git (push)

git fetch --all

echo "   * * * Branches * * *"
git branch -r # show remote branches
diff_branch=$(ask "which branch")
echo "diff_branch ->${diff_branch}<-"

echo "   * * * tags * * *"
git tag -l | grep ^5\.3\.1
diff_tag=$(ask "which tag")
echo "diff_tag ->${diff_tag}<-"

# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=
# Before we cut a branch and rebasing against upstream master
# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=
# git diff 5.3.0.0.alpha2 upstream/master ${FILES}

# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=
# After we have a production branch
# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=


# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=
# Find the last tag that has all gems already built into RPMs
# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=

echo "git diff ${diff_tag} ${diff_branch} ${FILES}"
git diff ${diff_tag} ${diff_branch} ${FILES}
# git diff 5.3.1.4 production/5.3.z ${FILES}

# Or diffing between 2 gerrit tags, once the new tag has been cut.

# git diff 5.2.4.2 production/5.2.4.x ${FILES}

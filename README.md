# WP Engine Deployment Image

A script for deploying WP Engine websites using Git that addresses some issues that we've encountered with tracking our websites via git, namely:

1. There are some files tracked in the repository that should not be hosted on WP Engine, such as `docker-compose.yml` and documentation.
2. WP Engine cannot pull from private submodules at all.
3. It is challenging to push changes in the repo with GitLab CI.

The script is based on [joshleecreates/wpengine-deploy-script](https://github.com/joshleecreates/wpengine-deploy-script).

## Usage

To run this script in the current directory, run:

    exec docker run \
        -e WPE_REMOTE="$1"\
        -e SSH_PRIVATE_KEY="`cat <PRIVATE_KEY_DIR>`"\
        --interactive --tty --rm \
        --volume "$PWD:/git/original" \
        utulsa/wpe-deploy:latest

The container creates a copy of your repository to avoid any potential side-effects.

| Variable | Description |
| -------- | ----------- |
| `WPE_REMOTE` | The name of the git remote to push to. |
| `WPE_REMOTE_URL` | (optional) The URL of the remote repo, if it does not exist in the Git repository. |
| `SSH_PRIVATE_KEY` | The private key to use when pushing to WP Engine. |

The wordpress repository must be mounted to `/git/original` in the container.

### Executable

I currently bundle this in a executable, `wpe-deploy`, with the following:

    exec docker run \
         -e WPE_REMOTE="$1"\
         -e SSH_PRIVATE_KEY="`cat ~/.ssh/id_rsa`"\
         --volume "$PWD:/git/original" \
         --interactive --tty --rm \
         "utulsa/wpe-deploy:latest"

So if the WP Engine remote is given in the repository as `production`, then

    wpe-deploy production

will deploy to WPEngine production.

### WPE Ignored Files

Ignoring files on the repository to WPEngine functions identically to `.gitignore`; simply add a file named `.wpe-gitignore` to the directory where you want to start ignoring a pattern. This file will not be tracked on WP Engine.

### Submodules

Submodules are automatically removed in the WP Engine push, so you can use private submodules when pushing.

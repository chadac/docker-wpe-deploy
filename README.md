# Deployment of Git Repositories to WPEngine

A helper script for deploying Wordpress-based Git repositories to WPEngine via Git. WPEngine allows users to push their git repositories to their own remote servers and has the advantage of doing some of their own tests on the code before applying any code updates. However, since Git is not meant for deploying code directly to a production server, there are several issues that we faced when using this feature, namely:

1. There are some files tracked in the repository that should not be hosted on WP Engine, such as `docker-compose.yml`, documentation, or any files that are meant to be used for local copies of the website.
2. WP Engine cannot pull from private submodules at all.
3. It's a bit of a challenge to use GitLab CI to automate deployments.

The script is based on [joshleecreates/wpengine-deploy-script](https://github.com/joshleecreates/wpengine-deploy-script), but is a bit more generalized to fully support submodules and ignoring files. Note that the history that is pushed to WPEngine will be very different from your base repository, so you will want to avoid storing your repository only on WPEngine.

## Usage

The container creates a copy of your repository to avoid any potential side-effects.

| Variable | Description |
| -------- | ----------- |
| `WPE_REMOTE` | The name of the git remote to push to. |
| `WPE_REMOTE_URL` | (optional) The URL of the remote repo, if it does not exist in the Git repository. |
| `SSH_PRIVATE_KEY` | (optional) The private key to use when pushing to WP Engine. You could also forward SSH_AUTH_PORT or something, but that doesn't work on Macs yet apparently. |

The wordpress repository must be located in the working directory to work correctly.

### Executable

I currently bundle this in a executable, `wpe-deploy`, with the following:

    exec docker run \
        -e WPE_REMOTE="$1" \
        -e SSH_PRIVATE_KEY="`cat ~/.ssh/id_rsa`" \
        --volume "$PWD:/data" \
        -w "/data" \
        --interactive --tty --rm \
        "utulsa/wpe-deploy:latest" /bin/bash -c 'source setup-ssh && run-deploy'

So if the WP Engine remote is given in the repository as `production`, then

    wpe-deploy production

will deploy the current branch to WPEngine production.

### WPE Ignored Files

Ignoring files on the repository to WPEngine functions identically to `.gitignore`; simply add a file named `.wpe-gitignore` to the directory where you want to start ignoring a pattern. This file will not be tracked on WP Engine.

### Submodules

Submodules are automatically removed in the WP Engine push, so you can use private submodules when pushing.

### GitLab CI

To set up deployments with GitLab CI, add the following to your `.gitlab-ci.yml`:

    deploy to wpengine:
      type: deploy
      image: utulsa/wpe-deploy:latest
      environment:
        name: wpe-production
      only:
        - production
      variables:
        WPE_REMOTE_URL: <YOUR_WPE_REMOTE_URL>
        GIT_SUBMODULE_STRATEGY: recursive
      before_script:
        - source setup-ssh
        - git submodule sync --recursive
        - git submodule update --init --recursive
      script:
        - run-deploy

Note that you might need to [change your `.gitmodules` file to use local addresses for submodules](https://docs.gitlab.com/ce/ci/git_submodules.html), and there [are some open issues regarding submodules in GitLab CI](https://gitlab.com/gitlab-org/gitlab-ci-multi-runner/issues/1569).

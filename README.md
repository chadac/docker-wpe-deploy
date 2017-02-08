# WP Engine Deployment Image

This is a sample image which may be used to deploy a repository to WP Engine.

## Usage

The script creates a new branch from whatever branch you are on, and then untracks any files that are listed in a `.wpe-gitignore` file. This process is recursive, so a `.wpe-gitignore` in any subdirectory will be copied into a corresponding `.gitignore` in that directory.

When you are ready to deploy, make sure to have the following environment variables set:

| Variable | Description |
| -------- | ----------- |
| `WPE_GIT_REPO` | The git repository to push to. |
| `WPE_SSH_PRIVATE_KEY` | The private key of the WPEngine user. |
| `WPE_SSH_PUBLIC_KEY` | The public key of the WPEngine user. |

Finally, run `deploy-to-wpengine` inside the image to complete the deployment.

## TODOs

I probably can have the `deploy-to-wpengine` script run automatically, need to check if that's true.

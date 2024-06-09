# Minecraft server image

This repository contains the code to build EC2 AMI with Minecraft baked in. The AMI is built using Packer.

## Files

|         File          |                        Description                         |
|:---------------------:|:----------------------------------------------------------:|
| minecraft-ami.pkr.hcl |                  Packer code to build AMI                  |
|   variables.pkr.hcl   |                 Variables needed for build                 |
|        files/*        | Auxiliary files needed for minecraft service to start/stop |

## Pipeline

The pipeline is a GitHub action. It runs on a push to any branch, and it handles initializing,
validating, and building the image. The pipeline authenticates into the AWS account using GitHub OIDC token.

## Testing

To test your code, first set your AWS credentials:

```
export AWS_ACCESS_KEY_ID="{access_key}"
export AWS_SECRET_ACCESS_KEY="{secret_key}"
export AWS_SESSION_TOKEN="{session_token}"
```

Also, set the url to download the minecraft package from (you can find the link on
[this](https://www.minecraft.net/en-us/download/server) page:

```
PKR_VAR_minecraft_url="{minecraft_url}
```

Then, you can build the image

```
packer init .
packer validate .
packer build .
```

## Future improvements
- Append the branch name to the image when building test images
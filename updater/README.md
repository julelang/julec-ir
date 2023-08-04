# IR Updater

This IR updater is an algorithm that builds all publishable IR versions, clones this repository locally, updates IRs and README.
Developed with Pure Jule.
You need to have a Jule compiler to be able to use it.
To perform the process you need to compile and execute the IR updater with a Jule compiler.

## Notice

- Your git settings should be set. A commit will be made with your profile.
- You must have write permission on this repository.

## Using Script

You can use [`ir-updater.sh`](https://github.com/julelang/julec-ir/blob/main/updater/ir-updater.sh) to make this fully automatic. \
This script assumes that JuleC is already available in your path.

Execute this command in your terminal:
```sh
bash <(curl -s https://raw.githubusercontent.com/julelang/julec-ir/main/updater/ir-updater.sh)
```

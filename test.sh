#! /usr/bin/env nix-shell
#! nix-shell -i python -p python38 python38Packages.boto3

import boto3

ec2 = boto3.resource("ec2")

_, *images = ec2.images.filter(
    Filters=[{"Name": "name", "Values": ["whslabs-cardano-node-*"]}], Owners=["self"]
)

for image in images:
    image_name = image.name
    snapshot_id = [
        d["Ebs"]["SnapshotId"] for d in image.block_device_mappings if "Ebs" in d
    ][0]

    image.deregister()
    print(image_name + " deregistered")

    ec2.Snapshot(snapshot_id).delete()
    print(snapshot_id + " deleted")

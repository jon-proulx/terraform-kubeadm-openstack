#!/bin/sh

# cloud init script touches this file once common
# apt bits are taken care of, we need ot wait for this before
# other provisioners will work.
#
# this should be copied to instances and remote exec'ed
# before any calls that require k8s bits to exist
while [ ! -f /tmp/cloudinit.complete ]; do
 sleep 5
done
#

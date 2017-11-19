#!/bin/bash

set -ev

chmod +x scripts/build.sh
chmod +x scripts/deploy.sh
chmod +x scripts/doc.sh
chmod +x scripts/test.sh

pub get

pub global activate grinder
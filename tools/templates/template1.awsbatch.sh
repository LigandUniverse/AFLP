#!/usr/bin/env bash

# Copyright (C) 2019 Christoph Gorgulla
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# This file is part of AdaptiveFlow.
#
# AdaptiveFlow is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# AdaptiveFlow is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with AdaptiveFlow.  If not, see <https://www.gnu.org/licenses/>.

echo "Running AWS Batch"

error_response_std() {

    # Printint some information
    echo "Error was trapped" 1>&2
    echo "Error in bash script $(basename ${BASH_SOURCE[0]})" 1>&2
    echo "Error on line $1" 1>&2
    echo "Environment variables" 1>&2
    echo "----------------------------------" 1>&2
    env 1>&2

    # Exiting
    exit 1
}
trap 'error_response_std $LINENO' ERR

# Adjusting the CHEMAXON_LICENSE_URL environment variable
AFLP_PKG_BASE=/opt/af/packages
export CHEMAXON_LICENSE_URL="${AFLP_PKG_BASE}/chemaxon/license.cxl"
export CLASSPATH="/opt/af/helper/*:${AFLP_PKG_BASE}/nailgun/nailgun-server/target/classes:${AFLP_PKG_BASE}/nailgun/nailgun-examples/target/classes:${AFLP_PKG_BASE}/jchemsuite/lib/*"
export PATH="${AFLP_PKG_BASE}/nailgun/nailgun-client/target/:$PATH"

export AFLP_WORKUNIT_SUBJOB=${AWS_BATCH_JOB_ARRAY_INDEX}

env

cd /opt/af/tools
./aflp_run.py



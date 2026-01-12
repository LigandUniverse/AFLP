#!/usr/bin/env bash

# Copyright (C) 2019 Christoph Gorgulla
# Copyright (C) 2024 Christopher Secker
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# This file is part of AdaptiveFlow.
#
# AdaptiveFlow is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# AdaptiveFlow is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with AdaptiveFlow.  If not, see <https://www.gnu.org/licenses/>.


# Job Information -- generally nothing in this
# section should be changed
##################################################################################

# If you are using a virtualenv, make sure the correct one
# is being activated

source $HOME/aflp_env/bin/activate

# deletes the temp directory
function cleanup {
  rm -rf ${AFLP_PKG_TMP_DIR}
  echo "delete tmpdir ${AFLP_PKG_TMP_DIR}"
}

trap cleanup EXIT

export AFLP_WORKUNIT={{workunit_id}}
export AFLP_JOB_STORAGE_MODE={{job_storage_mode}}
export AFLP_TMP_PATH=/dev/shm
export AFLP_CONFIG_JOB_TGZ={{job_tgz}}
export AFLP_VCPUS={{threads_to_use}}

##################################################################################

export AFLP_WORKFLOW_DIR=$(readlink --canonicalize ..)/workflow
export AFLP_CONFIG_JSON=${AFLP_WORKFLOW_DIR}/config.json
export AFLP_WORKUNIT_JSON=${AFLP_WORKFLOW_DIR}/workunits/${AFLP_WORKUNIT}.json.gz

##################################################################################

AFLP_PKG_BASE=$(readlink --canonicalize .)/packages
AFLP_PKG_TMP_DIR=$(mktemp -d)

chemaxon_license_filename=$(jq -r .chemaxon_license_filename ${AFLP_CONFIG_JSON})

jchem_package_filename=$(jq -r .jchem_package_filename ${AFLP_CONFIG_JSON})
java_package_filename=$(jq -r .java_package_filename ${AFLP_CONFIG_JSON})
ng_package_filename=$(jq -r .ng_package_filename ${AFLP_CONFIG_JSON})

if [[ "$jchem_package_filename" != "none" ]]; then
	echo "Unpacking $jchem_package_filename to ${AFLP_PKG_TMP_DIR}/jchemsuite"
	tar -xf $AFLP_PKG_BASE/$jchem_package_filename -C ${AFLP_PKG_TMP_DIR}
fi

if [[ "$java_package_filename" != "none" ]]; then
	echo "Unpacking $java_package_filename to ${AFLP_PKG_TMP_DIR}/java"
	tar -xf $AFLP_PKG_BASE/$java_package_filename -C ${AFLP_PKG_TMP_DIR}
	export JAVA_HOME=${AFLP_PKG_TMP_DIR}/java/bin
fi

if [[ "$ng_package_filename" != "none" ]]; then
	echo "Unpacking $ng_package_filename to ${AFLP_PKG_TMP_DIR}/nailgun"
	tar -xf $AFLP_PKG_BASE/$ng_package_filename -C ${AFLP_PKG_TMP_DIR}
fi

if [[ "$chemaxon_license_filename" != "none" ]]; then
	export CHEMAXON_LICENSE_URL=${AFLP_PKG_TMP_DIR}/chemaxon_license_filename
	cp $AFLP_PKG_BASE/$chemaxon_license_filename ${CHEMAXON_LICENSE_URL}
fi

export CLASSPATH="${AFLP_PKG_TMP_DIR}/nailgun/nailgun-server/target/classes:${AFLP_PKG_TMP_DIR}/nailgun/nailgun-examples/target/classes:${AFLP_PKG_TMP_DIR}/jchemsuite/lib/*"
export PATH="${AFLP_PKG_TMP_DIR}/java/bin:${AFLP_PKG_TMP_DIR}/nailgun/nailgun-client/target/:$PATH"

##################################################################################

for i in `seq 0 {{array_end}}`; do
	export AFLP_WORKUNIT_SUBJOB=${i}
	echo "Workunit ${AFLP_WORKUNIT}:${AFLP_WORKUNIT_SUBJOB}: stdout in {{batch_workunit_base}}/${AFLP_WORKUNIT_SUBJOB}.out, stderr in {{batch_workunit_base}}/${AFLP_WORKUNIT_SUBJOB}.err"
	date +%s > {{batch_workunit_base}}/${AFLP_WORKUNIT_SUBJOB}.start
	./aflp_run.py > {{batch_workunit_base}}/$$_${AFLP_WORKUNIT_SUBJOB}.out 2> {{batch_workunit_base}}/$$_${AFLP_WORKUNIT_SUBJOB}.err
	date +%s > {{batch_workunit_base}}/${AFLP_WORKUNIT_SUBJOB}.end
done

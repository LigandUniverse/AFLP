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

FROM amazonlinux:2 as aflpbuild
RUN yum -y install java-11-amazon-corretto-headless

ARG CX_LICENSE_FILE

ADD templates /opt/af/tools/templates

ADD packages/jchemsuite.tar.gz /opt/af/packages
ADD packages/nailgun.tar.gz /opt/af/packages
ADD helper /opt/af/helper

WORKDIR /opt/af/helper/af
RUN javac -cp "/opt/af/packages/jchemsuite/lib/*" CxCalcAttr.java
WORKDIR /opt/af/helper
RUN jar cf CxCalcAttr.jar af

COPY $CX_LICENSE_FILE /opt/af/packages/chemaxon/license.cxl



FROM amazonlinux:2

RUN amazon-linux-extras install epel -y
RUN yum update -y && yum -y install python3 openbabel java-11-amazon-corretto-headless which iproute
RUN pip3 install boto3 rdkit selfies

COPY --from=aflpbuild /opt/af /opt/af
ADD *.py *.sh /opt/af/tools/
RUN chmod +x -R /opt/af/tools/*.sh \
        /opt/af/tools/*.py  \
        /opt/af/tools/templates/*.sh \
        /opt/af/packages/nailgun/nailgun-client/target/ng

ENV USER ec2-user

WORKDIR /

ENTRYPOINT ["/opt/af/tools/templates/template1.awsbatch.sh"]

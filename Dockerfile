# Copyright 2022 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:1.17 AS builder
WORKDIR /go/src/sigs.k8s.io/ibm-powervs-block-csi-driver
ADD . .
RUN make driver

FROM k8s.gcr.io/build-image/debian-base:v2.1.3 AS debian-base
RUN clean-install ca-certificates e2fsprogs mount udev util-linux xfsprogs bash multipath-tools sg3-utils
COPY --from=builder /go/src/sigs.k8s.io/ibm-powervs-block-csi-driver/bin/ibm-powervs-block-csi-driver /ibm-powervs-block-csi-driver
ENTRYPOINT ["/ibm-powervs-block-csi-driver"]


FROM quay.io/centos/centos:stream8 AS centos-base
RUN yum install -y util-linux nfs-utils e2fsprogs xfsprogs ca-certificates && yum clean all && rm -rf /var/cache/yum
COPY --from=builder /go/src/sigs.k8s.io/ibm-powervs-block-csi-driver/bin/ibm-powervs-block-csi-driver /ibm-powervs-block-csi-driver
ENTRYPOINT ["/ibm-powervs-block-csi-driver"]

# SPDX-FileCopyrightText: 2022 Contributors to the License scan action project <OSPO@alliander.com>
#
# SPDX-License-Identifier: Apache-2.0

FROM ghcr.io/alliander-opensource/ort-container:latest

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

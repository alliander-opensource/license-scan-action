# SPDX-FileCopyrightText: 2022 Contributors to the License scan action project <OSPO@alliander.com>
#
# SPDX-License-Identifier: Apache-2.0

FROM philipssoftware/ort:latest

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

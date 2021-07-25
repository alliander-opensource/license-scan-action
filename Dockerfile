# SPDX-FileCopyrightText: 2021 Alliander N.V.
#
# SPDX-License-Identifier: Apache-2.0

FROM philipssoftware/ort:latest

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

#
# Cookbook Name:: rs-storage
# Attribute:: default
#
# Copyright (C) 2013 RightScale, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Restores from a backup lineage (specified by rs-storage/backup/lineage) instead of creating a new volume
default['rs-storage']['device']['restore'] = false

# Enable/Disable scheduling backups
default['rs-storage']['schedule']['enable'] = false

# The mount point where the device will be mounted
default['rs-storage']['device']['mount_point'] = '/mnt/storage'

# Nickname for the device
default['rs-storage']['device']['nickname'] = 'data_storage'

# Size of the volume to be created
default['rs-storage']['device']['volume_size'] = 10

# Number of volumes in the stripe
default['rs-storage']['device']['stripe_count'] = 1

# I/O Operations Per Second value
default['rs-storage']['device']['iops'] = nil

# The filesystem to be used on the device
default['rs-storage']['device']['filesystem'] = 'ext4'

# Backup lineage
default['rs-storage']['backup']['lineage'] = nil

# Override lineage name to restore backups from a different lineage
default['rs-srorage']['backup']['lineage_override'] = nil

# Override timestamp to restore backup from a backup taken on or before the timestamp in the same lineage
default['rs-srorage']['backup']['timestamp_override'] = nil

# Daily backups to keep
default['rs-srorage']['backup']['keep']['daily'] = 14

# Weekly backups to keep
default['rs-srorage']['backup']['keep']['weekly'] = 6

# Monthly backups to keep
default['rs-srorage']['backup']['keep']['monthly'] = 12

# Yearly backups to keep
default['rs-srorage']['backup']['keep']['yearly'] = 2

# Maximum snapshots to keep
default['rs-srorage']['backup']['keep']['max_snapshots'] = 60

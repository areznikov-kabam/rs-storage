#
# Cookbook Name:: rs-storage
# Library:: helper
#
# Copyright (C) 2014 RightScale, Inc.
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

require 'chef/mixin/shell_out'

module RsStorage
  module Helper
    include Chef::Mixin::ShellOut

    # Given a mount point this method will inspect if an LVM is used for the device mounted at the mount point.
    #
    # @param mount_point [String] the mount point of the device
    #
    # @return [Boolean] whether LVM is used in the device at the mount point
    #
    def is_lvm_used?(mount_point)
      Chef::Log.info "checking lvm #{mount_point}"
      mount = shell_out!('mount')
      Chef::Log.info "mount returned #{mount.stdout}"
      mount.stdout.each_line do |line|
        if line =~ /^(.+)\s+on\s+#{mount_point}\s+/
          device = $1
          Chef::Log.info "checking device #{device}"

          if !(device =~ /^\/dev\/mapper/ ) 
            Chef::Log.info "#{device} doesnt start with /dev/mapper"
            false
          end

          lvdisplay=shell_out("lvdisplay '#{device}'")
          if lvdisplay.status != 0
            Chef::Log.info "lvdisplay #{device} returned #{lvdisplay.status}"
            false
          end

          Chef::Log.info "#{device} is a LVM device"
          true
        else
            Chef::Log.info "line is no good #{line}"
        end
      end
      Chef::Log.info "lvm check failed #{mount_point}"
      false
    end

    # Removes the LVM conditionally. It only accepts the name of the volume group and performs the following:
    # 1. Removes the logical volumes in the volume group
    # 2. Removes the volume group itself
    # 3. Removes the physical volumes used to create the volume group
    #
    # This method is also idempotent -- it simply exits if the volume group is already removed.
    #
    # @param volume_group_name [String] the name of the volume group
    #
    def remove_lvm(volume_group_name)
      require 'lvm'
      lvm = LVM::LVM.new
      volume_group = lvm.volume_groups[volume_group_name]
      if volume_group.nil?
        Chef::Log.info "Volume group '#{volume_group_name}' is not found"
      else
        logical_volume_names = volume_group.logical_volumes.map { |logical_volume| logical_volume.name }
        physical_volume_names = volume_group.physical_volumes.map { |physical_volume| physical_volume.name }

        # Remove the logical volumes
        logical_volume_names.each do |logical_volume_name|
          Chef::Log.info "Removing logical volume '#{logical_volume_name}'"
          command = "lvremove --force /dev/mapper/#{to_dm_name(volume_group_name)}-#{to_dm_name(logical_volume_name)}"
          Chef::Log.debug "Running command: '#{command}'"
          output = lvm.raw(command)
          Chef::Log.debug "Command output: #{output}"
        end

        # Remove the volume group
        Chef::Log.info "Removing volume group '#{volume_group_name}'"
        command = "vgremove #{volume_group_name}"
        Chef::Log.debug "Running command: #{command}"
        output = lvm.raw(command)
        Chef::Log.debug "Command output: #{output}"

        physical_volume_names.each do |physical_volume_name|
          Chef::Log.info "Removing physical volume '#{physical_volume_name}'"
          command = "pvremove #{physical_volume_name}"
          Chef::Log.debug "Running command: #{command}"
          output = lvm.raw(command)
          Chef::Log.debug "Command output: #{output}"
        end
      end
    end

    # Replaces dashes (-) with double dashes (--) to mimic the behavior of the LVM cookbook's naming convention of
    # naming logical volume names.
    #
    # @param name [String] the name to be converted
    #
    # @return [String] the converted name
    #
    def to_dm_name(name)
      name.gsub(/-/, '--')
    end

    # Obtains the run state of the server. It uses the `rs_state` utility to get the current system run state.
    # Possible values for this command:
    # - booting
    # - booting:reboot
    # - operational
    # - stranded
    # - shutting-down:reboot
    # - shutting-down:terminate
    # - shutting-down:stop
    #
    # @return [String] the current system run state
    #
    def get_rs_run_state
      state = shell_out!('rs_state --type=run').stdout.chomp
      Chef::Log.info "The RightScale run state is: #{state.inspect}"
      state
    end

  end
end

# Include this helper to recipes
::Chef::Recipe.send(:include, RsStorage::Helper)
::Chef::Resource::RubyBlock.send(:include, RsStorage::Helper)

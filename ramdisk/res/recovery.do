
# for recovery (global)

on init-recovery
#    mount --option=ro /system

    mount -f /cache
    ls /cache/recovery/
    ls /cache/fota/

    unmount /cache
    exec -f "/system/bin/e2fsck -v -y <dev_node:/cache>"

    mount /cache
    fcut --limited-file-size=1024k -f /cache/recovery/last_recovery /tmp/recovery_old.tmp

on init-history
# Make command history file.
#   mount -f /cache

    df /efs
    mkdir -f radio system 0771 /efs/recovery
    touch -f /efs/recovery/history

#   echo "+ [<log_prefix>]" >> /efs/recovery/history
#   cat -f /cache/recovery/command >> /efs/recovery/history

#   cp -y -f -v /efs/recovery/history /cache/recovery/last_history
#   chown -f system system /cache/recovery/last_history

on init-history-command
# write misc command to history file
    mount -f /cache

    df /efs
    mkdir -f radio system 0771 /efs/recovery
    touch -f /efs/recovery/history

    echo "[BCB] : <recovery_command>" >> /efs/recovery/history
    #cat -f /cache/recovery/command >> /efs/recovery/history

    cp -y -f -v /efs/recovery/history /cache/recovery/last_history
    chown -f system system /cache/recovery/last_history

on reboot-reason-history
# Make reboot reason history
    touch -f /efs/recovery/history

    echo "reboot reason : <reboot_reason> " >> /efs/recovery/history

    echo "-" >> /efs/recovery/history
    cp -y -f -v /efs/recovery/history /cache/recovery/last_history
    chown -f system system /cache/recovery/last_history

on checking-log
        mount -f /cache
        ls /cache/recovery/
        unmount /cache

# running --data_resizing with the userdata binaray
on resizing-data
#    mount --option=ro /system

    exec -f "/system/bin/e2fsck -y -f <dev_node:/data>"
    mount --option=ro /data
    find -v --print=/tmp/data.list /data
    unmount /data

    loop_begin 2
        exec "/system/bin/resize2fs -R <footer_length> <dev_node:/data>"
    loop_end

    mount /data
    df /data
    verfiy_data <dev_node:/data> /data 5
    verfiy_data --size-from-file=/tmp/data.list
    unmount /data

# running --data_resizing-f2fs with the userdata binaray
on resizing-data-f2fs
#    mount --option=ro /system

    mount --option=ro /data
    find -v --print=/tmp/data.list /data
    unmount /data

    loop_begin 2
        exec -f "/system/bin/fsck.f2fs -y <dev_node:/data>"
        exec "/system/bin/resize.f2fs -t <sector_size> <dev_node:/data>"
    loop_end

    mount --option=ro /data
    df /data
    verfiy_data <dev_node:/data> /data 5
    verfiy_data --size-from-file=/tmp/data.list
    unmount /data

# only run command csc_factory
on pre-multi-csc
    precondition define /carrier
    mount -r /carrier
    format /carrier

# all
on exec-multi-csc
    echo 
    echo "-- Appling Multi-CSC..."
    unmount /system
    mount --option=rw /system
    echo "Applied the CSC-code : <salse_code>"
        
    ln -v -s -r --force-link -f /system/csc/common/system/app/ /system/app/
    cp -y -f -r -v /system/csc/common /

    cmp -r -f /system/csc/common/system/app/ /system/app/

    ln -v -s -r --force-link -f /system/csc/<salse_code>/system/app/ /system/app/
    cp -y -f -r -v /system/csc/<salse_code>/system /system

    cmp -r -f /system/csc/common/csc/<salse_code>/system/app/ /system/app/
        
    rm -v /system/csc_contents
    ln -v -s /system/csc/<salse_code>/csc_contents /system/csc_contents

    rm -v -r -f --limited-file-size=0 --type=file --except-root-dir /system/priv-app
    rm -v -r -f --limited-file-size=0 --type=file --except-root-dir /system/app
        
    unmount /system
    echo "Successfully applied multi-CSC."

# RECOVERY_DISABLE_SYMLINK
on exec-multi-csc-disable-symlink
    echo 
    echo "-- Appling Multi-CSC..."
    unmount /system
    mount --option=rw /system
    echo "Applied the CSC-code : <salse_code>"
        
#   ln -v -s -r --force-link -f /system/csc/common/system/app/ /system/app/
    cp -y -f -r -v /system/csc/common /

    cmp -r -f /system/csc/common/system/app/ /system/app/

#   ln -v -s -r --force-link -f /system/csc/<salse_code>/system/app/ /system/app/
    cp -y -f -r -v /system/csc/<salse_code>/system /system

        cmp -r -f /system/csc/common/csc/<salse_code>/system/app/ /system/app/
        
    rm -v /system/csc_contents
    ln -v -s /system/csc/<salse_code>/csc_contents /system/csc_contents

    rm -v -r -f --limited-file-size=0 --type=file --except-root-dir /system/priv-app
    rm -v -r -f --limited-file-size=0 --type=file --except-root-dir /system/app
        
    unmount /system
    echo "Successfully applied multi-CSC."

# only run command csc_factory
on exec-multi-csc-data
    mkdir -f radio system 0771 /efs/recovery
    write -f /efs/recovery/bootmessage "exec-multi-csc-data\n"

    unmount -f /system
    #mount /data
    #cp -y -f -r -v --with-fmode=0644 --with-dmode=0771 --with-owner=system.system /data/csc/common /
    #cp -y -f -r -v --with-fmode=0644 --with-dmode=0771 --with-owner=system.system /data/csc/<salse_code> /
    #rm -v -r -f --limited-file-size=0 --type=file --except-root-dir /data/app
    #rm -v -r -f /data/csc
    #unmount /data

# run condition wipe-data and csc_factory
on exec-install-preload
    echo "-- Set Factory Reset done..."
    mkdir -f radio system 0771 /efs/recovery
    write -f /efs/recovery/bootmessage "exec-install-preload\n"
    write -f /efs/recovery/currentlyFactoryReset "done"
    ls /efs/imei/

    #echo "-- Copying media files..."
    #mount /data
    #mount /system
    #mkdir media_rw media_rw 0770 /data/media
    #cp -y -r -v -f --with-fmode=0664 --with-dmode=0775 --with-owner=media_rw.media_rw /system/hidden/INTERNAL_SDCARD/ /data/media/
    #unmount /data
    #mount /data
    #cmp -r /system/hidden/INTERNAL_SDCARD/ /data/media/

    #echo "--  preload checkin..."
    #precondition define /preload

    #mount -f /preload
    #precondition mounted /preload

    #cp -y -r -v -f --with-fmode=0664 --with-dmode=0775 --with-owner=media_rw.media_rw /preload/INTERNAL_SDCARD/ /data/media/
    #unmount /data
    #mount /data
    #cmp -r /preload/INTERNAL_SDCARD/ /data/media/

on rm-wipe-app-data
    echo "-- rm-wipe-app-data..."
    mount -f /efs
    mkdir -f radio system 0771 /efs/recovery
    rm -v -f /efs/recovery/rescueparty
    write -f /efs/recovery/rescueparty "emergency_reset\n"
    
on post_wipe_data
    echo "-- post_wipe_data..."
    mkdir -f radio system 0771 /efs/recovery
    rm -v -f /efs/recovery/postwipedata
    write -f /efs/recovery/postwipedata "postwipedata\n"

on post-exec-install-preload
    mkdir -f radio system 0771 /efs/recovery
    write -f /efs/recovery/bootmessage "post-exec-install-preload\n"

    # for KOR
    #mount /system
    #precondition file /system/preload
    #mount /data
    #mkdir system system 0775 /data/app
    #cp -y -f -v --with-fmode=0664 --with-owner=system.system /system/preload/*.ppk /data/app/*.apk

on exec-delete-selective-file
    echo "-- Deleting selective files"

    unmount /system
    mount --option=rw /system

    # @IQI m.shetye MNO-Team-2 : Delete IQ apk (AttIqi_ATT.apk) and IQI related library files (libiqi_bridge.so & libiqi_service.so)
    rm -rf /system/carrier/ATT/priv-app/AttIqi_ATT

    unmount /system

    echo "Successfully deleted files selecitvely"

on exec-check-meminfo
    echo "-- meminfo..."
    ls /tmp
    rm -v -f tmp/meminfo
    cp -y -f -v /proc/meminfo /tmp/meminfo
    df ./tmp

# remove sec directorys of another sales code for single SKU feature
on clear-sec-directory
# for debugging
#       mkdir /system/omc
#       mkdir /system/omc/ATT
#       mkdir /system/omc/ATT/etc
#       mkdir /system/omc/ATT/res
#       mkdir /system/omc/ATT/sec
#       mkdir /system/omc/SPR
#       mkdir /system/omc/SPR/etc
#       mkdir /system/omc/SPR/res
#       mkdir /system/omc/SPR/sec
#       mkdir /system/omc/<salse_code>
#       mkdir /system/omc/<salse_code>/etc
#       mkdir /system/omc/<salse_code>/res
#       mkdir /system/omc/<salse_code>/sec
#       find -v --print=/system/omc/ATT/sec/11.list /system/omc
#       find -v --print=/system/omc/ATT/sec/12.list /system/omc
#       find -v --print=/system/omc/SPR/sec/22.list /system/omc
#       find -v --print=/system/omc/SPR/sec/23.list /system/omc
#       find -v --print=/system/omc/<salse_code>/sec/33.list /system/omc
#       find -v --print=/system/omc/<salse_code>/sec/34.list /system/omc
        
    #for debugging
    find -v --print=/tmp/before_clear_sec.list /system/omc
    find --skip-with=/<salse_code>/ --name-with=/sec --print=/tmp/rm_sec.list /system/omc
    rm -v -r -f --from-defined-file=/tmp/rm_sec.list /system/omc
    #for debugging
    find -v --print=/tmp/after_claer_sec.list /system/omc

on exec-delete-apn-changes
    echo "-- Deleting VZW's apn file"

#   ls /efs/sec_efs/

    rm -f /efs/sec_efs/apn-changes.xml

#   ls /efs/sec_efs/

    echo "Successfully deleted VZW's apn file"

on pre-exec-wipe-data
    echo "-- Start Factory Reset..."
    write -f /efs/recovery/currentlyFactoryReset "start wipe-data\n"

# @OMC : [
# When omc binary is donwloaded, cp mps_code.dat -> omcnw_code.dat(request by PL(chulwoo73.kim) / RIL (sj.jin.jung)) [
on omc_binary_download
    echo "-- omc_binary_download..."
    cp -y -f -v --with-fmode=0664 --with-owner=radio.system /efs/imei/mps_code.dat /efs/imei/omcnw_code.dat

# Conditional deletion of salesCodeChanged flag file according to device type 
on delete_salesCodeChanged_flag
    echo "-- delete_salesCodeChanged_flag..."
    rm -f /efs/imei/salesCodeChanged

# Delete omcnw_code.dat in case device is not OMC model. 
on delete_omcnw_code
#    mount -f /efs
    echo "-- delete_omcnw_code..."
    ls /efs/imei/
    rm -f -v /efs/imei/omcnw_code.dat
    ls /efs/imei/
#    unmount /efs

# If device is omc device,  Auth. of /system/omc folder should be changed 751 because it is requested by vendor
# But HWRDB / sipdb / res folders should be 755 because contents could be used. 
on omc_permission
    chmod -v -r --type=directory 0751 /system/omc/
    chmod -v -r --type=directory 0755 /system/omc/sipdb/
    chmod -v -r --type=directory 0755 /system/omc/HWRDB/

on omc_sysconfig_permission
    chmod -v -r --type=directory 0755 /system/omc/<salse_code>/etc/sysconfig/

on omc_permissions_permission
    chmod -v -r --type=directory 0755 /system/omc/<salse_code>/etc/permissions/

on omc_sysconfig_permission_carrierid
    chmod -v -r --type=directory 0755 /system/omc/<carrier_id>/etc/cid/sysconfig/

on omc_permissions_permission_carrierid
    chmod -v -r --type=directory 0755 /system/omc/<carrier_id>/etc/cid/permissions/

on omc_res_permission
    chmod -v -r --type=directory 0755 /system/omc/<salse_code>/res/

# @OMC]

        
on amazon_symlink_ATT
    echo "-- amazon_symlink_att..."
    ln -v -s --force-link -f /system/etc/att/amazon-kindle.properties /system/etc/amazon-kindle.properties
    ln -v -s --force-link -f /system/etc/att/amzn.mshop.properties /system/etc/amzn.mshop.properties


on amazon_symlink_SPR
    echo "-- amazon_symlink_spr..."
    ln -v -s --force-link -f /system/etc/spr/amazon-kindle.properties /system/etc/amazon-kindle.properties
    ln -v -s --force-link -f /system/etc/spr/amzn.mshop.properties /system/etc/amzn.mshop.properties
    ln -v -s --force-link -f /system/etc/spr/Audible.param /system/etc/Audible.param
    ln -v -s --force-link -f /system/etc/spr/amzn.aiv.properties /system/etc/amzn.aiv.properties
    ln -v -s --force-link -f /system/etc/spr/amzn.mp3.properties /system/etc/amzn.mp3.properties
    ln -v -s --force-link -f /system/etc/spr/amzn.cdrive.properties /system/etc/amzn.cdrive.properties

on amazon_symlink_BST
    echo "-- amazon_symlink_bst..."
    ln -v -s --force-link -f /system/etc/bst/amazon-kindle.properties /system/etc/amazon-kindle.properties
    ln -v -s --force-link -f /system/etc/bst/amzn.mshop.properties /system/etc/amzn.mshop.properties
    ln -v -s --force-link -f /system/etc/bst/Audible.param /system/etc/Audible.param
    ln -v -s --force-link -f /system/etc/bst/amzn.aiv.properties /system/etc/amzn.aiv.properties
    ln -v -s --force-link -f /system/etc/bst/amzn.mp3.properties /system/etc/amzn.mp3.properties
    ln -v -s --force-link -f /system/etc/bst/amzn.cdrive.properties /system/etc/amzn.cdrive.properties

on amazon_symlink_VMU
    echo "-- amazon_symlink_vmu..."
    ln -v -s --force-link -f /system/etc/vmu/amazon-kindle.properties /system/etc/amazon-kindle.properties
    ln -v -s --force-link -f /system/etc/vmu/amzn.mshop.properties /system/etc/amzn.mshop.properties
    ln -v -s --force-link -f /system/etc/vmu/Audible.param /system/etc/Audible.param
    ln -v -s --force-link -f /system/etc/vmu/amzn.aiv.properties /system/etc/amzn.aiv.properties
    ln -v -s --force-link -f /system/etc/vmu/amzn.mp3.properties /system/etc/amzn.mp3.properties
    ln -v -s --force-link -f /system/etc/vmu/amzn.cdrive.properties /system/etc/amzn.cdrive.properties

on amazon_symlink_XAS
    echo "-- amazon_symlink_xas..."
    ln -v -s --force-link -f /system/etc/spr/amazon-kindle.properties /system/etc/amazon-kindle.properties
    ln -v -s --force-link -f /system/etc/spr/amzn.mshop.properties /system/etc/amzn.mshop.properties
    ln -v -s --force-link -f /system/etc/spr/Audible.param /system/etc/Audible.param
    ln -v -s --force-link -f /system/etc/spr/amzn.aiv.properties /system/etc/amzn.aiv.properties
    ln -v -s --force-link -f /system/etc/spr/amzn.mp3.properties /system/etc/amzn.mp3.properties
    ln -v -s --force-link -f /system/etc/spr/amzn.cdrive.properties /system/etc/amzn.cdrive.properties

on amazon_symlink_VZW
    echo "-- amazon_symlink_vzw..."
    ln -v -s --force-link -f /system/etc/vzw/amazon-kindle.properties /system/etc/amazon-kindle.properties
    ln -v -s --force-link -f /system/etc/vzw/amzn.mshop.properties /system/etc/amzn.mshop.properties
    ln -v -s --force-link -f /system/etc/vzw/amzn.mp3.properties /system/etc/amzn.mp3.properties
    ln -v -s --force-link -f /system/etc/vzw/amzn.apps.ref /system/etc/amzn.apps.ref
    ln -v -s --force-link -f /system/etc/vzw/amzn.aiv.properties /system/etc/amzn.aiv.properties
    ln -v -s --force-link -f /system/etc/vzw/Audible.param /system/etc/Audible.param

on amazon_symlink_USC
    echo "-- amazon_symlink_usc..."
    ln -v -s --force-link -f /system/etc/usc/amzn.mshop.properties /system/etc/amzn.mshop.properties

on amazon_symlink_O2U
    echo "-- amazon_symlink_O2U..."
    ln -v -s --force-link -f /system/omc/O2U/etc/amzn.mshop.properties /system/etc/amzn.mshop.properties
    ln -v -s --force-link -f /system/omc/O2U/etc/amazon-kindle.properties /system/etc/amazon-kindle.properties
    ln -v -s --force-link -f /system/omc/O2U/etc/amzn.mp3.properties /system/etc/amzn.mp3.properties

on amazon_symlink_VIA
    echo "-- amazon_symlink_VIA..."
    ln -v -s --force-link -f /system/omc/VIA/etc/amzn.mshop.properties /system/etc/amzn.mshop.properties

on amazon_symlink_XEC
    echo "-- amazon_symlink_XEC..."
    ln -v -s --force-link -f /system/omc/XEC/etc/amzn.mshop.properties /system/etc/amzn.mshop.properties

on amazon_symlink_FTM
    echo "-- amazon_symlink_FTM..."
    ln -v -s --force-link -f /system/omc/FTM/etc/amzn.mshop.properties /system/etc/amzn.mshop.properties


on amazon_symlink_MAX
    echo "-- amazon_symlink_MAX..."
    ln -v -s --force-link -f /system/omc/MAX/etc/amzn.mshop.properties /system/etc/amzn.mshop.properties
    ln -v -s --force-link -f /system/omc/MAX/etc/amzn.mp3.properties /system/etc/amzn.mp3.properties
    ln -v -s --force-link -f /system/omc/MAX/etc/amazon-kindle.properties /system/etc/amazon-kindle.properties

on amazon_symlink_TRG
    echo "-- amazon_symlink_TRG..."
    ln -v -s --force-link -f /system/omc/TRG/etc/amzn.mshop.properties /system/etc/amzn.mshop.properties
    ln -v -s --force-link -f /system/omc/TRG/etc/amzn.mp3.properties /system/etc/amzn.mp3.properties
    ln -v -s --force-link -f /system/omc/TRG/etc/amazon-kindle.properties /system/etc/amazon-kindle.properties

on amazon_symlink_AIO
    echo "-- amazon_symlink_AIO..."
    ln -v -s --force-link -f /system/etc/aio/amzn.mshop.properties /system/etc/amzn.mshop.properties 

on amazon_symlink_TMK
    echo "-- amazon_symlink_TMK..."
    ln -v -s --force-link -f /system/etc/tmk/amzn.mshop.properties /system/etc/amzn.mshop.properties

on amazon_symlink_ZTM
    echo "-- amazon_symlink_ZTM..."
    ln -v -s --force-link -f /system/omc/ZTM/etc/amzn.mshop.properties /system/etc/amzn.mshop.properties

# [@VOLD Add command Extra values for running recovery with a specific command
on amazon_symlink_canada_FMC
    echo "-- amazon_symlink_canada_FMC..."
    ln -v -s --force-link -f /system/omc/FMC/etc/amzn.mshop.properties /system/etc/amzn.mshop.properties

    echo "-- spotify symlink Canada FMC..."
    ln -v -s --force-link -f /system/omc/FMC/etc/spotify.preload /system/etc/spotify.preload

on amazon_symlink_canada_RWC
    echo "-- amazon_symlink_canada_RWC..."
    ln -v -s --force-link -f /system/omc/RWC/etc/amzn.mshop.properties /system/etc/amzn.mshop.properties

    echo "-- spotify symlink Canada RWC..."
    ln -v -s --force-link -f /system/omc/RWC/etc/spotify.preload /system/etc/spotify.preload

on amazon_symlink_canada_KDO
    echo "-- amazon_symlink_canada_KDO..."
    ln -v -s --force-link -f /system/omc/KDO/etc/amzn.mshop.properties /system/etc/amzn.mshop.properties

on amazon_symlink_canada_TLS
    echo "-- amazon_symlink_canada_TLS..."
    ln -v -s --force-link -f /system/omc/TLS/etc/amzn.mshop.properties /system/etc/amzn.mshop.properties
# @VOLD]

on omc_app_link
    echo "-- omc-app-link..."
    ln -v -s -r --force-link -f /system/omc/common_app/app/ /system/app/
    ln -v -s -r --force-link -f /system/omc/common_app/priv-app/ /system/priv-app/

on hwr_symlink_no_bri
    echo "-- hwr_symlink_no_BRI..."
    ln -v -s -r --force-link -f /system/omc/VODB/ /system/VODB/

# [@VOLD Symlink DCM WALLPAPER by COLOR ID
on color_id_wallpaper
    echo "-- color_id_wallpaper..."
    echo "Applied the COLOR ID : <color_id>"

    ln -v -s --force-link -f /system/etc/dhome/<color_id>/5_T_original.kic /system/etc/dhome/5_T_original.kic

    #ls /system/etc/dhome/

    echo "Successfully made a wallpaper symlink"
# ]

# @RSU(s2.patil, MNO) : delete TMO/MPCS Remote SIM Unlock app TA file in outbound permanent BYOD scenario(request by Security TG(jaehyrk.park)/ RFI(jungil.yoon)) [
on exec-delete-rsuselective-file
    echo "-- Deleting RSU selective file"

    unmount /system
    mount --option=rw /system

#   ls /system/app/mcRegistry

    rm -f /system/app/mcRegistry/08880000000000000000000000000000.tlbin

#   ls /system/app/mcRegistry

    unmount /system

    echo "Successfully deleted RSU selective file"
# ]

# [@VOLD Test for DREAM RED SCREEN ISSUE
on copy-poc-file
    echo "-- copy-poc-file..."
    echo "POC FILE PATH : <poc_file_path>"

    cat -f <poc_file_path> > /dev/poc

#    ls /cache/test/

    echo "Successfully copied POC FILE"
# ]

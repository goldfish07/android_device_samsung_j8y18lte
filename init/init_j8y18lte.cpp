/*
   Copyright (c) 2016, The CyanogenMod Project. All rights reserved.
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of The Linux Foundation nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
   THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
   ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
   BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
   BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
   OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
   IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdlib.h>
#include <string.h>
#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/strings.h>
#include <android-base/properties.h>

#include "property_service.h"
#include "vendor_init.h"

using android::base::GetProperty;
using android::base::ReadFileToString;
using android::base::Trim;

void property_override(char const prop[], char const value[])
{
    prop_info *pi;

    pi = (prop_info*) __system_property_find(prop);
    if (pi)
        __system_property_update(pi, value, strlen(value));
    else
        __system_property_add(prop, strlen(prop), value, strlen(value));
}

void property_override_dual(char const system_prop[],
        char const vendor_prop[], char const value[])
{
    property_override(system_prop, value);
    property_override(vendor_prop, value);
}

void set_sim_info()
{
  
    property_override("rild.libpath2", "/vendor/lib/libsec-ril-dsds.so");
        
}

void vendor_load_properties()
{
    std::string bootloader = GetProperty("ro.bootloader", "");
    std::string device;

 if (bootloader.find("J810G") != std::string::npos) {
        /* SM-J810G */
        property_override_dual("ro.build.fingerprint", "ro.vendor.build.fingerprint", "samsung/j8y18ltedd/j8y18lte:10/QP1A.190711.020/J810GDDU4CUB2:user/release-keys");
        property_override("ro.system.build.fingerprint", "samsung/j8y18ltedd/j8y18lte:10/QP1A.190711.020/J810GDDU4CUB2:user/release-keys");
        property_override("ro.build.description", "j8y18ltedd-user 10 QP1A.190711.020 J810GDDU4CUB2 release-keys");
        property_override_dual("ro.product.model", "ro.vendor.product.model", "SM-J810G");
        property_override_dual("ro.product.device", "ro.vendor.product.device", "j8y18lte");
    } else if (bootloader.find("J810F") != std::string::npos) {
        /* SM-J810F */
        property_override_dual("ro.build.fingerprint", "ro.vendor.build.fingerprint", "samsung/j8y18ltejv/j8y18lte:10/QP1A.190711.020/J810FJXU4CTG2:user/release-keys");
        property_override("ro.system.build.fingerprint", "samsung/j8y18ltejv/j8y18lte:10/QP1A.190711.020/J810FJXU4CTG2:user/release-keys");
        property_override("ro.build.description", "j8y18ltejv-user 10 QP1A.190711.020 J810FJXU4CTG2 release-keys");
        property_override_dual("ro.product.model", "ro.vendor.product.model", "SM-J810F");
        property_override_dual("ro.product.device", "ro.vendor.product.device", "j8y18lte");
    } else if (bootloader.find("J810M") != std::string::npos) {
        /* SM-J810M */
        property_override_dual("ro.build.fingerprint", "ro.vendor.build.fingerprint", "samsung/j8y18lteub/j8y18lte:10/QP1A.190711.020/J810MUBU2CTJ3:user/release-keys");
        property_override("ro.system.build.fingerprint", "samsung/j8y18lteub/j8y18lte:10/QP1A.190711.020/J810MUBU2CTJ3:user/release-keys");
        property_override("ro.build.description", "j8y18lteub-user 10 QP1A.190711.020 J810MUBU2CTJ3 release-keys");
        property_override_dual("ro.product.model", "ro.vendor.product.model", "SM-J810M");
        property_override_dual("ro.product.device", "ro.vendor.product.device", "j8y18lte");
    } else if (bootloader.find("J810Y") != std::string::npos) {
        /* SM-J810Y */
        property_override_dual("ro.build.fingerprint", "ro.vendor.build.fingerprint", "samsung/j8y18ltedx/j8y18lte:10/QP1A.190711.020/J810YDXU6CTG3:user/release-keys");
        property_override("ro.system.build.fingerprint", "samsung/j8y18ltedx/j8y18lte:10/QP1A.190711.020/J810YDXU6CTG3:user/release-keys");
        property_override("ro.build.description", "j8y18ltedx-user 10 QP1A.190711.020 J810YDXU6CTG3 release-keys");
        property_override_dual("ro.product.model", "ro.vendor.product.model", "SM-J810Y");
        property_override_dual("ro.product.device", "ro.vendor.product.device", "j8y18lte");
    }

    set_sim_info();

    device = GetProperty("ro.product.device", "");
    LOG(ERROR) << "Found bootloader id '" << bootloader.c_str() << "' setting build properties for '" << device.c_str() << "' device\n";
}
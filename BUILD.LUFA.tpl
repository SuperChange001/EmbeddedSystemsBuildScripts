load("@{name}//:helpers.bzl", "mcu_avr_gcc_flag", "cpu_frequency_flag")

filegroup(
    name = "AVR8DriverSrcFiles",
    srcs = glob([
        "LUFA/Drivers/**/*.c",
        "LUFA/Drivers/**/*.h",
        "LUFA/Drivers/USB/Core/AVR8/Template/*.c"],
                exclude = [
                    "LUFA/Drivers/**/UC3/**/*.c",
                    "LUFA/Drivers/**/XMEGA/**/*.c",
                    "LUFA/Drivers/**/UC3/**/*.h",
                    "LUFA/Drivers/**/XMEGA/**/*.h",
                ]),

)

filegroup(
    name = "Headers",
    srcs = glob([
        "LUFA/Drivers/Board/*.h",
        "LUFA/Drivers/Misc/*.h",
        "LUFA/Drivers/Peripheral/*.h",
        "LUFA/Drivers/USB/*.h",
        "LUFA/Drivers/USB/Core/AVR8/Template/*.c"
    ]),
)

filegroup(
    name = "CommonSrcFiles",
    srcs = glob([
        "LUFA/Common/**/*.c"
    ]),
)

filegroup(
    name = "CommonHdrFiles",
    srcs = glob([
        "LUFA/Common/**/*.h"
    ]),
)

filegroup(
    name = "LufaConfig",
    srcs = ["Demos/Device/ClassDriver/VirtualSerial/Config/LUFAConfig.h"],
    )

LUFA_COPTS = [
    "-Iexternal/LUFA/Demos/Device/ClassDriver/VirtualSerial/Config",
    "-pipe",
    "-gdwarf-2",
    "-g2",
    "-fshort-enums",
    "-fno-inline-small-functions",
    "-fpack-struct",
    "-Wall",
    "-fno-strict-aliasing",
    "-funsigned-char",
    "-funsigned-bitfields",
    "-ffunction-sections",
    "-DARCH=ARCH_AVR8",
    "-mrelax",
    "-fno-jump-tables",
    "-x c",
    "-Os",
    "-Wstrict-prototypes",
    "-std=gnu99",
    "-DUSE_LUFA_CONFIG_HEADER",
    "-DF_USB=8000000UL",
]

cc_library(
	name = "LUFA_USB",
	srcs = ["AVR8DriverSrcFiles"],
  hdrs = ["CommonHdrFiles", "Headers", "LufaConfig"],
  copts = mcu_avr_gcc_flag() + cpu_frequency_flag() + LUFA_COPTS,
  visibility = ["//visibility:public"]
  )
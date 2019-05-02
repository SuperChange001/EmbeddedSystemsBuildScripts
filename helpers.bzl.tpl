def upload(name, srcs = [], upload_script = "@{avr_toolchain_project}//:dfu_upload_script"):
    native.sh_binary(
        name = name,
        srcs = [upload_script],
        args = mcu(return_array = True) + ["$(location {input})".format(input = srcs[0])],
        data = [srcs[0]],
    )

def generate_hex(name, input, testonly = 0):
    native.genrule(
        name = name,
        srcs = [input],
        outs = [name + ".hex"],
        cmd = select({
            "@{avr_toolchain_project}//:avr-config": "{avr_objcopy} -O ihex -j .text -j .data -j .bss $(SRCS) $(OUTS); {avr_size} --mcu=",
            "//conditions:default": "echo 'target only valid for avr platforms'; return 1",
        }) + mcu() + select({
            "@{avr_toolchain_project}//:avr-config": " --format avr $(SRCS)",
            "//conditions:default": "",
        }),
        testonly = testonly,
    )

def construct_select_dict_for_mcu_list(mcu_list, prefix = "", suffix = "", return_array = False, default = None):
    select_dict = {}
    if default == None:
        if return_array:
            default = []
        else:
            default = ""
    select_dict["//conditions:default"] = default
    for name in mcu_list:
        value = prefix + name + suffix
        if return_array:
            value = [value]
        select_dict["@{avr_toolchain_project}//config:" + name] = value
    return select_dict

SUPPORTED_MCUS = ["atmega64", "atmega32u4"]

def mcu(return_array = False):
    select_dict = construct_select_dict_for_mcu_list(SUPPORTED_MCUS, return_array = return_array)
    return select(select_dict)

def mcu_avr_gcc_flag():
    select_dict = construct_select_dict_for_mcu_list(
        SUPPORTED_MCUS,
        prefix = "-mmcu=",
        return_array = True,
    )
    return select(select_dict)

def cpu_frequency_flag():
    select_dict = {
        "@{avr_toolchain_project}//config:cpu_8mhz": ["-DF_CPU=8000000UL"],
        "@{avr_toolchain_project}//config:cpu_12mhz": ["-DF_CPU=12000000UL"],
        "//conditions:default": [],
    }
    return select(select_dict)

def default_embedded_binary(name, srcs = [], deps = [], defines = [], copts = [], linkopts = [], visibility = [], uploader = "@{avr_toolchain_project}//:dfu_upload_script"):
    native.cc_binary(
        name = name + "ELF",
        srcs = srcs,
        copts = copts,
        linkopts = linkopts,
        defines = defines,
        deps = deps,
        visibility = visibility,
    )
    generate_hex(
        name = name,
        input = name + "ELF",
    )
    upload(
        name = "upload" + name,
        srcs = [name],
    )

def default_embedded_binaries(main_files, other_srcs = [], deps = [], copts = [], linkopts = [], visibility = []):
    for file in main_files:
        default_embedded_binary(
            name = file.rpartition(".")[0].rpartition("/")[2],
            srcs = other_srcs + [file],
            deps = deps,
            copts = copts,
            linkopts = linkopts,
            visibility = visibility,
        )